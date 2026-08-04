--==============================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertFechaFeriado]
-- Fecha:  29-09-2025
-- Descripcion: Procedimiento para crear un registro en Fecha feriado
--==============================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertFechaFeriado]
    @FERIADO INT,
    @ANIO INT,
    @FECHA DATE,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT,
    @Id INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS(SELECT 1
    FROM DenominacionFeriado
    WHERE id = @FERIADO)
    BEGIN
        SET @State = -1;
        SET @Message ='El ´id´ del feriado no es valido'
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM Sync_Anio
    WHERE id = @ANIO)
    BEGIN
        SET @State = -1;
        SET @Message = 'El ´id´ del año no es valido'
        RETURN;
    END

    INSERT INTO FechaFeriado (denominacionFeriadoId_fk, anioId_fk, fecha, nCreatedBy, tCreatedAt)
    VALUES (@FERIADO,@ANIO,@FECHA,@USUARIO, GETDATE())
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Fecha feriado agregado correctamente'
        SET @State = 1
        SET @CodeError= 0
    END TRY
    BEGIN CATCH 
        SET @Id= 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = 0
    END CATCH
END
GO 