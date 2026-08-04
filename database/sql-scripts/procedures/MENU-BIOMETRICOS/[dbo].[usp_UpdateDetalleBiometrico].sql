IF EXISTS (
        SELECT *
        FROM INFORMATION_SCHEMA.ROUTINES
        WHERE SPECIFIC_SCHEMA = N'dbo'
            AND SPECIFIC_NAME = N'usp_UpdateDetalleBiometrico'
            AND ROUTINE_TYPE = N'PROCEDURE'
        )
    DROP PROCEDURE [dbo].[usp_UpdateDetalleBiometrico]
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateDetalleBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite ctualizar un detalle biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE PROCEDURE [dbo].[usp_UpdateDetalleBiometrico] @ID INT
    , @NOMBRE VARCHAR(50) = NULL
    , @IP CHAR(50) = NULL
    , @SERIE VARCHAR(50) = NULL
    , @UBICACION VARCHAR(100) = NULL
    , @HUELLA BIT
    , @ROSTRO BIT
    , @TARJETA BIT
    , @USER INT
    , @State INT OUTPUT
    , @Message NVARCHAR(200) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El detalleBiométrico no existe o está eliminado';

            RETURN;
        END;

        IF (
                (
                    @NOMBRE IS NOT NULL
                    AND LTRIM(RTRIM(@NOMBRE)) <> ''
                    AND LEFT(@NOMBRE, 1) IN (' ', '-', '_')
                    )
                OR (
                    @IP IS NOT NULL
                    AND LTRIM(RTRIM(@IP)) <> ''
                    AND LEFT(@IP, 1) IN (' ', '-', '_')
                    )
                OR (
                    @SERIE IS NOT NULL
                    AND LTRIM(RTRIM(@SERIE)) <> ''
                    AND LEFT(@SERIE, 1) IN (' ', '-', '_')
                    )
                OR (
                    @UBICACION IS NOT NULL
                    AND LTRIM(RTRIM(@UBICACION)) <> ''
                    AND LEFT(@UBICACION, 1) IN (' ', '-', '_')
                    )
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'Los campos no deben iniciar con espacio, "-" ni "_".';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(cNombre) = UPPER(@NOMBRE)
                    AND UPPER(ip) = UPPER(@IP)
                    AND UPPER(serie) = UPPER(@SERIE)
                    AND UPPER(ubicacion) = UPPER(@UBICACION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Ya existe un detalle con el misma nombre, IP, Serie y ubicación';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(ip) = UPPER(@IP)
                    AND UPPER(serie) = UPPER(@SERIE)
                    AND UPPER(ubicacion) = UPPER(@UBICACION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Ya existe un detalle con el mismo IP, Serie y ubicación';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(serie) = UPPER(@SERIE)
                    AND UPPER(ubicacion) = UPPER(@UBICACION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'Ya existe un detalle con el mismo Serie y ubicación';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(cNombre) = UPPER(@NOMBRE)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya existe un detalle con el mismo nombre';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(ip) = UPPER(@IP)
                    AND id <> @id
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'La IP ya está registrada en otro detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(serie) = UPPER(@SERIE)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'La Serie ya está registrada en otro detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(ubicacion) = UPPER(@UBICACION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Ya existe un detalle en la misma ubicación.';

            RETURN;
        END;

        UPDATE DetalleBiometrico
        SET cNombre = COALESCE(NULLIF(@NOMBRE, ''), cNombre)
            , ip = COALESCE(NULLIF(@IP, ''), ip)
            , serie = COALESCE(NULLIF(@SERIE, ''), serie)
            , ubicacion = COALESCE(NULLIF(@UBICACION, ''), ubicacion)
            , bHuella = @HUELLA
            , bRostro = @ROSTRO
            , bTarjeta = @TARJETA
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se actualizó ningún registro.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO


