SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para crear un registro de marcacion
-- Parámetros: 'EMPLEADOID','EMPLEADOCOD','PUNCHSTATE', 'TERMINALID'
-- 'TERMINALSN', 'TERMINALALIAS'
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_InsertMarcacion]
    @EMPLEADOID INT,
    @EMPLEADOCOD VARCHAR (10),
    @PUNCHSTATE VARCHAR(250),
    @TERMINALID INT,
    @TERMINALSN VARCHAR(250),
    @TERMINALALIAS VARCHAR(250),
    @USUARIO INT,
    @Id INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
BEGIN TRY
    IF NULLIF(LTRIM(RTRIM(@TERMINALSN)), '') IS NULL
    BEGIN
        SET @Message = 'no se permite registrar espacios en blanco'
        SET @CodeError = -1;
        RETURN;
    END
    IF NULLIF(LTRIM(RTRIM(@TERMINALALIAS)), '') IS NULL
    BEGIN
        SET @Message = 'no se permite registrar espacios en blanco en el alias'
        SET @CodeError = -1;
        RETURN;
    END
    INSERT INTO Marcacion
        (emp_id, emp_code, punch_time, punch_state, terminal_sn, terminal_alias, terminal_id, nCreatedBy, tCreatedAt)
    VALUES
        ( @EMPLEADOID, @EMPLEADOCOD, GETDATE(), @PUNCHSTATE, @TERMINALSN, @TERMINALALIAS, @TERMINALID, @USUARIO, GETDATE())
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Marcación registrada correctamente'
        RETURN;
    END TRY
    BEGIN CATCH
        SET @Id = 0
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
