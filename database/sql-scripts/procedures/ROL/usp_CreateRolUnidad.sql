/*======================================================================================================
NOMBRE: [dbo].[usp_CreateRolUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Instanciar un rol del catalogo global en una unidad (tabla RolUnidad). Valida que el rol y
          la unidad existan y que el par (RolId, UnidadId) no este duplicado (UNIQUE). Devuelve el
          RolUnidadId en @Id.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateRolUnidad]
    -- Parametros de entrada
    @RolId INT,
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
        IF NOT EXISTS (SELECT 1 FROM Rol WHERE RolId = @RolId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El rol no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Unidad WHERE UnidadId = @UnidadId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La unidad no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM RolUnidad WHERE RolId = @RolId AND UnidadId = @UnidadId)
        BEGIN
            SET @State = -1;
            SET @Message = 'El rol ya esta instanciado en la unidad';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO RolUnidad (RolId, UnidadId, CreatedBy, UpdatedBy)
        VALUES (@RolId, @UnidadId, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Rol asignado a la unidad correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
