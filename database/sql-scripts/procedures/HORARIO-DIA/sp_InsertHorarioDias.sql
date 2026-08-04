--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertHorioDias]
-- Fecha:  17-09-2025
-- Descripcion: Procedimiento para crear un horariodia, una relacion entre horario y día 
-- Parámetros:
-- 'HORARIOID: Es id de un horario dia existente 
-- 'DIAID: Es el id dia '
-- 'LIBRE: es el estado que define si un dia es libre dentro del horario dia
--  valor por defecto 0 '
--- Fecha Modificacion: 09-01-2026
--- Descripcion: despues de crear el horario dia se agregara automaticamente la vigencia
--=========================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertHorarioDias]
    @HORARIOID INT,
    @DIAID INT,
    @USUARIO INT,
    @LIBRE BIT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS(SELECT 1
    FROM Dia
    WHERE id = @DIAID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET @Message = 'El dia no es valido';
        SET @CodeError = -1;
        RETURN;
    END

        IF NOT EXISTS (SELECT 1
    FROM Horario
    WHERE id = @HORARIOID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET @Message = 'El horario no es valido';
        SET @CodeError = -1;
        RETURN;
    END

    --     IF EXISTS (SELECT 1
    -- FROM HorarioDias
    -- WHERE diaId_fk = @DIAID AND horarioId_fk = @HORARIOID AND bEliminado = 0)
    --     BEGIN
    --     SET @State = -1;
    --     SET @Message = 'El dia ya fue ingresado para el mismo horario';
    --     RETURN;
    -- END
        
        INSERT INTO HorarioDias
        (horarioId_fk, diaId_fk, bLibre, nCreatedBy, tCreatedAt)
    VALUES
        (@HORARIOID, @DIAID, @LIBRE, @USUARIO, GETDATE());

        SET @Id = SCOPE_IDENTITY(); 

        --- Agrega la vigencia 
    --     INSERT INTO Vigencia
    --     (tFechaInicio, tFechaFin, horarioDiasId_fk, bEliminado, nCreatedBy, tCreatedAt, bTipo)
    -- SELECT TOP 1
    --     v.tFechaInicio,
    --     v.tFechaFin,
    --     @Id,
    --     0,
    --     @USUARIO,
    --     GETDATE(),
    --     0
    -- FROM Vigencia v
    --     INNER JOIN HorarioDias hd ON v.horarioDiasId_fk = hd.id
    --   --  INNER JOIN FechaLimite fl ON v.fechaLimiteId_pk = fl.id
    -- WHERE hd.horarioId_fk = @HORARIOID
    --     AND v.bTipo = 0
    --     AND v.bEliminado = 0
    -- ORDER BY v.tfechaFin DESC; 

        SET @Message = 'Dia creado correctamente';
        SET @CodeError = 0;
        SET @State = 1;

    END TRY
    BEGIN CATCH 
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO