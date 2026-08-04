/*======================================================================================================
NOMBRE: [dbo].[usp_getControlPorRolUsuarioId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Reprocesar asistencia de usuarios en el sistema.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE OR ALTER PROCEDURE [dbo].[usp_getControlPorRolUsuarioId]
  @ROL_USUARIO_ID INT
AS
BEGIN
  DECLARE @ROL_ID INT;
  DECLARE @CONTROL_ID INT = NULL;
  DECLARE @TABLA VARCHAR(100);
  DECLARE @TABLA_ID INT;

  SELECT @ROL_ID = r.id
  FROM RolUsuario ru
    JOIN Rol r ON r.id = ru.rolId_fk
  WHERE ru.id = @ROL_USUARIO_ID;

  -- 1) RolControl (mayor prioridad)
  IF EXISTS (SELECT 1
  FROM RolControl rc
  WHERE rc.rolId_fk = @ROL_ID)
        BEGIN
    SELECT TOP 1
      @CONTROL_ID = rc.controlId_fk, @TABLA = 'RolControl', @TABLA_ID = rc.id
    FROM RolControl rc
    WHERE rc.rolId_fk = @ROL_ID;
  END
        ELSE IF EXISTS (
          SELECT 1
  FROM ControlRolUsuario cru
    JOIN RolUsuario ru ON ru.id = cru.rolUsuarioId_fk
  WHERE ru.rolId_fk = @ROL_ID
        )
        BEGIN
    SELECT TOP 1
      @CONTROL_ID = cru.controlId_fk, @TABLA = 'ControlRolUsuario', @TABLA_ID = cru.id
    FROM ControlRolUsuario cru
      JOIN RolUsuario ru ON ru.id = cru.rolUsuarioId_fk
    WHERE ru.rolId_fk = @ROL_ID;
  END
        ELSE IF EXISTS (
          SELECT 1
  FROM ControlUnidad cu
    JOIN Unidad u ON u.id = cu.unidadId_fk
    JOIN Rol r ON r.unidadId_fk = u.id
  WHERE r.id = @ROL_ID
        )
        BEGIN
    SELECT TOP 1
      @CONTROL_ID = cu.controlId_fk , @TABLA = 'ControlUnidad', @TABLA_ID = cu.id
    FROM ControlUnidad cu
      JOIN Unidad u ON u.id = cu.unidadId_fk
      JOIN Rol r ON r.unidadId_fk = u.id
    WHERE r.id = @ROL_ID;
  END

  SELECT
    Id id,
    nTolerancia tolerancia,
    nLimiteFalta limiteFalta,
    nLimiteMarcacion limiteMarcacion,
    @TABLA as fuente,
    @TABLA_ID as fuenteId
  FROM Controles
  WHERE id = @CONTROL_ID;
END
