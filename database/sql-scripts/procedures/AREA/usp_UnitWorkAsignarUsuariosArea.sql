/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkAsignarUsuariosArea]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar en lote usuarios a un area (modelo multi-area). Por cada fila del TVP:
          - Si SyncUsuarioId es NULL o no existe en SyncUsuarios, crea el SyncUsuarios (id = MAX+1).
          - Si no existe Usuario con ese SyncUsuarioId, crea el Usuario (Active = 1, Eliminado = 0).
          - Inserta la fila en UsuarioArea (EsSupervisor = 0).
          Regla de negocio: un usuario solo puede tener UN area POR UNIDAD. Si el usuario ya tiene un
          area en la misma unidad del area destino, se rechaza.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  13-08-2026  Gabriel    Modelo multi-area: TVP con datos, crea sync usuarios, INSERT en UsuarioArea.
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkAsignarUsuariosArea]
    -- Parametros de entrada
    @AreaId INT,
    @SyncUsuarios dbo.SyncUsuarioBatchTableType READONLY,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @AreaId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM @SyncUsuarios)
        BEGIN
            SET @State = -1;
            SET @Message = 'Debe enviar al menos un usuario';
            SET @CodeError = -1;
            RETURN;
        END

        -- Si se manda SyncUsuarioId, debe existir en SyncUsuarios
        IF EXISTS (
            SELECT 1
            FROM @SyncUsuarios s
            WHERE s.SyncUsuarioId IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM SyncUsuarios SU WHERE SU.SyncUsuarioId = s.SyncUsuarioId)
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Los usuarios sincronizados enviados con id deben existir';
            SET @CodeError = -1;
            RETURN;
        END

        DECLARE @UnidadId INT;
        SELECT @UnidadId = UnidadId FROM Area WHERE AreaId = @AreaId;

        -- Regla "un area por unidad": rechazar si el usuario ya tiene un area en esta unidad
        IF EXISTS (
            SELECT 1
            FROM @SyncUsuarios s
            INNER JOIN SyncUsuarios SU ON SU.SyncUsuarioId = s.SyncUsuarioId
            INNER JOIN Usuario U ON U.SyncUsuarioId = SU.SyncUsuarioId AND U.Eliminado = 0
            INNER JOIN UsuarioArea UA ON UA.UsuarioId = U.UsuarioId AND UA.Eliminado = 0
            INNER JOIN Area A ON A.AreaId = UA.AreaId AND A.Eliminado = 0
            WHERE A.UnidadId = @UnidadId
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Un usuario ya tiene un area en esta unidad';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        -- 1) Crear SyncUsuarios nuevos (SyncUsuarioId NULL), id = MAX + secuencia
        DECLARE @Base INT;
        SELECT @Base = ISNULL(MAX(SyncUsuarioId), 0) FROM SyncUsuarios;

        SELECT
            @Base + ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS syncUsuarioId,
            s.Usuario, s.Nombres, s.Apellidos, s.Tipo, s.Dni
        INTO #NuevosSync
        FROM @SyncUsuarios s
        WHERE s.SyncUsuarioId IS NULL
          AND LTRIM(RTRIM(ISNULL(s.Usuario, ''))) <> '';

        INSERT INTO SyncUsuarios (SyncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni)
        SELECT syncUsuarioId, Usuario, Nombres, Apellidos, Tipo, Dni
        FROM #NuevosSync;

        -- 2) Crear Usuarios faltantes (cubre existentes y nuevos)
        INSERT INTO Usuario (SyncUsuarioId, Active, Eliminado)
        SELECT su.SyncUsuarioId, 1, 0
        FROM (
            SELECT s.SyncUsuarioId FROM @SyncUsuarios s WHERE s.SyncUsuarioId IS NOT NULL
            UNION
            SELECT syncUsuarioId FROM #NuevosSync
        ) su
        WHERE NOT EXISTS (SELECT 1 FROM Usuario U WHERE U.SyncUsuarioId = su.SyncUsuarioId);

        -- 3) Insertar filas en UsuarioArea
        INSERT INTO UsuarioArea (UsuarioId, AreaId, EsSupervisor, Eliminado)
        SELECT U.UsuarioId, @AreaId, 0, 0
        FROM (
            SELECT s.SyncUsuarioId FROM @SyncUsuarios s WHERE s.SyncUsuarioId IS NOT NULL
            UNION
            SELECT syncUsuarioId FROM #NuevosSync
        ) su
        INNER JOIN Usuario U ON U.SyncUsuarioId = su.SyncUsuarioId
        WHERE NOT EXISTS (
            SELECT 1 FROM UsuarioArea UA
            WHERE UA.UsuarioId = U.UsuarioId AND UA.AreaId = @AreaId AND UA.Eliminado = 0
        );

        DROP TABLE #NuevosSync;

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Usuarios asignados al area correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
