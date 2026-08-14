/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteVigenciaGrupo]
FECHA: 14-08-2026
AUTOR: Gabriel
OBJETIVO: Soft-delete de un grupo de vigencia: marca Eliminado = 1 en el grupo y en cascada en sus
          HorarioDia, Turnos y SalidaTurnoDia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteVigenciaGrupo]
    -- Parametros de entrada
    @ID INT,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM VigenciaGrupo WHERE VigenciaGrupoId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El grupo de vigencia no existe';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        UPDATE STD
        SET STD.Eliminado = 1, STD.UpdatedAt = GETDATE(), STD.UpdatedBy = @USER
        FROM SalidaTurnoDia STD
        INNER JOIN Turno T ON T.TurnoId = STD.TurnoId
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
        WHERE HD.VigenciaGrupoId = @ID AND STD.Eliminado = 0;

        UPDATE T
        SET T.Eliminado = 1, T.UpdatedAt = GETDATE(), T.UpdatedBy = @USER
        FROM Turno T
        INNER JOIN HorarioDia HD ON HD.HorarioDiaId = T.HorarioDiaId
        WHERE HD.VigenciaGrupoId = @ID AND T.Eliminado = 0;

        UPDATE HD
        SET HD.Eliminado = 1, HD.UpdatedAt = GETDATE(), HD.UpdatedBy = @USER
        FROM HorarioDia HD
        WHERE HD.VigenciaGrupoId = @ID AND HD.Eliminado = 0;

        UPDATE VigenciaGrupo
        SET Eliminado = 1, UpdatedAt = GETDATE(), UpdatedBy = @USER
        WHERE VigenciaGrupoId = @ID;

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Grupo de vigencia eliminado correctamente';
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
