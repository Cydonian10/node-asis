/*======================================================================================================
NOMBRE: [dbo].[usp_DeletePermisoTurnoExtendidor]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar el registro de un permisoTurnoExtendido.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeletePermisoTurnoExtendido] @PERMISOID INT
    , @TURNOID INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @TURNOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El turnoExtendido no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @PERMISOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM PermisoTurnoRegular
                WHERE permisoId_pk = @PERMISOID
                    AND turnoRegularId_pk = @TURNOID
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'No existe el registro a eliminar.';

            RETURN;
        END;

        DELETE
        FROM PermisoTurnoExtendido
        WHERE permisoId_pk = @PERMISOID
            AND turnoExtendidoId_pk = @TURNOID;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la eliminación';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END;
GO
