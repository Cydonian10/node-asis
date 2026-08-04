SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_InsertCursoPreUniversitarioTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Insertar datos en la tabla CursoSeccionPreUniversitaria_TurnoRegular
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertCursoPreUniversitarioTurnoRegular]
    @syncCursoSeccionPreUniversitariaId INT,
    @turnoRegularEntradaId INT,
    @turnoRegularSalidaId INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        IF EXISTS (
            SELECT 1
            FROM API_SCAP_DB.dbo.CursoSeccionPreUniversitaria_TurnoRegular
            WHERE turnoRegularEntradaId = @turnoRegularEntradaId
              AND turnoRegularSalidaId = @turnoRegularSalidaId
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una asignación registrada para una sección preuniversitaria con el mismo turno de entrada y salida.';
            SET @CodeError = -2;
            RETURN;
        END


        -- verificar si entrada es bTipo 0 
        IF NOT EXISTS (
            SELECT 1
            FROM API_SCAP_DB.dbo.TurnoRegular
            WHERE id = @turnoRegularEntradaId AND bTipo = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de entrada no es válido. Debe tener bTipo = 0.';
            SET @CodeError = -3;
            RETURN;
        END

        -- verificar si salida es bTipo 1
        IF NOT EXISTS (
            SELECT 1
            FROM API_SCAP_DB.dbo.TurnoRegular
            WHERE id = @turnoRegularSalidaId AND bTipo = 1
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de salida no es válido. Debe tener bTipo = 1.';
            SET @CodeError = -4;
            RETURN;
        END


        INSERT INTO API_SCAP_DB.dbo.CursoSeccionPreUniversitaria_TurnoRegular
        ( syncCursoSeccionPreUniversitariaId, turnoRegularEntradaId, turnoRegularSalidaId, bEliminado, nCreatedBy, tCreatedAt )
            VALUES
        ( @syncCursoSeccionPreUniversitariaId, @turnoRegularEntradaId, @turnoRegularSalidaId, 0, @USER, getdate());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Asignación registrada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH   
END
GO
