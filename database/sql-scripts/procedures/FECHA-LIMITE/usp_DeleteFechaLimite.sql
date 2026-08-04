SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertVigenciaIndividual]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar una fecha limite

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_DeleteFechaLimite]
    @ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM FechaLimite WHERE id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya está eliminado.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Verificar si está en uso en Vigencia
        IF EXISTS (SELECT 1 FROM Vigencia WHERE fechaLimiteId_pk = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar porque está en uso en Vigencia.';
            SET @CodeError = -1;
            RETURN;
        END;

        UPDATE FechaLimite
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @State = 1;
        SET @Message = 'FechaLimite eliminada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

