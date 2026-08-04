/*======================================================================================================
NOMBRE: [dbo].[usp_InsertFechaLimite]
FECHA: 30-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar registro en la tabla FechaLimite

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertFechaLimite]
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar fechas obligatorias
        IF @FECHA_INICIO IS NULL OR @FECHA_FIN IS NULL
        BEGIN
            SET @State = -1;
            SET @Message = 'Las fechas de inicio y fin son obligatorias.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Validar rango lógico
        IF @FECHA_INICIO > @FECHA_FIN
        BEGIN
            SET @State = -1;
            SET @Message = 'La fecha de inicio no puede ser mayor que la fecha fin.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Evitar duplicados exactos
        IF EXISTS (
            SELECT 1
            FROM FechaLimite
            WHERE tfechaInicio = @FECHA_INICIO
              AND tfechaFin = @FECHA_FIN
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe un rango de fechas igual.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Insertar
        INSERT INTO API_SCAP_DB.dbo.FechaLimite
            (tfechaInicio, tfechaFin, bEliminado, nCreatedBy, tCreatedAt)
        VALUES
            (@FECHA_INICIO, @FECHA_FIN, 0, @USER, GETDATE());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Fecha límite registrada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
