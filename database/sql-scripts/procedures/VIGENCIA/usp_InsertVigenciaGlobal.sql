SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertVigenciaGlobal]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear vigencias para todos los días de un horario específico

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertVigenciaGlobal]
    @HORARIO_ID INT,
    @USER INT,
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1
    FROM Horario
    WHERE id = @HORARIO_ID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET 
            @Message = 'El horario no existe o está eliminado.';
        ROLLBACK TRANSACTION;
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

        -- desactivar vigencias
        UPDATE v
        SET v.bActivo = 0, --desactivado
            v.nUpdatedBy = @USER, 
            v.tUpdatedAt = GETDATE()
        FROM Vigencia v
        INNER JOIN HorarioDias hd ON v.horarioDiasId_fk = hd.id
        WHERE hd.horarioId_fk = @HORARIO_ID
        AND v.bActivo = 1; 

        --nueva vigencia
        INSERT INTO Vigencia
        (horarioDiasId_fk, bEliminado, nCreatedBy, tCreatedAt, bTipo, tFechaInicio, tFechaFin, bActivo)
    SELECT
        hd.id,
        0,
        @USER,
        GETDATE(),
        0, -- Global
        @FECHA_INICIO,
        @FECHA_FIN,
        1 -- 1 es Activo
    FROM HorarioDias hd
    WHERE hd.horarioId_fk = @HORARIO_ID
        AND hd.bEliminado = 0;

        COMMIT TRANSACTION;

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Vigencia creada correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Id = 0; SET @State = 0; SET @CodeError = ERROR_NUMBER();
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO

