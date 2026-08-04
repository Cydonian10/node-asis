CREATE OR ALTER PROCEDURE [dbo].[sp_InsertMarcacionCita]
    @EMPLEADOID INT,
    @EMPLEADOCOD VARCHAR (10),
    @PUNCHTIME VARCHAR(50),
    @PUNCHSTATE VARCHAR(5),
    @TERMINALID INT = NULL,
    @TERMINALSN VARCHAR(250) = NULL,
    @TERMINALALIAS VARCHAR(250) = NULL,
    @USUARIO INT,
    @Id INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @FechaFinal DATETIME = CONVERT(DATETIME, @PUNCHTIME, 120);
        DECLARE @HorarioUsuarioId INT = NULL;
        DECLARE @CitaId INT = NULL;

        SELECT TOP 1  @HorarioUsuarioId = hu.id FROM HorarioUsuario hu
            INNER JOIN RolUsuario ru on ru.id = hu.rolUsuarioId_fk AND ru.bEliminado = 0
            INNER JOIN Sync_Usuario u on u.id = ru.usuarioId_fk 
        WHERE u.cDni = @EMPLEADOCOD and hu.bEliminado = 0
        
        SELECT TOP 1 @CitaId = id FROM Cita
            WHERE horarioUsuarioId_fk = @HorarioUsuarioId
              AND CAST(fecha AS DATE) = CAST(@FechaFinal AS DATE)
              AND bCancelado = 0

        IF @CitaId IS NOT NULL
        BEGIN
            UPDATE Cita SET marcacion = @PUNCHTIME 
            WHERE id = @CitaId;

            SET @Message = 'Marcación de cita registrada correctamente'
            SET @State = 1;            
            SET @Id = @CitaId;
            RETURN;
        END
           
        INSERT INTO Marcacion
            (emp_id, emp_code, punch_time, punch_state, terminal_sn, terminal_alias, terminal_id, nCreatedBy, tCreatedAt)
        VALUES
            (@EMPLEADOID, @EMPLEADOCOD, @FechaFinal, @PUNCHSTATE, @TERMINALSN, @TERMINALALIAS, @TERMINALID, @USUARIO, GETDATE())

        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Marcación registrada correctamente'
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
