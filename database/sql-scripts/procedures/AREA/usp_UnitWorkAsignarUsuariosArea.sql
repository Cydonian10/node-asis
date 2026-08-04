/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkAsignarUsuariosArea]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar en lote usuarios a un area. Inserta en una sola sentencia los usuarios del TVP
          que aun no estan asignados al area (respeta el UNIQUE de UsuarioArea). Si el usuario ya
          esta asignado (aunque sea Eliminado = 1), se omite. No hay loop row-by-row.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkAsignarUsuariosArea]
    -- Parametros de entrada
    @AreaId INT,
    @UsuarioIds dbo.IntListTableType READONLY,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        -- Primero obtenemos la unidad propietaria del area. La asignacion debe respetar
        -- la jerarquia Unidad -> Area -> Usuario.
        DECLARE @UnidadId INT;
        SELECT @UnidadId = UnidadId
        FROM Area
        WHERE AreaId = @AreaId AND Eliminado = 0;

        IF @UnidadId IS NULL
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        -- Todos los usuarios recibidos deben existir, estar activos y pertenecer
        -- actualmente a la misma unidad del area. Si uno no cumple, se rechaza
        -- todo el lote para evitar asignaciones inconsistentes.
        IF EXISTS (
            SELECT 1
            FROM @UsuarioIds ids
            WHERE NOT EXISTS (
                SELECT 1
                FROM UsuarioUnidad uu
                INNER JOIN Usuario u ON u.UsuarioId = uu.UsuarioId
                WHERE uu.UsuarioId = ids.Value
                  AND uu.UnidadId = @UnidadId
                  AND uu.Eliminado = 0
                  AND u.Eliminado = 0
            )
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Todos los usuarios deben pertenecer a la misma unidad del area';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO UsuarioArea (UsuarioId, AreaId, CreatedBy, UpdatedBy)
        SELECT t.Value, @AreaId, @USER, @USER
        FROM @UsuarioIds t
        WHERE NOT EXISTS (
            SELECT 1 FROM UsuarioArea ua
            WHERE ua.UsuarioId = t.Value AND ua.AreaId = @AreaId
        );

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
