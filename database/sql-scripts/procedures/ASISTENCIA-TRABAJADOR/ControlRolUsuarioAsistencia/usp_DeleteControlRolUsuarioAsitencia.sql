SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControlRolUsuarioAsitencia]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar asistencia con que estado esta el usuario rol y que control se utlizo

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteControlRolUsuarioAsitencia]
    @ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ControlRolUsuarioAsistencia WHERE id = @ID AND bEliminado = 0)
        BEGIN 
            SET @State = -1;
            SET @Message = 'El registro de ControlRolUsuarioAsistencia no existe o ya está eliminado'
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE ControlRolUsuarioAsistencia
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID

        SET @State = 1;
        SET @Message = 'ControlRolUsuarioAsistencia eliminado correctamente'
        SET @CodeError = 0

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO
