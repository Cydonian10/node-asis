/*======================================================================================================
 NOMBRE: [dbo].[usp_CreateTurnoModificado]
 OBJETIVO: Crear una modificación de turno validando turno, usuario y unicidad activa.
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_CreateTurnoModificado]
    @TurnoId INT,
    @UsuarioId INT,
    @Fecha DATE,
    @HoraInicio TIME,
    @HoraFin TIME,
    @Motivo VARCHAR(255) = NULL,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        SET @Id = NULL;

        IF NOT EXISTS (
            SELECT 1
            FROM Turno
            WHERE TurnoId = @TurnoId
                AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM Usuario
            WHERE UsuarioId = @UsuarioId
                AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El usuario no existe';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1
            FROM TurnoModificado
            WHERE TurnoId = @TurnoId
                AND UsuarioId = @UsuarioId
                AND Fecha = @Fecha
                AND Eliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una modificación activa para el usuario y fecha indicados';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO TurnoModificado
        (
            TurnoId,
            UsuarioId,
            Fecha,
            HoraInicio,
            HoraFin,
            Motivo,
            CreatedBy,
            UpdatedBy
        )
        VALUES
        (
            @TurnoId,
            @UsuarioId,
            @Fecha,
            @HoraInicio,
            @HoraFin,
            @Motivo,
            @USER,
            @USER
        );

        SET @Id = CONVERT(INT, SCOPE_IDENTITY());
        SET @State = 1;
        SET @Message = 'Modificación de turno creada correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
