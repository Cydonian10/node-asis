/*======================================================================================================
NOMBRE: [dbo].[usp_actualizarJustificacion]
FECHA: 28-01-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Actualizar una justificación lógica en la tabla Justificacion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_actualizarJustificacion]
  @JUSTIFICACION_ID INT,
  @MOTIVO_ID INT,
  @DETALLE NVARCHAR(500),

  @USER_ID INT,
  @State INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE Justificacion
  SET 
      motivoId_fk = COALESCE(@MOTIVO_ID, motivoId_fk),
      cDetalle = COALESCE(@DETALLE, cDetalle),
      tUpdatedAt = GETDATE(),
      nUpdatedBy = @USER_ID
  WHERE id = @JUSTIFICACION_ID AND bEliminado = 0;
END