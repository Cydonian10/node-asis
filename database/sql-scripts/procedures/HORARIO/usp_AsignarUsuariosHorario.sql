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
                INNER JOIN UsuarioArea UA ON UA.UsuarioId = U.UsuarioId AND UA.Eliminado = 0
                WHERE U.UsuarioId = ids.Value
                  AND U.Eliminado = 0
                  AND UA.AreaId = @AreaId
            )
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Todos los usuarios deben pertenecer al area del horario';
            SET @CodeError = -1;
            RETURN;
        END

        -- Validacion no-solapamiento: el horario no puede cruzarse con otro horario ya asignado
        -- al usuario (sin importar el area). Compara turnos del mismo dia (DiaId) que se crucen.
        IF EXISTS (
            SELECT 1
            FROM @UsuarioIds ids
            INNER JOIN HorarioAsignacion HA ON HA.UsuarioId = ids.Value AND HA.Eliminado = 0
            INNER JOIN Horario H2 ON H2.HorarioId = HA.HorarioId AND H2.Eliminado = 0
            INNER JOIN HorarioDia HD2 ON HD2.HorarioId = H2.HorarioId AND HD2.Eliminado = 0
            INNER JOIN Turno T2 ON T2.HorarioDiaId = HD2.HorarioDiaId AND T2.Eliminado = 0
            INNER JOIN HorarioDia HD ON HD.HorarioId = @HorarioId AND HD.Eliminado = 0
                AND HD.DiaId = HD2.DiaId
            INNER JOIN Turno T ON T.HorarioDiaId = HD.HorarioDiaId AND T.Eliminado = 0
            WHERE (HA.FechaFin IS NULL OR HA.FechaFin >= CAST(GETDATE() AS DATE))
              AND (HA.FechaInicio IS NULL OR HA.FechaInicio <= CAST(GETDATE() AS DATE))
              AND T.HoraInicio < T2.HoraFin
              AND T2.HoraInicio < T.HoraFin
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El horario se cruza con otro horario ya asignado al usuario';
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
