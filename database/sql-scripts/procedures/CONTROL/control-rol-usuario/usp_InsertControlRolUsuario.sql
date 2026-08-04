SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControlRolUsuario]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar un registro en la tabla ControlRolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
ALTER   PROCEDURE [dbo].[usp_InsertControlRolUsuario]
    @ROL_USUARIO_ID INT,
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
            FROM ControlRolUsuario
            WHERE controlId_fk = @CONTROL_ID
            AND rolUsuarioId_fk = @ROL_USUARIO_ID
            AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una relación entre este Control y este RolUsuario.';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO API_SCAP_DB.dbo.ControlRolUsuario
          (controlId_fk, rolUsuarioId_fk, bEliminado, nCreatedBy, tCreatedAt)
        VALUES(@CONTROL_ID, @ROL_USUARIO_ID, 0, @USER, GETDATE());


        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'ControlRolUsuario registrado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @Id = -1;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
