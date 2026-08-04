/*======================================================================================================
NOMBRE: [dbo].[usp_UnitWorkAsignarUsuariosUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Asignar en lote usuarios a una unidad. Inserta en una sola sentencia los usuarios del
          TVP que aun no estan asignados a la unidad. Si el usuario ya esta asignado (aunque sea
          Eliminado = 1), se omite. No hay loop row-by-row.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UnitWorkAsignarUsuariosUnidad]
    -- Parametros de entrada
    @UnidadId INT,
    @UsuarioIds dbo.IntListTableType READONLY,
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

        INSERT INTO UsuarioUnidad (UsuarioId, UnidadId, CreatedBy, UpdatedBy)
        SELECT t.Value, @UnidadId, @USER, @USER
        FROM @UsuarioIds t
        WHERE NOT EXISTS (
            SELECT 1 FROM UsuarioUnidad uu
            WHERE uu.UsuarioId = t.Value AND uu.UnidadId = @UnidadId
        );

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Usuarios asignados a la unidad correctamente';
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
