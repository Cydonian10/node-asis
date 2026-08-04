SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControlUnidad]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar (lógicamente) un registro en la tabla ControlUnidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_DeleteControlUnidad]
    @Id INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar que el registro exista y no esté ya eliminado
        IF NOT EXISTS (SELECT 1 
                       FROM ControlUnidad 
                       WHERE id = @Id AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró el registro de ControlUnidad o ya fue eliminado.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Eliminar (lógicamente)
        UPDATE ControlUnidad
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @Id;

        SET @State = 1;
        SET @Message = 'Control Unidad eliminado correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
