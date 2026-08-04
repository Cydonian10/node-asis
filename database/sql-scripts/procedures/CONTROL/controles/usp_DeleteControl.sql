SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControl]
FECHA: 18-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_DeleteControl]
    @CONTROL_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY

        IF EXISTS (SELECT 1 FROM ControlUnidad cu WHERE cu.controlId_fk = @CONTROL_ID) OR 
           EXISTS (SELECT 1 FROM ControlRolUsuario cru WHERE cru.controlId_fk = @CONTROL_ID)  OR 
           EXISTS (SELECT 1 FROM RolControl rc WHERE rc.controlId_fk = @CONTROL_ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar, el control está en uso.'
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS ( SELECT 1 FROM [Controles] WHERE id = @CONTROL_ID and bEliminado = 0)
            BEGIN
                SET @State = -1;
                SET @Message = 'Registro fue eliminado o no existe.'
                SET @CodeError = -1;
            RETURN;
        END


        UPDATE CONTROLES 
            SET bEliminado = 1
        WHERE Id = @CONTROL_ID
        
        SET @State = 1;
        SET @Message = 'Control eliminado correctamente';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO
