/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControlVacaciones]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Actualizar datos de control vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateControlVacaciones]
    @ID INT
    , @DIASDISPONIBLES INT = NULL
    , @DIASTOMADOS INT = NULL
    , @USER INT
    , @APROBADO BIT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF (@DIASDISPONIBLES IS NOT NULL AND @DIASDISPONIBLES < 0)
        BEGIN
            SET @State = - 1;
            SET @Message = 'El numero de días disponibles no es válido.';

            RETURN;
        END;

        IF  (@DIASTOMADOS IS NOT NULL AND @DIASTOMADOS < 0)
        BEGIN
            SET @State = - 1;
            SET @Message = 'El numero de días tomados no es válido.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM ControlVacaciones
                WHERE bEliminado = 0
                    AND Id = @ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El control no existe o fue eliminado';

            RETURN
        END

        UPDATE ControlVacaciones
        SET nDiasDisponibles = COALESCE(NULLIF(@DIASDISPONIBLES, 0), nDiasDisponibles)
            , nDiasTomados = COALESCE(NULLIF(@DIASTOMADOS, 0), nDiasTomados)
            , nUpdatedBy = @USER
            , bAprobado = COALESCE(@APROBADO, bAprobado)
            , nAprobadoBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER()
    END CATCH
END
GO
