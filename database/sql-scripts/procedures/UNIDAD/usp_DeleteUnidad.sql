/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteUnidad]
FECHA: 04-08-2026
AUTOR: Gabriel
OBJETIVO: Eliminacion fisica de una unidad. Valida restricciones: no debe existir ninguna fila
          (eliminada o no) en UsuarioUnidad, Rol, Horario, ControlUnidad ni FeriadoUnidad que
          referencie UnidadId, porque las FK bloquearian el DELETE. Si hay restricciones, error.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeleteUnidad]
    -- Parametros de entrada
    @ID INT,
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

        IF EXISTS (SELECT 1 FROM UsuarioUnidad WHERE UnidadId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar la unidad porque tiene usuarios asignados (UsuarioUnidad)';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Rol WHERE UnidadId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar la unidad porque tiene roles asociados (Rol)';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Horario WHERE UnidadId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar la unidad porque tiene horarios asociados (Horario)';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM ControlUnidad WHERE UnidadId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar la unidad porque tiene controles asociados (ControlUnidad)';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM FeriadoUnidad WHERE UnidadId = @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar la unidad porque tiene feriados asociados (FeriadoUnidad)';
            SET @CodeError = -1;
            RETURN;
        END

        DELETE FROM Unidad WHERE UnidadId = @ID;

        SET @State = 1;
        SET @Message = 'Unidad eliminada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
