SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
    NOMBRE: [dbo].[usp_DeleteCursoSeccionPreUniversitarioTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Eliminar la relación entre curso sección preuniversitaria y turno regular
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
     -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteCursoSeccionPreUniversitarioTurnoRegular]
    @ID INT,
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
            FROM CursoSeccionPreUniversitaria_TurnoRegular
            WHERE id = @ID AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró la asignación especificada para eliminar.';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE CursoSeccionPreUniversitaria_TurnoRegular
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @State = 1;
        SET @Message = 'Asignación eliminada exitosamente.';
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
