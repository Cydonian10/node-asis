SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateVigenciasGlobal]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Update vigencias para un día de un horario específico

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER   PROCEDURE [dbo].[usp_UpdateVigenciasGlobal]
    @ID INT,
    @HORARIO_ID INT,
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1
    FROM Horario
    WHERE id = @HORARIO_ID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET @Message = 'El horario no existe o está eliminado.';
        SET @CodeError = -1;
        RETURN;
    END;
        IF @FECHA_INICIO IS NULL OR @FECHA_FIN IS NULL
        BEGIN
        SET @State = -1;
        SET @Message = 'Las fechas de inicio y fin son obligatorias.';
        SET @CodeError = -1;
        RETURN;
    END;

        IF @FECHA_INICIO > @FECHA_FIN
        BEGIN
        SET @State = -1;
        SET @Message = 'La fecha de inicio no puede ser mayor que la fecha fin.';
        SET @CodeError = -1;
        RETURN;
    END;
        IF EXISTS(SELECT 1
    FROM dbo.Vigencia
    WHERE tFechaInicio = @FECHA_INICIO
        AND tFechaFin = @FECHA_FIN
        AND horarioDiasId_fk = @HORARIO_ID
        AND bEliminado = 0
        AND id <> @Id )
            BEGIN
        SET @State = -1;
        SET @Message = 'El rango de fechas ya registrado.';
        SET @CodeError = -1;
        RETURN;
    END;

        UPDATE Vigencia
        SET  tFechaInicio = @FECHA_INICIO,
             tFechaFin = @FECHA_FIN,
             nUpdatedBy = @USER,
             tUpdatedAt = GETDATE(),
             horarioDiasId_fk = COALESCE(@HORARIO_ID, horarioDiasId_fk)
        WHERE id = @ID
        AND bEliminado = 0;

        SET @State = 1;
        SET @Message = 'Vigencias actualizada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
