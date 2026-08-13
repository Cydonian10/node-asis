/*======================================================================================================
NOMBRE: [dbo].[usp_CreateSyncUnidad]
FECHA: 13-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un registro en SyncUnidad. Si no se envia @SyncUnidadId, se asigna MAX+1.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateSyncUnidad]
    -- Parametros de entrada
    @SyncUnidadId INT = NULL,
    @Codigo VARCHAR(50) = NULL,
    @Nombre VARCHAR(200) = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF LTRIM(RTRIM(ISNULL(@Nombre, ''))) = ''
        BEGIN
            SET @State = -1;
            SET @Message = 'El nombre es requerido';
            SET @CodeError = -1;
            RETURN;
        END

        IF @SyncUnidadId IS NULL
        BEGIN
            SELECT @SyncUnidadId = ISNULL(MAX(SyncUnidadId), 0) + 1 FROM SyncUnidad;
        END

        IF EXISTS (SELECT 1 FROM SyncUnidad WHERE SyncUnidadId = @SyncUnidadId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La unidad sincronizada ya existe';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO SyncUnidad (SyncUnidadId, Codigo, Nombre)
        VALUES (@SyncUnidadId, @Codigo, @Nombre);

        SET @Id = @SyncUnidadId;
        SET @State = 1;
        SET @Message = 'Unidad sincronizada creada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
