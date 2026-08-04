/*======================================================================================================
NOMBRE: [dbo].[usp_InsertPermisoTurnoExtendido]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Inserta un turno extendido asociado a un permiso.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertPermisoTurnoExtendido] 
      @PERMISOID INT
    , @TURNOID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @PERMISOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @TURNOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El turno extendido no existe o fue eliminado.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM PermisoTurnoExtendido
                WHERE permisoId_pk = @PERMISOID
                    AND turnoExtendidoId_pk = @TURNOID
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Ya existe un registro con el permiso y turnoExtendido.';

            RETURN;
        END;

        INSERT INTO PermisoTurnoExtendido (
            permisoId_pk
            , turnoExtendidoId_pk
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @PERMISOID
            , @TURNOID
            , @USER
            , GETDATE()
            );

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se insertó el registro.';
        END;
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO
