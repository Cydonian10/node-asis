/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateUsuario]
FECHA: 05-08-2026
AUTOR: Gabriel
OBJETIVO: Actualizar activo y/o las filas de UsuarioArea de un usuario (modelo multi-area).
          - @Activo -> Usuario.
          - @UsuarioAreaId + @AreaId / @EsSupervisor -> UsuarioArea (si cambia el area, debe ser de
            la MISMA unidad del area actual de esa fila, regla "un area por unidad").
          Actualiza solo las columnas enviadas (ISNULL sobre la columna actual).

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
  1  13-08-2026  Gabriel    Modelo multi-area: activo en Usuario; area/supervisor en UsuarioArea.
=====================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_UpdateUsuario]
    -- Parametros de entrada
    @ID INT,
    @Activo BIT = NULL,
    @UsuarioAreaId INT = NULL,
    @AreaId INT = NULL,
    @EsSupervisor BIT = NULL,
    @USER INT,

    -- Salidas
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM Usuario WHERE UsuarioId = @ID AND Eliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El usuario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF @Activo IS NOT NULL
        BEGIN
            UPDATE Usuario
            SET Active = @Activo,
                UpdatedAt = GETDATE()
            WHERE UsuarioId = @ID;
        END

        IF @UsuarioAreaId IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM UsuarioArea
                WHERE UsuarioAreaId = @UsuarioAreaId AND UsuarioId = @ID AND Eliminado = 0
            )
            BEGIN
                SET @State = -1;
                SET @Message = 'La asignacion de area del usuario no existe';
                SET @CodeError = -1;
                RETURN;
            END

            IF @AreaId IS NOT NULL
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM Area WHERE AreaId = @AreaId AND Eliminado = 0)
                BEGIN
                    SET @State = -1;
                    SET @Message = 'El area no existe';
                    SET @CodeError = -1;
                    RETURN;
                END

                -- El area nueva debe pertenecer a la misma unidad del area actual de esa fila
                IF NOT EXISTS (
                    SELECT 1
                    FROM UsuarioArea UA
                    INNER JOIN Area A1 ON A1.AreaId = UA.AreaId
                    INNER JOIN Area A2 ON A2.AreaId = @AreaId
                    WHERE UA.UsuarioAreaId = @UsuarioAreaId
                      AND A1.UnidadId = A2.UnidadId
                )
                BEGIN
                    SET @State = -1;
                    SET @Message = 'El area debe pertenecer a la misma unidad';
                    SET @CodeError = -1;
                    RETURN;
                END
            END

            UPDATE UsuarioArea
            SET AreaId = ISNULL(@AreaId, AreaId),
                EsSupervisor = ISNULL(@EsSupervisor, EsSupervisor),
                UpdatedAt = GETDATE()
            WHERE UsuarioAreaId = @UsuarioAreaId;
        END
        ELSE IF @AreaId IS NOT NULL OR @EsSupervisor IS NOT NULL
        BEGIN
            SET @State = -1;
            SET @Message = 'UsuarioAreaId es requerido para cambiar el area o esSupervisor';
            SET @CodeError = -1;
            RETURN;
        END

        SET @State = 1;
        SET @Message = 'Usuario actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
