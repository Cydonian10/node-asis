SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_UpdateCursoSeccionBasicaTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Actualizar la relación entre curso sección básica y turno regular
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
     -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateCursoSeccionBasicaTurnoRegular]
    @ID INT,
    @SYNC_CURSO_SECCION_ID INT,
    @TURNO_REGULAR_ENTRADA_ID INT,
    @TURNO_REGULAR_SALIDA_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1
            FROM CursoSeccionBasica_TurnoRegular
            WHERE id = @ID AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró la asignación especificada para actualizar.';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM
                CursoSeccionBasica_TurnoRegular
            WHERE turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID
              AND turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID
              AND id <> @ID
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una asignación registrada para este turno regular.';
            SET @CodeError = -2;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @TURNO_REGULAR_ENTRADA_ID AND bTipo = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de entrada no es válido. Debe tener bTipo = 0.';
            SET @CodeError = -3;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @TURNO_REGULAR_SALIDA_ID AND bTipo = 1
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de salida no es válido. Debe tener bTipo = 1.';
            SET @CodeError = -4;
            RETURN;
        END

        UPDATE CursoSeccionBasica_TurnoRegular
        SET 
            syncCursoSeccionId = @SYNC_CURSO_SECCION_ID,
            turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID,
            turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @State = 1;
        SET @Message = 'Asignación actualizada exitosamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        RETURN;
    END CATCH
END
GO
