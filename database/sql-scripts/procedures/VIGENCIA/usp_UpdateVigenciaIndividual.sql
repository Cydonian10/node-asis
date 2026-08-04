SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateVigenciaIndividual]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Update vigencias para un día de un horario específico

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateVigenciaIndividual]
    @ID INT,
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que exista el registro original
        IF NOT EXISTS (
            SELECT 1 
            FROM Vigencia 
            WHERE Id = @ID 
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'La vigencia original no existe o ya fue eliminada.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Actualizar
        UPDATE Vigencia
        SET 
            tFechaInicio = @FECHA_INICIO,
            tFechaFin = @FECHA_FIN,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID

        SET @State = 1;
        SET @Message = 'Vigencia actualizada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
