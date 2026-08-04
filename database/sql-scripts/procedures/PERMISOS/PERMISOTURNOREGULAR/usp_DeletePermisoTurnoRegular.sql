/*======================================================================================================
NOMBRE: [dbo].[usp_DeletePermisoTurnoRegular]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar el registro de un permisoTurnoRegular

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_DeletePermisoTurnoRegular] @PERMISOID INT
    , @TURNOID INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoRegular
                WHERE id = @TURNOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El turnoRegular no existe o está eliminado.';

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
        FROM PermisoTurnoRegular
        WHERE permisoId_pk = @PERMISOID
            AND turnoRegularId_pk = @TURNOID;

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
    END CATCH
END;
GO