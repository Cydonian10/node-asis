
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateUnidad]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar una unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_UpdateUnidad]
    @UNIDAD_ID INT,
    @HORA_ESTANDAR INT,
    @HORA_TOTAL INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT

    BEGIN TRY
        
        IF NOT EXISTS ( SELECT 1 FROM Unidad WHERE id = @UNIDAD_ID AND bEliminado = 0 )
                BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

         
        IF @HORA_ESTANDAR <= 0
        BEGIN
            SET @State = -1;
            SET @Message = 'Debe registrar un valor válido para hora estándar.';
            SET @CodeError = -1;
            RETURN;
        END
        
        IF  @HORA_TOTAL <= 0
        BEGIN
            SET @State = -1;
            SET @Message = 'Debe registrar un valor válido para hora total.';
            SET @CodeError = -1;
            RETURN;
        END


        UPDATE Unidad SET
            horaEstandar = COALESCE(@HORA_ESTANDAR, horaEstandar),
            horaTotal = COALESCE(@HORA_TOTAL, horaTotal)
        WHERE id = @UNIDAD_ID

        SET @AffectedRows = @@ROWCOUNT;
            
        IF (@AffectedRows > 0)
            BEGIN
                SET @State = 0;
                SET @Message = 'Unidad actualizada correctamente.';
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
