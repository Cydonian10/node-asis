/*======================================================================================================
NOMBRE: [dbo].[usp_InsertPermiso]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite realizar el Registro de un nuevo  permiso

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_InsertPermiso] 
     @ROLUSUARIOID INT
    , @MOTIVOID INT
    , @FECHA DATE
    , @HORASALIDA TIME
    , @HORARETORNOESTIMADO TIME
    , @HORARETORNOREAL TIME
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROLUSUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El rolUsuario no existe o fue eliminado';

            RETURN;
        END

        IF NOT EXISTS (
                SELECT 1
                FROM Motivo
                WHERE id = @MOTIVOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El motivo no existe o fue eliminado';

            RETURN;
        END

        IF (
                @FECHA IS NULL
                OR @HORASALIDA IS NULL
                OR @HORARETORNOESTIMADO IS NULL
                OR @HORARETORNOREAL IS NULL
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'La fecha y horas no pueden ser nulas.';

            RETURN;
        END;

        IF (
                @HORASALIDA = '00:00'
                OR @HORARETORNOESTIMADO = '00:00'
                OR @HORARETORNOREAL = '00:00'
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Las horas no pueden ser 00:00.';

            RETURN;
        END;

        INSERT INTO Permiso (
            rolUsuarioId_fk
            , motivoId_fk
            , tfecha
            , tHoraSalida
            , tHoraRetornoEstimado
            , tHoraRetornoReal
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @ROLUSUARIOID
            , @MOTIVOID
            , @FECHA
            , @HORASALIDA
            , @HORARETORNOESTIMADO
            , @HORARETORNOREAL
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO