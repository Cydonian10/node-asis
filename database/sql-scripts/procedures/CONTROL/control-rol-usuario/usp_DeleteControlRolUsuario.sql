SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControlRolUsuario]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Elimina (lógico) un registro en la tabla ControlRolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_DeleteControlRolUsuario]
    @ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar que exista
        IF NOT EXISTS (SELECT 1 FROM ControlRolUsuario WHERE Id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró el registro o ya fue eliminado.';
            SET @CodeError = -1; 
            RETURN;
        END

        -- Eliminado lógico
        UPDATE ControlRolUsuario
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE Id = @ID;

        SET @State = 1;
        SET @Message = 'Registro eliminado correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
