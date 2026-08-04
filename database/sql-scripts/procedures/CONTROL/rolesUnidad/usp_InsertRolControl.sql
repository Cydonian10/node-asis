SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertRolControl]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar un registro en la tabla RolControl

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertRolControl]
    @ROL_ID INT,
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

        IF EXISTS (
            SELECT 1 
            FROM RolControl 
            WHERE rolId_fk = @ROL_ID 
              AND controlId_fk = @CONTROL_ID
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe un registro con este Rol y Control.';
            SET @CodeError = -1; 
            RETURN;
        END


        INSERT INTO RolControl
            (rolId_fk, controlId_fk, bEliminado, nCreatedby, tCreatedAt)
        VALUES
            (@ROL_ID, @CONTROL_ID, 0, @USER, GETDATE());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'RolControl registrado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
