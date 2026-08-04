SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertAsistenciaRegular]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertAsistenciaRegular]
    @IDTURNO INT
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
                FROM TurnoRegular
                WHERE id = @IDTURNO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El turno no existe o está eliminado.';

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
            SET @Message = 'La asistencia no existe o está eliminada.';

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
            SET @Message = 'La marcación no existe o está eliminada.';

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
            SET @Message = 'El detalle biométrico no existe o está eliminado.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM AsistenciaRegular
                WHERE turnoRegularId_fk = @IDTURNO
                    AND asistenciaId_fk = @IDASISTENCIA
                    AND marcacionId_fk = @IDMARCACION
                    AND detalleBiometricoId_fk = @IDDBIOMETRICO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'Ya existe un registro con estos datos.';

            RETURN;
        END

        INSERT INTO AsistenciaRegular (
            turnoRegularId_fk
            , asistenciaId_fk
            , marcacionId_fk
            , detalleBiometricoId_fk
            , nCreatedBy
            )
        VALUES (
            @IDTURNO
            , @IDASISTENCIA
            , @IDMARCACION
            , @IDDBIOMETRICO
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
