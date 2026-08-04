/*======================================================================================================
NOMBRE: [dbo].[usp_addPermisosRegular]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Agregar registros a la tabla PermisoRegular

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_addPermisosRegular]
  @ROL_USUARIO_ID INT,
  @MOTIVO_ID INT,
  @FECHA DATE,
  @HORA_SALIDA TIME,
  @HORA_RETORNO_ESTIMADO TIME,
  @HORA_RETORNO_REAL TIME = NULL,
  @TURNO_REGULAR_ID INT,
  @USER_ID INT,

  @State INT OUTPUT,
  @Message VARCHAR (255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @PERMISO_ID INT;

  INSERT INTO Permiso
    (rolUsuarioId_fk, motivoId_fk, tfecha, tHoraSalida, tHoraRetornoEstimado, tHoraRetornoReal, nCreatedBy)
  VALUES
    (@ROL_USUARIO_ID, @MOTIVO_ID, @FECHA, @HORA_SALIDA, @HORA_RETORNO_ESTIMADO, @HORA_RETORNO_REAL, @USER_ID);

  SET @PERMISO_ID = SCOPE_IDENTITY();

  INSERT INTO PermisoTurnoRegular
    (permisoId_pk, turnoRegularId_pk, nCreatedBy)
  VALUES
    (@PERMISO_ID, @TURNO_REGULAR_ID, @USER_ID);

  SET @State = 1;
  SET @Message = 'Permiso con turno regular agregado exitosamente.';
  SET @CodeError = 0;
END

-- GO
-- DECLARE @State INT,
--         @Message VARCHAR(255),
--         @CodeError INT;

-- EXEC dbo.usp_addPermisosRegular
--   @ROL_USUARIO_ID = 1,
--   @MOTIVO_ID = 1,
--   @FECHA = '2025-09-30',
--   @HORA_SALIDA = '08:00:00',
--   @HORA_RETORNO_ESTIMADO = '17:00:00',
--   @HORA_RETORNO_REAL = '16:45:00',
--   @TURNO_REGULAR_ID = 1,
--   @USER_ID = 1,
--   @State = @State OUTPUT,
--   @Message = @Message OUTPUT,
--   @CodeError = @CodeError OUTPUT;
-- GO
