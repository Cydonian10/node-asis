SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdatePermiso]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite realizar la actualización del permiso.


MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdatePermiso] 
    @ID INT
    , @ROLUSUARIOID INT
    , @MOTIVOID INT
    , @FECHA DATE
    , @HORASALIDA TIME = NULL
    , @HORARETORNOESTIMADO TIME = NULL
    , @HORARETORNOREAL TIME = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROLUSUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El rol de usuario no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Motivo
                WHERE id = @MOTIVOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El motivo no existe o fue eliminado.';

            RETURN;
        END;

        IF (
                @FECHA IS NULL
                OR @HORASALIDA IS NULL
                OR @HORARETORNOESTIMADO IS NULL
                OR @HORARETORNOREAL IS NULL
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'La fecha y horas no pueden ser nulas.';

            RETURN;
        END;

        IF (
                @HORASALIDA = '00:00'
                OR @HORARETORNOESTIMADO = '00:00'
                OR @HORARETORNOREAL = '00:00'
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Las horas no pueden ser 00:00.';

            RETURN;
        END;

        UPDATE Permiso
        SET rolUsuarioId_fk = @ROLUSUARIOID
            , motivoId_fk = @MOTIVOID
            , tFecha = COALESCE(@FECHA, tFecha)
            , tHoraSalida = COALESCE(@HORASALIDA, tHoraSalida)
            , tHoraRetornoEstimado = COALESCE(@HORARETORNOESTIMADO, tHoraRetornoEstimado)
            , tHoraRetornoReal = COALESCE(@HORARETORNOREAL, tHoraRetornoReal)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO
