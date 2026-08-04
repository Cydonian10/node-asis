--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertTurnoModificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para crear un registro de turno Modificado 
--=======================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertTurnoModificado]
    @IDROLUSUARIO INT = NULL,
    @IDTURNO INT,
    @HORA TIME(7),
    @TIPO  BIT,
    @FECHAINICIO DATE,
    @FECHAFIN DATE,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT

AS 
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS (
        SELECT 1
    FROM TurnoRegular
    WHERE id = @IDTURNO AND bEliminado = 0
    )
    BEGIN
        SET @State = -1;
        SET @Message = 'El Turno no es valido'
        SET @CodeError = -1;
        RETURN;
    END
    -- IF NOT EXISTS (
    --     SELECT 1
    -- FROM RolUsuario
    -- WHERE (@IDROLUSUARIO IS NULL OR id = @IDROLUSUARIO) AND bEliminado = 0
    -- )
    -- BEGIN 
    --     SET @State = -1;
    --     SET @Message = 'El RolUsuario no es valido'
    --     SET @CodeError =-1;
    --     RETURN;
    -- END
    IF EXISTS(
        SELECT 1 
        FROM Vigencia 
        WHERE horarioDiasId_fk = (SELECT horarioDiasId_fk FROM TurnoRegular WHERE id = @IDTURNO AND bEliminado = 0)
        AND bEliminado = 0
        AND  ((
        @FECHAINICIO < @FECHAFIN AND
              (
                @FECHAINICIO < tFechaInicio 
                AND @FECHAFIN > tfechaFin
              )
        ))
    )
    BEGIN
        SET @State = -1;
        SET @Message = 'El rago de fechas no se encuentra dentro de periodo vigente'
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM TurnoModificado 
    WHERE (turnoRegularId_fk = @IDTURNO) AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El turno ya fue modificado'
        RETURN;
    END
    INSERT INTO TurnoModificado
        (rolUsuarioId_fk, turnoRegularId_fk, tHora, btipo, fechaInicio, fechaFin, nCreatedBy, tCreatedAt)
    VALUES
        (@IDROLUSUARIO, @IDTURNO, @HORA, 0, @FECHAINICIO, @FECHAFIN, @USUARIO, GETDATE())
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Turno modificado creado correctamente'
        SET @CodeError = 0
    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE()
        SET @CodeError = ERROR_NUMBER()
        SET @State = -1;
    END CATCH
END
GO