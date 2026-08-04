SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_InsertCursoSeccionBasica_TurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Crear la relación entre curso sección básica y turno regular especidifamente
    insertar un nuevo registro en la tabla CursoSeccionBasica_TurnoRegular

    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
     -     -            -            -
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertCursoSeccionBasica_TurnoRegular]
    @SYNC_CURSO_SECCION_ID INT,
    @TURNO_REGULAR_ENTRADA_ID INT,
    @TURNO_REGULAR_SALIDA_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF EXISTS (
            SELECT 1 FROM
                CursoSeccionBasica_TurnoRegular
            WHERE turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID
              AND turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una asignación registrada para este turno regular.';
            SET @CodeError = -1;
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
            SET @CodeError = -2;
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
            SET @CodeError = -2;
            RETURN;
        END

        INSERT INTO CursoSeccionBasica_TurnoRegular (
            syncCursoSeccionId,
            turnoRegularEntradaId,
            turnoRegularSalidaId,
            nCreatedBy,
            tCreatedAt
        ) VALUES (
            @SYNC_CURSO_SECCION_ID,
            @TURNO_REGULAR_ENTRADA_ID,
            @TURNO_REGULAR_SALIDA_ID,
            @USER,
            GETDATE()
        );

        SET @State = 1;
        SET @Message = 'Registro insertado correctamente.';
        SET @Id = SCOPE_IDENTITY();
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
