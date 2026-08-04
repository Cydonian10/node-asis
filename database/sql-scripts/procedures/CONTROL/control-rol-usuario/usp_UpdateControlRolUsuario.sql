SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControlRolUsuario]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar control para rolUsuario en la tabla intermedia ControlRolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER     PROCEDURE [dbo].[usp_UpdateControlRolUsuario]
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

        IF NOT EXISTS (SELECT 1 FROM dbo.ControlRolUsuario WHERE id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro de ControlRolUsuario no existe o está eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        -- Actualizar registro
        UPDATE dbo.ControlRolUsuario
        SET controlId_fk    = COALESCE(@CONTROL_ID, controlId_fk),
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()     
        WHERE id = @ID;

        SET @State = 1;
        SET @Message = 'Registro actualizado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH

        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
