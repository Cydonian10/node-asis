/*======================================================================================================
NOMBRE: [dbo].[usp_eliminarJustificacion]
FECHA: 08-01-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Eliminar una justificación lógica en la tabla Justificacion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_eliminarJustificacion]
  @JUSTIFICACION_ID INT,
  @USER_ID INT,
  @State INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE Justificacion
  SET bEliminado = 1,
      tUpdatedAt = GETDATE(),
      nUpdatedBy = @USER_ID
  WHERE id = @JUSTIFICACION_ID AND bEliminado = 0;
END