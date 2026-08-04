SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControl]
FECHA: 18-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar un control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_UpdateControl]
    @CONTROL_ID INT
    , @TOLERANCIA INT
    , @LIMITE_FALTA INT
    , @LIMITE_MARCACION INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT

    BEGIN TRY
        IF EXISTS (
                SELECT 1
                FROM CONTROLES
                WHERE nTolerancia = @TOLERANCIA
                    AND nLimiteFalta = @LIMITE_FALTA
                    AND nLimiteMarcacion = @LIMITE_MARCACION
                    AND Id <> @CONTROL_ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'Ya existe otro registro con esos valores';
            SET @CodeError = - 1;

            RETURN;
        END;

        UPDATE CONTROLES
        SET nTolerancia = COALESCE(@TOLERANCIA, nTolerancia)
            , nLimiteFalta = COALESCE(@LIMITE_FALTA, nLimiteFalta)
            , nLimiteMarcacion = COALESCE(@LIMITE_MARCACION, nLimiteMarcacion)
        WHERE id = @CONTROL_ID

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Control actualizada correctamente.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
