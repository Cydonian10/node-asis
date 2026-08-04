IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'sp_InsertCita'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[sp_InsertCita];
GO

/*======================================================================================================
NOMBRE: [dbo].[sp_InsertCitas]
FECHA: 26-09-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: Procedimiento para crear una cita a partir de un Horario Usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[sp_InsertCita] @IDHORARIOUSUARIO INT
    , @NOMBRE VARCHAR(250)
    , @DESCRIPCION VARCHAR(250)
    , @FECHA DATE
    , @HORA TIME
    , @USUARIO INT
    , @State INT OUTPUT
    , @Message VARCHAR(250) OUTPUT
    , @CodeError INT OUTPUT
    , @Id INT OUTPUT
AS
BEGIN
    SET NOCOUNT
        , XACT_ABORT ON;

    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM HorarioUsuario
                WHERE id = @IDHORARIOUSUARIO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El horario de usuario no es válido o fue eliminado.';

            RETURN;
        END;

        IF NULLIF(LTRIM(RTRIM(@NOMBRE)), '') IS NULL
        BEGIN
            SET @State = - 3;
            SET @Message = 'El nombre no puede estar vacío.';

            RETURN;
        END;

        IF NULLIF(LTRIM(RTRIM(@DESCRIPCION)), '') IS NULL
        BEGIN
            SET @State = - 4;
            SET @Message = 'La descripción no puede estar vacío.';

            RETURN;
        END;

        IF @FECHA IS NULL
        BEGIN
            SET @State = - 5;
            SET @Message = 'La fecha de la cita es obligatoria.';

            RETURN;
        END;

        IF @HORA IS NULL
            OR FORMAT(@HORA, 'HH:mm') = '00:00'
        BEGIN
            SET @State = - 6;
            SET @Message = 'Debe ingresar una hora válida distinta de 00:00.';

            RETURN;
        END;

        IF LEFT(@NOMBRE, 1) IN (' ', '-', '_')
            OR LEFT(@DESCRIPCION, 1) IN (' ', '-', '_')
        BEGIN
            SET @State = - 7;
            SET @Message = 'El nombre y la descripción no deben iniciar con espacio, "-" ni "_".';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE fecha = @FECHA
                    AND hora = @HORA
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'Ya existe una cita, registrada en la misma fecha y hora.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(nombre) = UPPER(@NOMBRE)
                    AND UPPER(cDescripcion) = UPPER(@DESCRIPCION)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'Ya existe una cita con el mismo nombre y descripción.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(nombre) = UPPER(@NOMBRE)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Ya existe una cita con el mismo nombre y descripción.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(cDescripcion) = UPPER(@DESCRIPCION)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 11;
            SET @Message = 'Ya existe una cita con el mismo nombre y descripción.';

            RETURN;
        END;

        INSERT INTO Cita (
            horarioUsuarioId_fk
            , nombre
            , cDescripcion
            , fecha
            , hora
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @IDHORARIOUSUARIO
            , @NOMBRE
            , @DESCRIPCION
            , @FECHA
            , @HORA
            , @USUARIO
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
        SET @Id = 0
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = - 1;
    END CATCH
END
GO


