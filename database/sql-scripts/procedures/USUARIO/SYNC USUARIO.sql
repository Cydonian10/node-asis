CREATE TABLE Sync_UsuarioPersona
(
    id INT PRIMARY KEY NOT NULL,
    cUsuario VARCHAR(255) NOT NULL,
    cNombre VARCHAR(255) NOT NULL,
    cApellido VARCHAR(255) NOT NULL,
    cDni VARCHAR(20) NOT NULL,
    cTipo CHAR(2) NOT NULL
)

GO
-- DROP TABLE Sync_UsuarioPersona
GO
SELECT *
FROM Sync_UsuarioPersona
GO
CREATE OR ALTER PROCEDURE usp_InsertSyncUsuarioPersona
    @IDUSUARIO INT,
    @USUARIO VARCHAR(255),
    @NOMBRE VARCHAR(255),
    @APELLIDO VARCHAR(255),
    @DNI VARCHAR(20),
    @TIPO CHAR(2),
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY
    IF EXISTS(SELECT 1
    FROM Sync_UsuarioPersona
    WHERE id = @IDUSUARIO OR cNombre = @USUARIO)
    BEGIN
        SET @State = -1;
        SET @Message = 'Ya existe el usuario';
        SET @CodeError = -1;
        RETURN;
    END

    INSERT INTO Sync_UsuarioPersona
        (id, cUsuario, cNombre, cApellido,cDni,cTipo)
    VALUES
        (@IDUSUARIO, @USUARIO, @NOMBRE, @APELLIDO, @DNI, @TIPO)

    SET @Id = @IDUSUARIO;
    SET @Message = 'Usuario creado correctamente';
    SET @CodeError = 0;
    SET @State = 1;

    END TRY
    BEGIN CATCH    
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END

GO

CREATE OR ALTER PROCEDURE usp_UpdateSyncUsuarioPersona
    @IDUSUARIO INT,
    @USUARIO VARCHAR(255),
    @NOMBRE VARCHAR(255),
    @APELLIDO VARCHAR(255),
    @DNI VARCHAR(20),
    @TIPO CHAR(2),
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS(SELECT 1
    FROM Sync_UsuarioPersona
    WHERE id = @IDUSUARIO)
    BEGIN
        SET @State = -1;
        SET @Message = 'El usuario no existe';
        SET @CodeError = -1;
        RETURN;
    END

    UPDATE Sync_UsuarioPersona
    SET cUsuario=@USUARIO, cNombre = @NOMBRE, cApellido = @APELLIDO, cTipo = @TIPO, cDni = @DNI
    WHERE id = @IDUSUARIO

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

CREATE OR ALTER PROCEDURE usp_DeleteSyncUsuarioPersona
    @ID INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS(SELECT 1
    FROM Sync_UsuarioPersona
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'El usuario no existe';
        SET @CodeError = -1;
        RETURN;
    END

    DELETE Sync_UsuarioPersona
    WHERE id = @ID

    SET @State = 0;
    SET @Message = 'Usuario eliminado correctamente';
    SET @CodeError = 0;
    END TRY
    BEGIN CATCH    
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END