--=================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertAsistenciaModificada]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para crear un registro de asistencia modificada 
-- a partir de:
-- 'Detalle biomtrico', 'Turno Modificado', 'Marcaciones' 'Asistencia'
--=================================================================================
CREATE OR ALTER PROCEDURE [dbo].[sp_InsertAsistenciaModificada]
    @DETALLEBIOMETRICOID INT,
    @TURNOMODIFICADOID INT,
    @MARCACIONID INT,
    @ASISTENCIAID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR (250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY 
   IF NOT EXISTS (SELECT 1
    FROM TurnoModificado
    WHERE id = @TURNOMODIFICADOID
        AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El turno modificado no valido'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM Asistencia
    WHERE id = @ASISTENCIAID
        AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'La asistencias no es valida'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM DetalleBiometrico
    WHERE id = @DETALLEBIOMETRICOID
        AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El ´id´ del Detalle Biometrico no es valida'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM Marcacion
    WHERE id = @MARCACIONID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El ´id´ de la marcacion no es valida'
        SET @CodeError = -1;
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM AsistenciaModificada
    WHERE marcacionId_fk= @MARCACIONID AND asistenciaId_fk = @ASISTENCIAID)
        BEGIN
            SET @State = -1;
            SET @Message = 'Los parámetros ya fueron ingresados'
            RETURN;
        END

    INSERT INTO AsistenciaModificada
        (detalleBiometricoId_fk, turnoModificadoId_fk, marcacionId_fk, asistenciaId_fk, nCreatedBy, tCreatedAt)
    VALUES(@DETALLEBIOMETRICOID, @TURNOMODIFICADOID, @MARCACIONID, @ASISTENCIAID, @USUARIO, GETDATE());

        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Asistencia Modificada creada correctamente'
        SET @CodeError = 0;
        SET @State = -1
    END TRY 
    BEGIN CATCH 
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
