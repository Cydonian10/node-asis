SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControlUnidad]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar control para ControlUnidad en la tabla UpdateControlUnidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_UpdateControlUnidad]
    @Id INT,
    @CONTROL_ID INT = NULL,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar que el registro exista y no esté eliminado
        IF NOT EXISTS (SELECT 1 
                       FROM ControlUnidad 
                       WHERE id = @Id AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró el registro de ControlUnidad.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Actualizar
        UPDATE ControlUnidad
        SET controlId_fk = COALESCE(@CONTROL_ID, controlId_fk),
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @Id;

        SET @State = 1;
        SET @Message = 'ControlUnidad actualizado correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
