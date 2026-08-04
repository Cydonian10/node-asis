SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertAsistenciaExtendida]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertAsistenciaExtendida] @IDTURNO INT
    , @IDASISTENCIA INT
    , @IDMARCACION INT
    , @IDDBIOMETRICO INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @IDTURNO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El turno no existe o está inactivo.';

            RETURN;
        END

        IF NOT EXISTS (
                SELECT 1
                FROM Asistencia
                WHERE id = @IDASISTENCIA
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'La asistencia no existe o está inactiva.';

            RETURN;
        END

        IF NOT EXISTS (
                SELECT 1
                FROM Marcacion
                WHERE id = @IDMARCACION
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'La marcación no existe o está inactiva.';

            RETURN;
        END

        IF NOT EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE id = @IDDBIOMETRICO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El detalle biométrico no existe o está inactivo.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM AsistenciaExtendida
                WHERE turnoExtendidoId_fk = @IDTURNO
                    AND asistenciaId_fk = @IDASISTENCIA
                    AND detalleBiometricoId_fk = @IDDBIOMETRICO
                    AND marcacionId_fk = @IDMARCACION
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'Ya existe un registro con los mismos datos.';

            RETURN;
        END

        INSERT INTO AsistenciaExtendida (
            turnoExtendidoId_fk
            , asistenciaId_fk
            , detalleBiometricoId_fk
            , marcacionId_fk
            , nCreatedBy
            )
        VALUES (
            @IDTURNO
            , @IDASISTENCIA
            , @IDDBIOMETRICO
            , @IDMARCACION
            , @USER
            )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
