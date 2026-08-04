SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_CrearAsistencia]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear un registro de asistencia en base al horario asignado y al rol del usuario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_CrearAsistencia]
    @ROL_USUARIO_ID INT, -- o deberia pasara usuarioHorarioId
    @HORARIO_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @InsertedIds TABLE (id INT);
    BEGIN TRY
        WITH Numerados AS (
                SELECT 
                    d.cTitulo AS Dia,
                    tr.horaInicio,
                    ROW_NUMBER() OVER (PARTITION BY d.cTitulo ORDER BY tr.orden) AS rn
                FROM TurnoRegular tr
                INNER JOIN HorarioDias hd ON hd.id = tr.horarioDiasId_fk
                INNER JOIN Dia d ON d.id = hd.diaId_fk
                WHERE hd.horarioId_fk = @HORARIO_ID AND d.cTitulo = FORMAT(GETDATE(), 'dddd', 'es-ES')
            )
            INSERT INTO Asistencia (tFecha, horaEntrada, horaSalida, rolUsuarioid_fk, nCreatedBy, tCreatedAt)
            OUTPUT INSERTED.id INTO @InsertedIds
            SELECT 
                DISTINCT
                CAST(GETDATE() AS DATE),
                CAST(CAST(GETDATE() AS DATE) AS DATETIME) + CAST(n1.horaInicio AS DATETIME) AS horaEntrada,
                CAST(CAST(GETDATE() AS DATE) AS DATETIME) + CAST(n2.horaInicio AS DATETIME) AS horaSalida,
                @ROL_USUARIO_ID,
                @USER,
                GETDATE()
            FROM Numerados n1
            JOIN Numerados n2 
                ON n1.rn = n2.rn - 1  -- emparejar consecutivos
            WHERE n1.rn % 2 = 1;
        
        SELECT TOP 1 @Id = id FROM @InsertedIds ORDER BY id DESC;
        SET @State = 1;
        SET @Message = 'Asistencia creada exitosamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
