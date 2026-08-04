/*======================================================================================================
NOMBRE: [dbo].[usp_CreateArea]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Crear un area subordinada a una unidad (Area.UnidadId). Valida que la unidad exista y que
          el nombre no sea vacio. Devuelve el AreaId en @Id.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateArea]
    -- Parametros de entrada
    @Nombre VARCHAR(200),
    @Descripcion VARCHAR(255) = NULL,
    @UnidadId INT,
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
        IF NOT EXISTS (SELECT 1 FROM Unidad WHERE UnidadId = @UnidadId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La unidad no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF @Nombre IS NULL OR LTRIM(RTRIM(@Nombre)) = ''
        BEGIN
            SET @State = -1;
            SET @Message = 'El nombre del area es requerido';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO Area (UnidadId, Nombre, Descripcion, CreatedBy, UpdatedBy)
        VALUES (@UnidadId, @Nombre, @Descripcion, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Area creada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
