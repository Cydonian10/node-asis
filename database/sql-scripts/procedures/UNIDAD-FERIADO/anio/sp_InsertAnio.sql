CREATE OR ALTER PROCEDURE [dbo].[sp_InsertAnio]
    @DENOMINACION INT,
    @DESCRIPCION VARCHAR(250),
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT 
AS 
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY
    IF EXISTS (SELECT 1 
    FROM Sync_Anio
    WHERE cDenominacion = @DENOMINACION)
    BEGIN 
         SET @State =-1;
         SET @Message = 'Ya existe un año con esta denomminación'
         RETURN;
    END
    IF NULLIF(LTRIM(RTRIM( @DENOMINACION)), '') IS NULL
    BEGIN 
        SET @Message = 'no se permite espcios en blanco'
        RETURN;
    END
    IF @DESCRIPCION IS NOT NULL
    BEGIN
        SET @DESCRIPCION = LTRIM(RTRIM(@DESCRIPCION))
        IF @DESCRIPCION = ''
        IF NOT @DESCRIPCION LIKE '%[a-zA-Z]%'
        BEGIN
            SET @Message  = 'debe de ingresar solo letras, no se admiten espacios en blancos o números'
            RETURN;
        END
    END 
    INSERT INTO Sync_Anio (cDenominacion, cDescripcion)
    VALUES (@DENOMINACION,@DESCRIPCION)
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Año creado correctamente'
        SET @CodeError = 0;
        SET @State = 1;
    END TRY
    BEGIN CATCH
        SET @Id = 0
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
