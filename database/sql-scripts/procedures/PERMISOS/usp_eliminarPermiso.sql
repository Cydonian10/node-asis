/*======================================================================================================
NOMBRE: [dbo].[usp_eliminarPermiso]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Eliminar un permiso lógico en la tabla Permiso

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_eliminarPermiso]
  @PERMISO_ID INT,
  @USER_ID INT,

  @State INT OUTPUT,
  @Message VARCHAR (255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE Permiso
  SET bEliminado = 1,
      tUpdatedAt = GETDATE(),
      nUpdatedBy = @USER_ID
  WHERE id = @PERMISO_ID
    AND bEliminado = 0;

  SET @State = 1;
  SET @Message = 'Permiso eliminado exitosamente.';
  SET @CodeError = 0;
END

GO


