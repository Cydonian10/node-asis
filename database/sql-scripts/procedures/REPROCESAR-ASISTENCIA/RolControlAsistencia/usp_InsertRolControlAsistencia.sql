-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
-- /*======================================================================================================
-- NOMBRE: [dbo].[usp_InsertRolControlAsistencia]
-- FECHA: 25-09-2025
-- AUTOR: Gabriel Vásquez Uscuvilca
-- OBJETIVO: Insertar asistencia con que estado esta y que control se utlizo

-- MODIFICACIONES:
-- NRO  FECHA       USUARIO    MODIFICACION
--  -     -            -            - 
-- ======================================================================================================*/
-- CREATE OR ALTER PROCEDURE [dbo].[usp_InsertRolControlAsistencia]
--     @ROL_CONTROL_ID INT,
--     @ASISTENCIA_ID INT,
--     @ESTADO_ASISTENCIA_ID INT,
--     @USER INT,

--     @State INT OUTPUT,
--     @Message VARCHAR (255) OUTPUT,
--     @Id INT OUTPUT,
--     @CodeError INT OUTPUT
-- AS
-- BEGIN
--     SET NOCOUNT ON;

--     BEGIN TRY

--         -- Validar existencia
--         IF NOT EXISTS (SELECT 1
--     FROM RolControl
--     WHERE id = @ROL_CONTROL_ID AND bEliminado = 0)
--                 BEGIN
--         SET @State = -1;
--         SET @Message = 'El RolControl no existe o está eliminado.';
--         SET @CodeError = -1;
--         SET @Id = 0;
--         RETURN;
--     END

--         IF NOT EXISTS (SELECT 1
--     FROM Asistencia
--     WHERE id = @ASISTENCIA_ID AND bEliminado = 0)
--         BEGIN
--         SET @State = -1;
--         SET @Message = 'La asistenciaId no existe o está eliminado.';
--         SET @CodeError = 50001;
--         RETURN;
--     END

--         IF NOT EXISTS (SELECT 1
--     FROM EstadoAsistencia
--     WHERE id = @ESTADO_ASISTENCIA_ID AND bEliminado = 0)
--         BEGIN
--         SET @State = -1;
--         SET @Message = 'El estadoAsistenciaId no existe o está eliminado.';
--         SET @CodeError = 50001;
--         RETURN;
--     END
        
--         IF EXISTS (
--             SELECT 1
--     FROM RolControlAsistencia
--     WHERE asistenciaId_fk = @ASISTENCIA_ID
--         AND bEliminado = 0
--         )
--         BEGIN
--         SET @State = -1;
--         SET @Message = 'Ya existe un registro asistencia para [RolControlAsistencia].';
--         SET @CodeError = -1;
--         RETURN;
--     END

--         -- Insertar
--         INSERT INTO RolControlAsistencia
--         (rolControlId_fk, asistenciaId_fk, estadoAsistenciaId_fk, bEliminado, nCreatedBy, tCreatedAt )
--     VALUES(@ROL_CONTROL_ID, @ASISTENCIA_ID, @ESTADO_ASISTENCIA_ID, 0, @USER, GETDATE());

--         SET @Id = SCOPE_IDENTITY();
--         SET @State = 1;
--         SET @Message = 'RolControlAsistencia registrada correctamente.';
--         SET @CodeError = 0;

--     END TRY
--     BEGIN CATCH
--         SET @Id = 0;
--         SET @State = -1;
--         SET @Message = ERROR_MESSAGE();
--         SET @CodeError = ERROR_NUMBER();
--     END CATCH
-- END
-- GO
