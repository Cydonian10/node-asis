SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertVigenciaIndividual]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear la vigencia por horario Dia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertVigenciaIndividual]
    @HORARIO_DIA_ID INT,
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @USER INT,
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

        -- VALIDACIONES DE EXISTENCIA
        IF NOT EXISTS (SELECT 1 FROM HorarioDias WHERE id = @HORARIO_DIA_ID AND bEliminado = 0)
        BEGIN
            SET @State = -1; SET @Message = 'El horario día no existe.';
            ROLLBACK TRANSACTION; RETURN;
        END;

        IF EXISTS(
            SELECT 1 
            FROM Vigencia 
            WHERE horarioDiasId_fk = @HORARIO_DIA_ID
            AND tFechaInicio = @FECHA_INICIO
            AND tFechaFin = @FECHA_FIN
            AND bEliminado = 0
        )
        BEGIN 
            SET @State = -1;
            SET @Message = 'Ya existe una vigencia con este rago de fechas'
            SET @CodeError = -1;
            RETURN;
        END;

        UPDATE Vigencia
        SET bActivo = 0,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
            FROM Vigencia V
        INNER JOIN HorarioDias hd ON v.horarioDiasId_fk = hd.id
        WHERE horarioDiasId_fk = @HORARIO_DIA_ID 
          AND bActivo = 1;

        -- INSERTAR NUEVA VIGENCIA INDIVIDUAL
        INSERT INTO Vigencia (
            horarioDiasId_fk, 
            bEliminado, 
            nCreatedBy, 
            tCreatedAt, 
            bTipo, -- 1 para Individual
            tFechaInicio, 
            tFechaFin,
            bActivo -- 1 para Activo
        )
        VALUES (
            @HORARIO_DIA_ID,
            0,
            @USER,
            GETDATE(),
            1, -- Tipo Individual
            @FECHA_INICIO,
            @FECHA_FIN,
            1  -- Estado Activo
        );

        SET @Id = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Vigencia individual creada correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Id = 0;
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
