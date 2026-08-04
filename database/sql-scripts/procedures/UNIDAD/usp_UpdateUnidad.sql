/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar las horas laborales de una unidad. Solo actualiza las columnas enviadas
          (ISNULL sobre el valor actual). Nunca sobreescribe SyncUnidadId.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateUnidad]
    -- Parametros de entrada
    @ID INT,
    @HorasLaborales INT = NULL,
    @HorasLaboralesTotales INT = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Unidad WHERE UnidadId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'La unidad no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Unidad
        SET HorasLaborales = ISNULL(@HorasLaborales, HorasLaborales),
            HorasLaboralesTotales = ISNULL(@HorasLaboralesTotales, HorasLaboralesTotales)
        WHERE UnidadId = @ID;

        SET @State = 1;
        SET @Message = 'Unidad actualizada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
