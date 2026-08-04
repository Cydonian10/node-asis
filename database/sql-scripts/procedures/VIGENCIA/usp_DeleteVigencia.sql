SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteVigencia]
FECHA: 30-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar (soft delete) una vigencia según su horario y fecha límite

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteVigencia]
    @HORARIO_DIA_ID INT,
    @FECHA_LIMITE_ID INT,
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar existencia
        IF NOT EXISTS (
            SELECT 1
            FROM Vigencia
            WHERE id = @ID
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La vigencia no existe o ya fue eliminada.';
            SET @CodeError = -1;
            RETURN;
        END;

        UPDATE Vigencia
        SET bEliminado = 1
        , nUpdatedBy = @USER
        , tUpdatedAt = GETDATE()
        WHERE id = @ID;
        
        SET @State = 1;
        SET @Message = 'Vigencia eliminada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
