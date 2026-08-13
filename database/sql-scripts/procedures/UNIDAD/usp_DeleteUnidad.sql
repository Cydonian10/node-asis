/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteUnidad]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Eliminacion fisica de una unidad. Valida restricciones: no debe existir ninguna fila en
          Usuario (via Area.UnidadId), Horario, ControlUnidad ni FeriadoUnidad que referencie la
          unidad. Si hay restricciones, error (SPEC 04).

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

        IF EXISTS (
            SELECT 1
            FROM UsuarioArea UA
            INNER JOIN Area A ON A.AreaId = UA.AreaId
            INNER JOIN Usuario U ON U.UsuarioId = UA.UsuarioId
            WHERE A.UnidadId = @ID
              AND U.Eliminado = 0
              AND UA.Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar la unidad porque tiene usuarios asignados (UsuarioArea)';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM Horario H
            INNER JOIN Area A ON A.AreaId = H.AreaId
            WHERE A.UnidadId = @ID
              AND H.Eliminado = 0
        )
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
