/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateFechaLimite]
FECHA: 17-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actulizar registro en la tabla FechaLimite

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE dbo.usp_UpdateFechaLimite
    @Id INT OUTPUT,    
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validaciones básicas
        IF @Id IS NULL OR @Id <= 0
        BEGIN
            SET @State = -1;
            SET @Message = 'El identificador (Id) es obligatorio y debe ser mayor que 0.';
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

        -- Comprobar existencia y estado del registro a actualizar
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.FechaLimite
            WHERE id = @Id
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró un registro activo con el Id proporcionado.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Evitar duplicados exactos en otros registros
        IF EXISTS (
            SELECT 1
            FROM dbo.FechaLimite
            WHERE tfechaInicio = @FECHA_INICIO
              AND tfechaFin = @FECHA_FIN
              AND bEliminado = 0
              AND id <> @Id
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe otro rango de fechas igual.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Actualizar
        UPDATE dbo.FechaLimite
        SET
            tfechaInicio = @FECHA_INICIO,
            tfechaFin = @FECHA_FIN,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @Id;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @State = -1;
            SET @Message = 'No se realizó ninguna actualización.';
            SET @CodeError = 0;
            RETURN;
        END

        SET @State = 1;
        SET @Message = 'Fecha límite actualizada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO