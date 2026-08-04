IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_InsertBiometrico'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_InsertBiometrico];
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite realizar el registro un nuevo biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_InsertBiometrico] @MARCA VARCHAR(100)
    , @TIPOBD VARCHAR(50)
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF (LTRIM(RTRIM(ISNULL(@MARCA, ''))) = '')
        BEGIN
            SET @State = - 2;
            SET @Message = 'La marca no puede estar vacía.';

            RETURN;
        END;

        IF (LTRIM(RTRIM(ISNULL(@TIPOBD, ''))) = '')
        BEGIN
            SET @State = - 3;
            SET @Message = 'El tipoBD no puede estar vacío.';

            RETURN;
        END;

        IF (
                LEFT(@MARCA, 1) IN (' ', '-', '_')
                OR LEFT(@TIPOBD, 1) IN (' ', '-', '_')
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Los campos no deben iniciar con epacio, "-" ni "_".';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(marca) = UPPER(@MARCA)
                    AND UPPER(tipoBD) = UPPER(@TIPOBD)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'El biométrico ya existe.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(marca) = UPPER(@MARCA)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6
            SET @Message = 'Ya existe, un registro de la marca'

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(tipoBD) = UPPER(@TIPOBD)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7
            SET @Message = 'Ya existe, un registro del TipoBD'

            RETURN;
        END

        INSERT INTO Biometrico (
            marca
            , tipoBD
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @MARCA
            , @TIPOBD
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();
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
END;
GO


