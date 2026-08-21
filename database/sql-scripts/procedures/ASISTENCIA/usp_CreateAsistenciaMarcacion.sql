/*======================================================================================================
NOMBRE: [dbo].[usp_CreateAsistenciaMarcacion]
FECHA: 07-08-2026
AUTOR: Gabriel
OBJETIVO: Enlazar una marcacion a una asistencia con su TipoMarcacion ('entrada'/'salida').
          No duplica (MarcacionId, AsistenciaId) sin eliminar.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateAsistenciaMarcacion]
    -- Parametros de entrada
    @AsistenciaId INT,
    @MarcacionId INT,
    @BiometricoId INT = NULL,
    @TipoMarcacion VARCHAR(50),
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
        IF NOT EXISTS (SELECT 1 FROM Asistencia WHERE AsistenciaId = @AsistenciaId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La asistencia no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Marcacion WHERE MarcacionId = @MarcacionId AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'La marcacion no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM AsistenciaMarcacion WHERE MarcacionId = @MarcacionId)
        BEGIN
            SET @State = -1;
            SET @Message = 'La marcacion ya esta enlazada a una asistencia';
            SET @CodeError = -1;
            RETURN;
        END

        IF @BiometricoId IS NOT NULL
           AND NOT EXISTS (
               SELECT 1 FROM Biometrico
               WHERE BiometricoId = @BiometricoId AND Eliminado = 0
           )
        BEGIN
            SET @State = -1;
            SET @Message = 'El biometrico no existe';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO AsistenciaMarcacion (AsistenciaId, MarcacionId, BiometricoId, TipoMarcacion, CreatedBy, UpdatedBy)
        VALUES (@AsistenciaId, @MarcacionId, @BiometricoId, @TipoMarcacion, @USER, @USER);

        SET @Id = SCOPE_IDENTITY();

        SET @State = 1;
        SET @Message = 'Marcacion enlazada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
