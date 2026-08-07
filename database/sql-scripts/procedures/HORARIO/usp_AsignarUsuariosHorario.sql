/*======================================================================================================
NOMBRE: [dbo].[usp_AsignarUsuariosHorario]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar en lote usuarios a un horario. Valida que cada usuario exista, no este eliminado
          y pertenezca al area del horario (Usuario.AreaId = Horario.AreaId). Inserta HorarioAsignacion
          con FechaInicio = GETDATE() y FechaFin = NULL. No duplica (UsuarioId, HorarioId) no eliminados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_AsignarUsuariosHorario]
    -- Parametros de entrada
    @HorarioId INT,
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
        DECLARE @AreaId INT;
        SELECT @AreaId = AreaId
        FROM Horario
        WHERE HorarioId = @HorarioId AND Eliminado = 0;

        IF @AreaId IS NULL
        BEGIN
            SET @State = -1;
            SET @Message = 'El horario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM @UsuarioIds ids
            WHERE NOT EXISTS (
                SELECT 1
                FROM Usuario U
                WHERE U.UsuarioId = ids.Value
                  AND U.Eliminado = 0
                  AND U.AreaId = @AreaId
            )
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Todos los usuarios deben pertenecer al area del horario';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO HorarioAsignacion (UsuarioId, HorarioId, FechaInicio, FechaFin, Eliminado, CreatedBy, UpdatedBy)
        SELECT t.Value, @HorarioId, CAST(GETDATE() AS DATE), NULL, 0, @USER, @USER
        FROM @UsuarioIds t
        WHERE NOT EXISTS (
            SELECT 1 FROM HorarioAsignacion HA
            WHERE HA.UsuarioId = t.Value
              AND HA.HorarioId = @HorarioId
              AND HA.Eliminado = 0
        );

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Usuarios asignados al horario correctamente';
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
