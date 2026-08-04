/*======================================================================================================
NOMBRE: [dbo].[usp_insertAsistenciaRegular]
FECHA: 20/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Insertar un registro de asistencia regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_insertAsistenciaRegular]
  @TURNO_REGULAR_ID INT,
  @ASISTENCIA_ID INT,
  @MARCACION_ID INT,
  @DETALLE_BIOMETRICO_ID INT,
  @Id INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @State INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO AsistenciaRegular
    (
    turnoRegularId_fk,
    asistenciaId_fk,
    marcacionId_fk,
    detalleBiometricoId_fk,
    bEliminado,
    nCreatedBy,
    tCreatedAt)
  VALUES
    (
      @TURNO_REGULAR_ID,
      @ASISTENCIA_ID,
      @MARCACION_ID,
      @DETALLE_BIOMETRICO_ID,
      0,
      1,
      GETDATE()
  );

  SET @Id = SCOPE_IDENTITY();
  SET @Message = 'Asistencia Regular insertada correctamente';
  SET @State = 1;
END


