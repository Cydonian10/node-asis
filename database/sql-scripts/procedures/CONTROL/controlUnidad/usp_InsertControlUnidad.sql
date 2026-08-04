SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControlUnidad]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar control para unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER PROCEDURE [dbo].[usp_InsertControlUnidad]
    @UNIDAD_ID INT,
    @CONTROL_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
    --     IF EXISTS ( SELECT 1
    -- FROM ControlUnidad
    -- WHERE controlId_fk = @CONTROL_ID AND unidadId_fk = @UNIDAD_ID AND bEliminado = 0 )
    --     BEGIN
    --     SET @State = -1;
    --     SET @Message = 'Ya existe una relación entre este Control y esta Unidad.';
    --     SET @CodeError = -1;
    --     RETURN;
    -- END

        INSERT INTO API_SCAP_DB.dbo.ControlUnidad
        (controlId_fk, unidadId_fk, bEliminado, nCreatedBy, tCreatedAt)
    VALUES(@CONTROL_ID, @UNIDAD_ID, 0, @USER, GETDATE());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'ControlUnidad registrado correctamente.';
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
