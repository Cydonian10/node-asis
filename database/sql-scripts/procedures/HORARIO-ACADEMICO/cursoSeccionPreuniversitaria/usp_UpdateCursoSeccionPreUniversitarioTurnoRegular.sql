SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_UpdateCursoSeccionPreUniversitarioTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Actualizar tabla CursoSeccionPreUniversitaria_TurnoRegular
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateCursoSeccionPreUniversitarioTurnoRegular]
    @Id INT,
    @syncCursoSeccionPreUniversitariaId INT,
    @turnoRegularEntradaId INT,
    @turnoRegularSalidaId INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; 

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM CursoSeccionPreUniversitaria_TurnoRegular WHERE id = @Id AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No existe una asignación registrada con el Id proporcionado.';
            SET @CodeError = -1;
            RETURN;
        END

        -- IF EXISTS (
        --     SELECT 1
        --     FROM CursoSeccionPreUniversitaria_TurnoRegular
        --     WHERE turnoRegularEntradaId = @turnoRegularEntradaId
        --       AND turnoRegularSalidaId = @turnoRegularSalidaId
        --       AND id <> @Id
        --       AND bEliminado = 0
        -- )
        -- BEGIN
        --     SET @State = -1;
        --     SET @Message = 'Ya existe una asignación registrada para una sección preuniversitaria con el mismo turno de entrada y salida.';
        --     SET @CodeError = -2;
        --     RETURN;
        -- END

        -- verificar si entrada es bTipo 0
        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @turnoRegularEntradaId AND bTipo = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de entrada debe ser de tipo 0.';
            SET @CodeError = -3;
            RETURN;
        END

        -- verificar si salida es bTipo 1
        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @turnoRegularSalidaId AND bTipo = 1
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de salida debe ser de tipo 1.';
            SET @CodeError = -4;
            RETURN;
        END

        -- Realizar la actualización
        UPDATE CursoSeccionPreUniversitaria_TurnoRegular
        SET
            syncCursoSeccionPreUniversitariaId = @syncCursoSeccionPreUniversitariaId,
            turnoRegularEntradaId = @turnoRegularEntradaId,
            turnoRegularSalidaId = @turnoRegularSalidaId,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @Id;

        SET @State = 1;
        SET @Message = 'Asignación actualizada correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END

GO
