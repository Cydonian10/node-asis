IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_InsertUnidad'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_InsertUnidad]
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertUnidad]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear unidad que se va supervisaar en el sistema

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
01   22/11/2025  FLUNA      Modificar @SYNC_UNIDAD_ID de INT a CHAR(3)
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertUnidad]
    @SYNC_UNIDAD_ID CHAR(3),
    @HORA_ESTANDAR INT,
    @HORA_TOTAL INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- VALIDAR SI EXISTE LA SYNC_UNIDAD_ID EN UNIDAD POR QUE ES UNA RELACION UNO A UNO
        IF EXISTS (SELECT 1 FROM API_SCAP_DB.dbo.Unidad WHERE unidadOrgId_fk = @SYNC_UNIDAD_ID AND bEliminado = 0)
        BEGIN
            SET @Id = 0;
            SET @State = 0;
            SET @Message = 'La unidad con SyncUnidadId ' + CAST(@SYNC_UNIDAD_ID AS VARCHAR(10)) + ' ya existe.';
            SET @CodeError = 1;
            RETURN;
        END

        INSERT INTO API_SCAP_DB.dbo.Unidad
            (unidadOrgId_fk, horaEstandar, horaTotal, bEliminado, nCreatedBy, tCreatedAt)
        VALUES
            (@SYNC_UNIDAD_ID, @HORA_ESTANDAR, @HORA_TOTAL, 0, @USER, GETDATE());
        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Unidad creada correctamente.';
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
