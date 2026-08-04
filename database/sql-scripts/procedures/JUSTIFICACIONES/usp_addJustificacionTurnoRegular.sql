/*======================================================================================================
NOMBRE: [dbo].[usp_addJustificacionTurnoRegular]
FECHA: 28/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Agregar registros a la tabla JustificacionTurnoRegular


MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_addJustificacionTurnoRegular]
  @ROL_USUARIO_ID INT,
  @MOTIVO_ID INT,
  @FECHA DATE,
  @DETALLE NVARCHAR(500),
  @USER_ID INT,
  @TURNO_ID INT,

  @Id INT OUTPUT,
  @State INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @JustificacionId INT;

  INSERT INTO Justificacion
    (fecha, motivoId_fk, rolUsuarioId_fk, cDetalle, bEliminado, nCreatedBy, tCreatedAt)
  VALUES
    (@FECHA, @MOTIVO_ID, @ROL_USUARIO_ID, @DETALLE, 0, @USER_ID, GETDATE());

  SET @JustificacionId = SCOPE_IDENTITY();

  INSERT INTO JustificacionTurnoRegular
    (justificacionId_fk, turnoRegularId_fk, bEliminado, nCreatedBy, tCreatedAt)
  VALUES
    (@JustificacionId, @TURNO_ID , 0, @USER_ID, GETDATE());

  SET @State = 1;
  SET @Message = 'Justificación de turno regular agregada exitosamente.';
  SET @CodeError = 0;
  SET @Id = SCOPE_IDENTITY();

END
