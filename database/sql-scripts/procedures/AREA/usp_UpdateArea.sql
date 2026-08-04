/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateArea]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar el nombre y/o descripcion de un area. Solo actualiza las columnas enviadas
          (ISNULL sobre el valor actual). Nunca sobreescribe UnidadId.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateArea]
    -- Parametros de entrada
    @ID INT,
    @Nombre VARCHAR(200) = NULL,
    @Descripcion VARCHAR(255) = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El area no existe';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE Area
        SET Nombre = ISNULL(@Nombre, Nombre),
            Descripcion = ISNULL(@Descripcion, Descripcion),
            UpdatedAt = GETDATE(),
            UpdatedBy = @USER
        WHERE AreaId = @ID;

        SET @State = 1;
        SET @Message = 'Area actualizada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
