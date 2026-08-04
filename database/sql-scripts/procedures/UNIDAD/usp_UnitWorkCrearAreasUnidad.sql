/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkCrearAreasUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Crear en lote N areas para una unidad. Inserta en una sola sentencia cada fila del TVP
          Areas con UnidadId = @UnidadId dentro de transaccion. No hay loop row-by-row.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkCrearAreasUnidad]
    -- Parametros de entrada
    @UnidadId INT,
    @Areas dbo.AreaBatchTableType READONLY,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Unidad WHERE UnidadId = @UnidadId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La unidad no existe';
            SET @CodeError = -1;
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO Area (UnidadId, Nombre, Descripcion, CreatedBy, UpdatedBy)
        SELECT @UnidadId, Nombre, Descripcion, @USER, @USER
        FROM @Areas;

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Areas creadas correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
