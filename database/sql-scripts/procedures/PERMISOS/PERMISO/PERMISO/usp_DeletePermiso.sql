SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_DeletePermiso]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar un permiso (lógicamente)

MODIFICACIONES:
NRO   FECHA       USUARIO   MODIFICACION
 -       -          -           - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_DeletePermiso] @ID INT
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
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o fue eliminado';

            RETURN;
        END
        IF EXISTS (
                SELECT 1
                FROM PermisoTurnoRegular
                WHERE permisoId_pk = @ID
                ) 
            OR EXISTS (
                SELECT 1
                FROM PermisoTurnoExtendido
                WHERE permisoId_pk = @ID

                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El permiso está en uso y no se puede eliminar';

            RETURN;
        END

        UPDATE Permiso
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

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
END
GO
