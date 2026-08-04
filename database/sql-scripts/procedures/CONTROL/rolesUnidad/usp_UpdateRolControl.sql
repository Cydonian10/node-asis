SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateRolControl]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar control de Rol en la tabla [RolControl]

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_UpdateRolControl]
    @ID INT,
    @CONTROL_ID INT = NULL,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Validar existencia
        IF NOT EXISTS (SELECT 1 FROM API_SCAP_DB.dbo.RolControl WHERE Id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro de RolControl no existe o está eliminado.';
            SET @CodeError = -1;
            ROLLBACK TRAN;
            RETURN;
        END
        
        UPDATE API_SCAP_DB.dbo.RolControl
        SET 
            controlId_fk = COALESCE(@CONTROL_ID, controlId_fk),
            nUpdatedBy  = @USER,        
            tUpdatedAt  = GETDATE()     
        WHERE Id = @ID;

        SET @State = -1;
        SET @Message = 'RolControl actualizado correctamente.';
        SET @CodeError = -1;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
