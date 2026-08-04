SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControl]
FECHA: 18-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER  PROCEDURE [dbo].[usp_InsertControl]
    @TOLERANCIA INT,
    @LIMITE_FALTA INT,
    @LIMITE_MARCACION INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM Controles
        WHERE nTolerancia = @TOLERANCIA
            AND nLimiteFalta = @LIMITE_FALTA
            AND nLimiteMarcacion = @LIMITE_MARCACION
    )
    BEGIN
        SET @State = -1;
        SET @Message = 'Ya existe un registro con esos valores';
        SET @Id = 0;
        SET @CodeError = -1; 
        RETURN;
    END

    BEGIN TRY
        INSERT INTO [CONTROLES]
            ( nTolerancia, nLimiteFalta, nLimiteMarcacion, bEliminado, nCreatedBy, tCreatedAt )
        VALUES
            (  @TOLERANCIA, @LIMITE_FALTA, @LIMITE_MARCACION ,0, @USER, getdate());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Control insertado correctamente';
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
