/*======================================================================================================
NOMBRE: [dbo].[usp_insertMarcacionAsistenciaExtendida]
FECHA: 13-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar una marcación y su correspondiente asistencia extendida.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_insertMarcacionAsistenciaExtendida]
  @ASISTENCIA_ID INT,
  @TURNO_EXTENDIDO_ID INT,
  @FECHA_ASISTENCIA VARCHAR(10),
  @HORA_ENTRADA VARCHAR(8)
AS
 
BEGIN
    -- Primero crear la marcación con status SIN-REGISTRAR y la hora correcta
    DECLARE @MarcacionId INT;
    DECLARE @PunchTime DATETIME;
    
    -- Combinar fecha de asistencia con hora
    SET @PunchTime = CAST(@FECHA_ASISTENCIA + ' ' + @HORA_ENTRADA AS DATETIME);
    
    INSERT INTO Marcacion 
      (emp_code, punch_time, punch_state, terminal_sn, terminal_alias, emp_id, terminal_id, nCreatedBy)
    VALUES
      (0, @PunchTime, 0, 'SIN-REGISTRAR', 'SIN-REGISTRAR', 1, 1, 0);
    
    SET @MarcacionId = SCOPE_IDENTITY();

    -- Luego crear la asistencia extendida con la marcacion creada
    INSERT INTO AsistenciaExtendida 
      (turnoExtendidoId_fk, asistenciaId_fk, marcacionId_fk, detalleBiometricoId_fk, nCreatedBy)  
    VALUES
      (@TURNO_EXTENDIDO_ID, @ASISTENCIA_ID, @MarcacionId, 1, 0);
      
    SELECT @MarcacionId AS Id;
END