SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControlRolUsuarioAsistencia]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar asistencia con que estado esta y que control se utlizo

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertControlRolUsuarioAsistencia]
    @CONTROL_ROL_USUARIO_ID INT,
    @ASISTENCIA_ID INT,
    @ESTADO_ASISTENCIA_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ControlRolUsuario WHERE id = @CONTROL_ROL_USUARIO_ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El ControlRolUsuario no existe o está eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Asistencia WHERE id = @ASISTENCIA_ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'La asistenciaId no existe o está eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM EstadoAsistencia WHERE id = @ESTADO_ASISTENCIA_ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El estadoAsistenciaId no existe o está eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM ControlRolUsuarioAsistencia
            WHERE asistenciaId_fk = @ASISTENCIA_ID AND controlRolUsuarioId_fk = @CONTROL_ROL_USUARIO_ID
                AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una relación activa entre la asistencia y el controlRolUsuario en [ControlRolUsuarioAsistencia].';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO ControlRolUsuarioAsistencia
            (controlRolUsuarioId_fk, asistenciaId_fk, estadoAsistenciaId_fk, bEliminado, nCreatedBy, tCreatedAt )
        VALUES(@CONTROL_ROL_USUARIO_ID, @ASISTENCIA_ID, @ESTADO_ASISTENCIA_ID, 0, @USER, GETDATE());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'ControlRolUsuarioAsistencia registrada correctamente.';
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
