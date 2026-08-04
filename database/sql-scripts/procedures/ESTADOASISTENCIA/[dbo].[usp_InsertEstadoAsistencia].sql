IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_InsertEstadoAsistencia'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_InsertEstadoAsistencia];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertEstadoAsistencia]
FECHA: 25-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar estado de asitencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertEstadoAsistencia] @NOMBRE CHAR(40)
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF (TRIM(ISNULL(@NOMBRE, '')) = '')
        BEGIN
            SET @State = - 2;
            SET @Message = 'El nombre no puede estar vacio';

            RETURN;
        END;

        IF LEFT(@NOMBRE, 1) = ' '
        BEGIN
            SET @State = - 3;
            SET @Message = 'El nombre no puede iniciar con espacio en blanco';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM EstadoAsistencia
                WHERE UPPER(cNombre) = UPPER(@NOMBRE)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El nombre ya exite en otro EstadoAsistencia'

            RETURN;
        END

        IF PATINDEX('%[^a-zA-ZÁÉÍÓÚáéíóúÑñ ]%', @NOMBRE) > 0
        BEGIN
            SET @State = - 5;
            SET @Message = 'No se permite ingresar numero, ni _, en el nombre'

            RETURN;
        END

        INSERT INTO EstadoAsistencia (
            cNombre
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @NOMBRE
            , @USER
            , GETDATE()
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


