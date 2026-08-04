SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteRolControl]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar (lógicamente) un registro en la tabla RolControl

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_DeleteRolControl]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar existencia
        IF NOT EXISTS (SELECT 1 FROM RolControl WHERE Id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro de RolControl no existe o ya está eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

          -- Validar existencia
        IF EXISTS (SELECT 1 FROM RolControlAsistencia WHERE rolControlId_fk = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El RolControl seleccionado está en uso por RolControlAsistencia y no puede eliminarse."';
            SET @CodeError = -1;
            RETURN;
        END

        -- Eliminación lógica
        UPDATE RolControl
        SET bEliminado = 1,
            nUpdatedBy = @USER,     
            tCreatedAt = GETDATE()  
        WHERE Id = @ID;

        SET @State = 1;
        SET @Message = 'RolControl eliminado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
