/*======================================================================================================
NOMBRE: [dbo].[getUltimasCitas]
FECHA: 13-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite listar las últimas citas registradas.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
1     16-02-2026   Gabriel       Convertir campos TIME a VARCHAR para evitar incluir la fecha predeterminada.
======================================================================================================*/
CREATE   PROCEDURE [dbo].[getUltimasCitas]
  @FECHA_DESDE DATE ,
  @FECHA_HASTA DATE = NULL,
  @UNIDAD_ID INT
AS
BEGIN

  IF @FECHA_HASTA IS NULL
  BEGIN
    SET @FECHA_HASTA = GETDATE();
  END

  SELECT
    c.id,
    c.nombre,
    u.cDni AS dni,
    c.cDescripcion,
    c.fecha,
    CONVERT(VARCHAR(8), c.hora, 108) AS hora,
    CONVERT(VARCHAR(8), c.horaMarcacion, 108) AS horaMarcacion,
    u.cNombre AS nombreUsuario,
    u.cApellido AS apellidoUsuario,
    r.cTitulo AS rolUsuario,
    h.cTitulo AS tituloHorario
  FROM Cita c
    INNER JOIN HorarioUsuario hu ON c.horarioUsuarioId_fk = hu.id
    INNER JOIN Horario h ON hu.horarioId_fk = h.id
    INNER JOIN RolUsuario ru ON hu.rolUsuarioId_fk = ru.id
    INNER JOIN Sync_Usuario u ON ru.usuarioId_fk = u.id
    INNER JOIN Rol r ON ru.rolId_fk = r.id
  WHERE c.bEliminado = 0
    AND c.fecha >= @FECHA_DESDE
    AND c.fecha <= @FECHA_HASTA
    AND r.unidadId_fk = @UNIDAD_ID
    AND c.bCancelado = 0
  ORDER BY c.fecha DESC, c.hora DESC;
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[getUsuariosPorHorarioCitaId]
FECHA: 13-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener usuarios que tengan un horario específico para una cita.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
-      -             -           -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[getUsuariosPorHorarioCitaId]
  @HORARIO_ID INT,
  @UNIDAD_ID INT

AS
BEGIN


  -- Consulta principal
  SELECT
    u.id,
    u.cNombre AS nombre,
    u.cApellido AS apellido,
    u.cDni AS dni,
    u.cTipo AS tipo,
    r.cTitulo AS rol,
    ru.id AS rolUsuarioId,
    r.unidadId_fk AS unidadId,
    hu.horarioId_fk AS horarioId,
    hu.id AS horarioUsuarioId
  FROM Sync_Usuario u
    INNER JOIN RolUsuario ru on ru.usuarioId_fk = u.id
    INNER JOIN Rol r ON ru.rolId_fk = r.id
    INNER JOIN HorarioUsuario hu ON ru.id = hu.rolUsuarioId_fk
  WHERE hu.horarioId_fk = @HORARIO_ID AND r.unidadId_fk = @UNIDAD_ID
  GROUP BY u.id, u.cNombre, u.cApellido, u.cDni, u.cTipo, r.cTitulo, ru.id, r.unidadId_fk, hu.horarioId_fk, hu.id;
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[getUsuariosWithHorarioId]
FECHA: 13-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los usuarios con su respectivo horario si tiene el horario o no.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
-      -             -           -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[getUsuariosWithHorarioId]
  @ID_HORARIO INT,
  @UNIDAD_ID INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    ru.id,
    u.cNombre AS nombre,
    u.cApellido AS apellido,
    r.cTitulo AS rol,
    u.cDni AS dni,
    MAX(CASE 
      WHEN h.id = @ID_HORARIO THEN 1 
      ELSE 0 
    END) AS tieneHorario
  FROM Sync_Usuario u
    INNER JOIN RolUsuario ru ON ru.usuarioId_fk = u.id
    INNER JOIN Rol r ON r.id = ru.rolId_fk
    LEFT JOIN HorarioUsuario hu ON ru.id = hu.rolUsuarioId_fk
    LEFT JOIN Horario h ON hu.horarioId_fk = h.id AND h.id = @ID_HORARIO
  WHERE (@UNIDAD_ID IS NULL OR r.unidadId_fk = @UNIDAD_ID)
  GROUP BY ru.id, u.cNombre, u.cApellido, r.cTitulo, u.cDni;
END
GO
 
--=================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre:  [dbo].[sp_DeleteAsistenciaModificada]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para eliminar un registro de asistencia modificada 
--=================================================================================
CREATE   PROCEDURE [dbo].[sp_DeleteAsistenciaModificada]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT, 
    @CodeError  INT OUTPUT

AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM AsistenciaModificada 
    WHERE id = @ID )
    BEGIN
        SET @State = -1;
        SET @Message = 'no se encontro la asistencia Modificada'
        SET @CodeError = -1;
        RETURN;
    END 
    UPDATE AsistenciaModificada 
        SET bEliminado = 1,
            tUpdatedAt = GETDATE(),
            nUpdatedBy = @USUARIO
        WHERE id = @ID
        SET @State = 0;
        SET @Message = 'Asistencia eliminado Correctamente'
        SET @codeError = 0
    END TRY 
    BEGIN CATCH
        SET @state = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--==============================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteFechaFeriado]
-- Fecha:  06-10-2025
-- Descripcion: Procedimiento para eliminar un registro de Fecha feriado
--==============================================================================
CREATE   PROCEDURE [dbo].[sp_DeleteFechaFeriado]
    @ID INT,
    @USUARIO INT,
    @Message VARCHAR (250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM FechaFeriado
    WHERE id = @ID AND bEliminado = 0 )
    BEGIN
        SET @State = -1;
        SET @Message = 'id no valido'
        RETURN;
    END
   UPDATE FechaFeriado
   SET bEliminado = 1 
   WHERE id = @ID
   
   IF EXISTS (SELECT 1 
   FROM UnidadFeriado 
   WHERE fechaFeriadoId_pk = @ID)
   BEGIN
      DELETE uf
      FROM UnidadFeriado AS uf
      INNER JOIN FechaFeriado AS ff ON uf.fechaFeriadoId_pk = ff.id
      
    END

    SET @State = 1;
    SET @Message = 'Fecha ferido eliminado correctamente'
    SET @CodeError = 0;

    END TRY 
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteFeriado]
-- Fecha:  06-09-2025
-- Descripcion: Procedimiento para eliminar de forma logica los datos de denominacion de feriado 
-- Parámetros:
-- ID: El ID de un registro de la tabla DenominacionFeriado (int)
-- USUARIO: Id del usuario que realiza la elimincion (int)
--=========================================================================================
CREATE   PROCEDURE[dbo].[sp_DeleteFeriados]
    @ID INT,
    @USUARIO INT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY 
    IF NOT EXISTS ( SELECT 1
    FROM DenominacionFeriado 
    WHERE id = @ID AND bEliminado = 0)
    BEGIN 
        SET @State = -1;
        SET @Message = 'El feriado no es valido o fue eliminado'
        RETURN;
    END
    
    IF EXISTS (SELECT 1
    FROM FechaFeriado
    WHERE denominacionFeriadoId_fk = @ID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El feriado esta en uso'
        RETURN;
    END

    UPDATE DenominacionFeriado 
        SET bEliminado = 1,
            nUpdatedBy = @USUARIO,
            tUpdatedAt = GETDATE()
        WHERE id = @ID
        SET @State = 1
        SET @Message = 'Eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteHorarioDias]
-- Fecha:  17-09-2025
-- Descripcion: El procedimiento elimina un registro de horariodia
-- si el hoarioDia se esta usando en otras tablas no se podra eliminar
--=========================================================================================
CREATE    PROCEDURE [dbo].[sp_DeleteHorarioDias]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT,
    @Message VARCHAR (250) OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS (SELECT 1
    FROM HorarioDias
    WHERE Id = @ID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'Horario-Dia no encontrado'
        SET @CodeError = -1;
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM TurnoExtendido
    WHERE HorarioDiasId_fk = @ID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'Horario dia en uso dentro de Turno extendido'
        SET @CodeError = -1;
        RETURN;
    END
    IF EXISTS ( SELECT 1
    FROM TurnoRegular
    WHERE HorarioDiasID_fk = @ID AND bEliminado = 0)
    BEGIN
        SET @State = -1
        SET @Message = 'Horario dia en uso dentro de un Turno Regular'
        SET @CodeError = -1;
        RETURN;
    END
     -- Si existen vigencia relacionado, marcarlos como eliminados
        IF EXISTS (
            SELECT 1
    FROM vigencia
    WHERE HorarioDiasId_fk = @ID
        )
        BEGIN
        UPDATE vigencia
            SET bEliminado = 1
            WHERE HorarioDiasId_fk = @ID;
    END


    UPDATE HorarioDias
        SET bEliminado = 1
        WHERE id = @ID
        SET @State = 0;
        SET @Message = 'Horario-Dia eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para eliminar un registro de marcacion
-- Parámetros: 'ID' 'USUARIO'
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_DeleteMarcacion]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR (250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM Marcacion
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'marcacion no encontrada'
        SET @CodeError = -1;
        RETURN;
    END 
    IF EXISTS(SELECT 1
    FROM AsistenciaRegular
    WHERE marcacionId_fk = @ID )
    BEGIN
        SET @State = -1;
        SET @Message = 'La marcacion se esta registrando en Asistencia Regular'
        SET @CodeError = -1;
        RETURN;
    END 
    IF EXISTS(SELECT 1
    FROM AsistenciaExtendida
    WHERE marcacionId_fk = @ID )
    BEGIN
        SET @State = -1;
        SET @Message = 'La marcacion se esta registrando en Asistencia Extendida'
        SET @CodeError = -1;
        RETURN;
    END

    UPDATE Marcacion
        SET nUpdatedBy = @USUARIO,
            tUpdateAt = GETDATE(),
            bEliminado = 1
        WHERE id = @ID
        SET @State = 0;
        SET @Message = 'Marcacion eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteMotivo]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para Eliminar de forma logica un registro de Motivo
-- Parámetros: 'ID', 'USUARIO'
-- bElimado: valor por defecto 0, al realizarse una eliminacion el valor cambia a 1 
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_DeleteMotivo]
    @ID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS(SELECT 1
    FROM Motivo
    WHERE id = @ID)
    BEGIN
        SET @state = -1;
        SET @Message = 'Motivo no encontrado'
        SET @CodeError = -1;
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM Permiso
    WHERE motivoId_fk = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'se esta usando el motivo en un permiso'
        SET @CodeError = -1;
        RETURN;
    END
    
    IF EXISTS (SELECT 1
    FROM Licencia 
    WHERE motivoId_fk = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'El motivo se esta usado en una licencia'
        SET @CodeError = -1;
        RETURN;
    END

    IF EXISTS (SELECT 1
    FROM Justificacion 
    WHERE motivoId_fk = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'El motivo se esta usando en una Justificacion'
        SET @CodeError = -1;
        RETURN;
    END

    UPDATE Motivo 
        SET nUpdatedBy = @USUARIO,
            tUpdatedAt = GETDATE(),
            bEliminado = 1
        WHERE id = @ID

        SET @State = 0;
        SET @Message = 'eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH 
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_DeleteTurnoModificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para Eliminar de forma logica un registro de turno Modificado
-- Parámetros: 'ID', 'USUARIO'
-- bElimado: valor por defecto 0, al realizarse una eliminacion el valor cambia a 1 
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_DeleteTurnoModificado]
    @ID INT,
    @USUARIO INT OUTPUT,
    @State INT OUTPUT,
    @Message VARCHAR (250) OUTPUT,
    @CodeError INT OUTPUT
AS 
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS (SELECT 1 
    FROM TurnoModificado
    WHERE id = @ID AND bEliminado = 0)
    BEGIN 
        SET @State = -1;
        SET @Message = 'Turno Modificado no encontrado'
        SET @CodeError = -1;
        RETURN;
    END 
    UPDATE TurnoModificado 
        SET bEliminado = 1,
            nUpdatedBy = @USUARIO,
            tUpdatedAt = GETDATE()
        WHERE id = @ID
        SET @State = 0;
        SET @Message = 'El turno modificado eliminado correctamente'
        SET @codeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
CREATE   PROCEDURE [dbo].[sp_GetAnio]

AS
BEGIN
    SELECT id, cDenominacion AS denominacion, cDescripcion AS descripcion
    FROM Sync_Anio
END
GO
 
 
--=================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetAsistenciaModificada]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros que 
-- no esten eliminados de asistencia modificada 
-- a partir de:
-- 'Detalle biomtrico', 'Turno Modificado', 'Marcaciones' 'Asistencia'
--=================================================================================
CREATE   PROCEDURE [dbo].[sp_GetAsistenciaModificada]

AS
BEGIN 
    SELECT am.id
    ,db.cNombre as biometrico
    ,db.ubicacion
    ,tm.tHora as hora
    ,tm.btipo as tipo
    ,a.tFecha as fecha
    ,m.id as idMarcacion
    ,U.cUsuario AS usuario
    ,U.cNombre AS nombre
    ,RU.usuarioId_fk AS id_usuario
    FROM AsistenciaModificada AS am
    INNER JOIN  DetalleBiometrico AS db ON am.detalleBiometricoId_fk = db.id
    INNER JOIN  TurnoModificado AS tm ON am.turnoModificadoId_fk = tm.id
    INNER JOIN  Asistencia AS a ON am.asistenciaId_fk = a.id
    INNER JOIN  Marcacion AS m ON am.marcacionId_fk = m.id
    INNER JOIN Sync_Usuario U ON M.emp_id = U.id
    INNER JOIN RolUsuario RU ON U.id = RU.usuarioId_fk
    WHERE am.bEliminado =  0;
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[sp_GetCita]
FECHA: 26-09-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: Procedimiento para mostrar todas las citas que fueron creadas

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
01   02-01-2026  FLUNA      Añadir alias
======================================================================================================*/
CREATE   PROCEDURE [dbo].[sp_GetCita]
AS
BEGIN
    SELECT c.id AS id
        , hu.id AS horarioUsuarioId
        , h.cTitulo AS horario
        , u.cUsuario AS usuario
        , c.nombre AS nombre
        , r.cTitulo AS rol
        , c.cDescripcion AS descripcion
        , CONVERT(VARCHAR(10), c.fecha, 120) AS fecha
        , CONVERT(CHAR(5), c.hora, 108) AS hora
        , cancelado = CASE 
            WHEN bCancelado = 1
                THEN 'SI'
            WHEN bCancelado = 0
                THEN 'NO'
            END
        , c.tCreatedAt AS fechaCreacion
    FROM Cita AS c
    INNER JOIN HorarioUsuario AS hu
        ON c.horarioUsuarioId_fk = hu.id
    INNER JOIN Horario AS h
        ON hu.horarioId_fk = h.id
    INNER JOIN RolUsuario AS ru
        ON hu.rolUsuarioId_fk = ru.id
    INNER JOIN Rol AS r
        ON ru.rolId_fk = r.id
    INNER JOIN Sync_Usuario AS u
        ON ru.usuarioId_fk = u.id
    WHERE c.bEliminado = 0
END
GO
 
--==============================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetFechaFeriado]
-- Fecha:  01-10-2025
-- Descripcion: Procedimiento para mostrar todos los registros de Fecha feriado

--==============================================================================
CREATE   PROCEDURE [dbo].[sp_GetFechaFeriado]

AS 
BEGIN
    SET NOCOUNT ON;

    SELECT f.id, df.cDenominacion AS feriado, f.fecha, a.cDenominacion AS anio
    FROM FechaFeriado AS f
    INNER JOIN Sync_Anio AS a ON f.anioId_fk = a.id
    INNER JOIN DenominacionFeriado AS df ON f.denominacionFeriadoId_fk = df.id 
    WHERE f.bEliminado = 0 
END
GO
 
--==============================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetFeriado]
-- Fecha:  27-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros de la tablas 
-- DenominacionFeriado
--==============================================================================
CREATE   PROCEDURE [dbo].[sp_GetFeriado]

AS
BEGIN
    SELECT id, codigo, cDenominacion AS denominacion, cDescripcion AS descripcion
    FROM DenominacionFeriado
    WHERE bEliminado = 0
END
GO
 
--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetHorarioDiasByHorarioId]
-- Fecha:  17-09-2025
-- Descripcion: Procedimiento para Mostrar un horariodia a partir del id
-- Parámetros:
-- 'HORARIOID: Es id de un horario dia existente 
-- 'MOSTRARTODO: estado para poder visualizar todos los registros de la tabla independiete
--  si tiene o no una vigencia asisgnada'
--=========================================================================================
CREATE    PROCEDURE [dbo].[sp_GetHorarioDiasByHorarioId]
    @IDHORARIO INT,
    @MOSTRARTODO BIT,
    @FECHA_INICIO DATE = NULL,
    @FECHA_FIN DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        hd.id AS horarioDiaId,
        h.id AS horarioId,
        h.cTitulo AS nombreHorario,
        d.cTitulo AS dia,
        d.id as diaId,
        h.horaDia as horarioDia,
        --CASE WHEN hd.bLibre = 1 THEN 'SI' ELSE 'NO' END AS libre,
        hd.bLibre AS libre,
        CAST(MAX(v.tfechaInicio) AS VARCHAR(10)) AS fechaInicio,
        CAST(MAX(v.tfechaFin) AS VARCHAR(10)) AS fechaFin
    FROM HorarioDias AS hd
        INNER JOIN Horario AS h ON hd.horarioId_fk = h.id
        INNER JOIN Dia AS d ON hd.diaId_fk = d.id
        LEFT JOIN Vigencia AS v ON v.horarioDiasId_fk = hd.id AND ISNULL(v.bEliminado, 0) = 0
    WHERE 
            hd.horarioId_fk = @IDHORARIO
        AND hd.bEliminado = 0

        AND (@FECHA_INICIO IS NULL OR v.tFechaInicio = @FECHA_INICIO) AND (@FECHA_FIN IS NULL OR v.tFechaFin = @FECHA_FIN) AND v.bActivo = 1
    GROUP BY hd.id, h.id, h.cTitulo, d.cTitulo, hd.bLibre, d.orden, d.id, h.horaDia, d.cTitulo
    ORDER BY d.orden ASC;
END
GO
 
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros de marcacion
-- Parámetros: 'EMPLEADOID','EMPLEADOCOD','PUNCHSTATE', 'TERMINALID'
-- 'TERMINALSN', 'TERMINALALIAS', TERMINALAlIAS
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_GetMarcacion]
AS
BEGIN
     SELECT M.id,
     emp_code AS Codigo_Empleado,
     U.cNombre AS nombre,
     u.cApellido as apellido,
     punch_time AS Tiempo_Marcacion,
     punch_state AS Estado_Marcacion,
     terminal_sn AS Numero_Serie,
     terminal_alias AS Nombre_Terminal,
     emp_id,
     terminal_id
     FROM Marcacion AS M
     INNER JOIN Sync_Usuario AS U ON M.emp_id = u.id 
      WHERE bEliminado = 0
      ORDER BY Tiempo_Marcacion DESC
END
GO
 

--==============================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetMotivo]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para mostrar todos los registro de Motivo que no esten eliminados
-- Parámetros: 'ID', NOMBRE', 'DETALLE', 'EN USO'
--==============================================================================================
CREATE   PROCEDURE [dbo].[sp_GetMotivo]
AS
BEGIN
    SELECT id, nombre, detalle,
        CASE 
        WHEN EXISTS( SELECT 1
        FROM Justificacion
        WHERE motivoId_fk = id AND bEliminado = 0) THEN 1
        WHEN EXISTS( SELECT 1
        FROM Permiso
        WHERE motivoId_fk = id AND bEliminado = 0) THEN 1
        WHEN EXISTS( SELECT 1
        FROM Licencia
        WHERE motivoId_fk = id AND bEliminado = 0) THEN 1
        ELSE 0
    END as uso,
        bDocumento as documento
    FROM Motivo
    WHERE bEliminado = 0
END
GO
 
 
/*======================================================================================================
NOMBRE: [dbo].[sp_GetOneCita]
FECHA: 26-09-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: Procedimiento para mostrar una cita por ID

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[sp_GetOneCita] @ID INT
AS
BEGIN
    SELECT c.id
        , hu.id
        , h.cTitulo
        , u.cUsuario
        , c.nombre
        , r.cTitulo
        , c.cDescripcion
        , CONVERT(VARCHAR(10), c.fecha, 120) AS fecha
        , hora
        , bCancelado = CASE 
            WHEN bCancelado = 1
                THEN 'SI'
            WHEN bCancelado = 0
                THEN 'NO'
            END
        , c.tCreatedAt AS fechaCreacion
    FROM Cita AS c
    INNER JOIN HorarioUsuario AS hu
        ON c.horarioUsuarioId_fk = hu.id
    INNER JOIN Horario AS h
        ON hu.horarioId_fk = h.id
    INNER JOIN RolUsuario AS ru
        ON hu.rolUsuarioId_fk = ru.id
    INNER JOIN Rol AS r
        ON ru.rolId_fk = r.id
    INNER JOIN Sync_Usuario AS u
        ON ru.usuarioId_fk = u.id
    WHERE c.id = @ID
        AND c.bEliminado = 0
END
GO
 

--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetOneMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para mostrar un registro de marcacion a partir de ID
-- Parámetros: 'EMPLEADOID','EMPLEADOCOD','PUNCHSTATE', 'TERMINALID'
-- 'TERMINALSN', 'TERMINALALIAS', TERMINALAlIAS
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_GetOneMarcacion]
    @ID INT
AS
BEGIN 
    SELECT id,
     emp_code AS codigoEmpleado,
     punch_time AS TiempoMarcacion,
     punch_state AS EstadoMarcacion,
     terminal_sn,
     terminal_alias,
     emp_id AS Id_Usuario,
     terminal_id
    FROM Marcacion 
    WHERE id = @ID AND bEliminado = 0
END
GO
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetOneTurnoModificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para mostrar un registro de turno Modificado
-- Parámetros: 'ID'
--=======================================================================================
CREATE  PROCEDURE [dbo].[sp_GetOneTurnoModificado]
@ID INT
AS
BEGIN
  SELECT tm.id,
    h.id as horarioId,
    d.cTitulo AS dia,
    usuario = CASE
        WHEN tm.rolUsuarioId_fk IS NULL THEN 'Todos los usuarios'
        ELSE CAST(tm.rolUsuarioId_fk AS varchar(10))
        END,
    tr.id as idTurno, tr.horaInicio,

    CAST(tm.tHora AS VARCHAR(8)) AS horaModificada,
    tipo = CASE
        WHEN tm.bTipo = 0 THEN 'Entrada'
        WHEN tm.bTipo = 1 THEN 'Salida'
    END,
    tm.fechaInicio, tm.fechaFin, tr.horarioDiasId_fk AS idHorarioDias,
    su.cNombre as nombre,
    su.cApellido as apellido,
    ru.id as idRolUsuario
  FROM TurnoModificado AS tm
    INNER JOIN TurnoRegular AS tr ON tm.turnoRegularId_fk = tr.id
    LEFT JOIN RolUsuario AS ru on tm.rolUsuarioId_fk = ru.id
    LEFT JOIN Sync_Usuario as su ON ru.usuarioId_fk = su.id
    INNER JOIN HorarioDias AS hd ON tr.horarioDiasId_fk = hd.id
    INNER JOIN Dia AS d ON hd.diaId_fk = d.id
    INNER JOIN Horario AS h ON hd.horarioId_fk = h.id

  WHERE tr.id = @ID AND tm.bEliminado = 0
END
GO
 
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetTurnoModfificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros de turno Modificado 
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_GetTurnoModfificado]
AS
BEGIN
    SELECT tm.id, usuario = CASE
        WHEN tm.rolUsuarioId_fk IS NULL THEN 'Todos los usuarios'
        ELSE CAST(tm.rolUsuarioId_fk AS varchar(10))
      
    END,
        tr.id as turnoRegularId,
        CAST(tr.horaInicio AS VARCHAR(5)) AS horaInicio,
        CAST(tm.tHora AS VARCHAR(5)) AS hora,
        tipo = CASE
        WHEN tm.bTipo = 0 THEN 'Entrada'
        WHEN tm.bTipo = 1 THEN 'Salida'
    END,
        tm.fechaInicio,
        tm.fechaFin,
        su.cNombre as nombre,
        su.cApellido as apellido,
        ru.id as idRolUsuario,
        d.cTitulo as dia,
        h.cTitulo as horario
    FROM TurnoModificado AS tm
        INNER JOIN TurnoRegular AS tr ON tm.turnoRegularId_fk = tr.id
        LEFT JOIN RolUsuario AS ru ON tm.rolUsuarioId_fk = ru.id
        LEFT JOIN Sync_Usuario as su ON ru.usuarioId_fk = su.id
        LEFT JOIN HorarioDias AS hd ON tr.horarioDiasId_fk = hd.id
        LEFT JOIN Dia AS d ON hd.diaId_fk = d.id
        LEFT JOIN Horario AS h ON hd.horarioId_fk = h.id
    WHERE tm.bEliminado = 0
    ORDER BY  tm.id DESC
END
GO
 

--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetUnidadFeriado]
-- Fecha:  02-10-2025
-- Descripcion: Procedimiento para mostrar todos los resgistros de Unidad Feriado 
--=======================================================================================

CREATE   PROCEDURE [dbo].[sp_GetUnidadFeriado]
  @UNIDADID INT

AS
BEGIN
    SET NOCOUNT ON; 
    
    SELECT su.cTitulo AS Unidad,df.cDenominacion AS Feriado, f.fecha
    FROM UnidadFeriado AS uf
    INNER JOIN Unidad AS u ON uf.unidadId_pk = u.id
    INNER JOIN Sync_Unidad AS su ON u.unidadOrgId_fk = su.id
    INNER JOIN FechaFeriado AS f ON uf.fechaFeriadoId_pk = f.id
    INNER JOIN DenominacionFeriado AS df ON f.denominacionFeriadoId_fk = df.id
    WHERE u.id = @UNIDADID

END
GO
 
CREATE   PROCEDURE [dbo].[sp_InsertAnio]
    @DENOMINACION INT,
    @DESCRIPCION VARCHAR(250),
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT 
AS 
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY
    IF EXISTS (SELECT 1 
    FROM Sync_Anio
    WHERE cDenominacion = @DENOMINACION)
    BEGIN 
         SET @State =-1;
         SET @Message = 'Ya existe un año con esta denomminación'
         RETURN;
    END
    IF NULLIF(LTRIM(RTRIM( @DENOMINACION)), '') IS NULL
    BEGIN 
        SET @Message = 'no se permite espcios en blanco'
        RETURN;
    END
    IF @DESCRIPCION IS NOT NULL
    BEGIN
        SET @DESCRIPCION = LTRIM(RTRIM(@DESCRIPCION))
        IF @DESCRIPCION = ''
        IF NOT @DESCRIPCION LIKE '%[a-zA-Z]%'
        BEGIN
            SET @Message  = 'debe de ingresar solo letras, no se admiten espacios en blancos o números'
            RETURN;
        END
    END 
    INSERT INTO Sync_Anio (cDenominacion, cDescripcion)
    VALUES (@DENOMINACION,@DESCRIPCION)
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Año creado correctamente'
        SET @CodeError = 0;
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
 
--=================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertAsistenciaModificada]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para crear un registro de asistencia modificada 
-- a partir de:
-- 'Detalle biomtrico', 'Turno Modificado', 'Marcaciones' 'Asistencia'
--=================================================================================
CREATE   PROCEDURE [dbo].[sp_InsertAsistenciaModificada]
    @DETALLEBIOMETRICOID INT,
    @TURNOMODIFICADOID INT,
    @MARCACIONID INT,
    @ASISTENCIAID INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR (250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY 
   IF NOT EXISTS (SELECT 1
    FROM TurnoModificado
    WHERE id = @TURNOMODIFICADOID
        AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El turno modificado no valido'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM Asistencia
    WHERE id = @ASISTENCIAID
        AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'La asistencias no es valida'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM DetalleBiometrico
    WHERE id = @DETALLEBIOMETRICOID
        AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El ´id´ del Detalle Biometrico no es valida'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM Marcacion
    WHERE id = @MARCACIONID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El ´id´ de la marcacion no es valida'
        SET @CodeError = -1;
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM AsistenciaModificada
    WHERE marcacionId_fk= @MARCACIONID AND asistenciaId_fk = @ASISTENCIAID)
        BEGIN
            SET @State = -1;
            SET @Message = 'Los parámetros ya fueron ingresados'
            RETURN;
        END

    INSERT INTO AsistenciaModificada
        (detalleBiometricoId_fk, turnoModificadoId_fk, marcacionId_fk, asistenciaId_fk, nCreatedBy, tCreatedAt)
    VALUES(@DETALLEBIOMETRICOID, @TURNOMODIFICADOID, @MARCACIONID, @ASISTENCIAID, @USUARIO, GETDATE());

        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Asistencia Modificada creada correctamente'
        SET @CodeError = 0;
        SET @State = -1
    END TRY 
    BEGIN CATCH 
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
 
 
/*======================================================================================================
NOMBRE: [dbo].[sp_InsertCitas]
FECHA: 26-09-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: Procedimiento para crear una cita a partir de un Horario Usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[sp_InsertCita] @IDHORARIOUSUARIO INT
    , @NOMBRE VARCHAR(250)
    , @DESCRIPCION VARCHAR(250)
    , @FECHA DATE
    , @HORA TIME
    , @USUARIO INT
    , @State INT OUTPUT
    , @Message VARCHAR(250) OUTPUT
    , @CodeError INT OUTPUT
    , @Id INT OUTPUT
AS
BEGIN
    SET NOCOUNT
        , XACT_ABORT ON;

    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM HorarioUsuario
                WHERE id = @IDHORARIOUSUARIO
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El horario de usuario no es válido o fue eliminado.';

            RETURN;
        END;

        IF NULLIF(LTRIM(RTRIM(@NOMBRE)), '') IS NULL
        BEGIN
            SET @State = - 3;
            SET @Message = 'El nombre no puede estar vacío.';

            RETURN;
        END;

        IF NULLIF(LTRIM(RTRIM(@DESCRIPCION)), '') IS NULL
        BEGIN
            SET @State = - 4;
            SET @Message = 'La descripción no puede estar vacío.';

            RETURN;
        END;

        IF @FECHA IS NULL
        BEGIN
            SET @State = - 5;
            SET @Message = 'La fecha de la cita es obligatoria.';

            RETURN;
        END;

        IF @HORA IS NULL
            OR FORMAT(@HORA, 'HH:mm') = '00:00'
        BEGIN
            SET @State = - 6;
            SET @Message = 'Debe ingresar una hora válida distinta de 00:00.';

            RETURN;
        END;

        IF LEFT(@NOMBRE, 1) IN (' ', '-', '_')
            OR LEFT(@DESCRIPCION, 1) IN (' ', '-', '_')
        BEGIN
            SET @State = - 7;
            SET @Message = 'El nombre y la descripción no deben iniciar con espacio, "-" ni "_".';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE fecha = @FECHA
                    AND hora = @HORA
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'Ya existe una cita, registrada en la misma fecha y hora.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(nombre) = UPPER(@NOMBRE)
                    AND UPPER(cDescripcion) = UPPER(@DESCRIPCION)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'Ya existe una cita con el mismo nombre y descripción.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(nombre) = UPPER(@NOMBRE)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Ya existe una cita con el mismo nombre y descripción.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(cDescripcion) = UPPER(@DESCRIPCION)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 11;
            SET @Message = 'Ya existe una cita con el mismo nombre y descripción.';

            RETURN;
        END;

        INSERT INTO Cita (
            horarioUsuarioId_fk
            , nombre
            , cDescripcion
       , fecha
            , hora
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @IDHORARIOUSUARIO
            , @NOMBRE
            , @DESCRIPCION
            , @FECHA
            , @HORA
            , @USUARIO
            , GETDATE()
            )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @Id = 0
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = - 1;
    END CATCH
END
GO
 
 
--==============================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertFechaFeriado]
-- Fecha:  29-09-2025
-- Descripcion: Procedimiento para crear un registro en Fecha feriado
--==============================================================================
CREATE   PROCEDURE [dbo].[sp_InsertFechaFeriado]
    @FERIADO INT,
    @ANIO INT,
    @FECHA DATE,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT,
    @Id INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS(SELECT 1
    FROM DenominacionFeriado
    WHERE id = @FERIADO)
    BEGIN
        SET @State = -1;
        SET @Message ='El ´id´ del feriado no es valido'
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM Sync_Anio
    WHERE id = @ANIO)
    BEGIN
        SET @State = -1;
        SET @Message = 'El ´id´ del año no es valido'
        RETURN;
    END

    INSERT INTO FechaFeriado (denominacionFeriadoId_fk, anioId_fk, fecha, nCreatedBy, tCreatedAt)
    VALUES (@FERIADO,@ANIO,@FECHA,@USUARIO, GETDATE())
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Fecha feriado agregado correctamente'
        SET @State = 1
        SET @CodeError= 0
    END TRY
    BEGIN CATCH 
        SET @Id= 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = 0
    END CATCH
END
GO
 
--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertFeriado]
-- Fecha:  27-09-2025
-- Descripcion: Procedimiento para crear una denominacion de feriado 
-- Parámetros:
-- 'CODIGO: Es el codigo que se le asigna al registro puede ser alfanumerico
-- 'DENOMINACION: Es el nombre que se le asigna al feriado'
-- 'DESCRIPCION: Es la descripcion que se le asigna al feriado este campo no es obligatorio'
--=========================================================================================
CREATE   PROCEDURE [dbo].[sp_InsertFeriado]
    @CODIGO CHAR(10),
    @DENOMINACION VARCHAR(250),
    @DESCRIPCION VARCHAR(250),
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT,
    @Id INT OUTPUT
AS
BEGIN 
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF EXISTS (SELECT 1
    FROM DenominacionFeriado
    WHERE cDenominacion = @DENOMINACION)
    BEGIN
        SET @State =-1;
        SET @Message ='Ya se registro un feriado con esta denominacion'
        RETURN;
    END
    IF NULLIF(LTRIM(RTRIM(@DENOMINACION)), '') IS NULL
        BEGIN 
            SET @Message = 'no se permite ingresar campos en blanco'
            RETURN;
        END
    INSERT INTO DenominacionFeriado (codigo, cDenominacion, cDescripcion, nCreatedBy, tCreatedAt)
    VALUES (@CODIGO, @DENOMINACION,@DESCRIPCION,@USUARIO, GETDATE());
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Feriado creado correctamente';
        SET @State = 1;
        SET @CodeError = 0
    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1
    END CATCH
END
GO
 
--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertHorioDias]
-- Fecha:  17-09-2025
-- Descripcion: Procedimiento para crear un horariodia, una relacion entre horario y día 
-- Parámetros:
-- 'HORARIOID: Es id de un horario dia existente 
-- 'DIAID: Es el id dia '
-- 'LIBRE: es el estado que define si un dia es libre dentro del horario dia
--  valor por defecto 0 '
--- Fecha Modificacion: 09-01-2026
--- Descripcion: despues de crear el horario dia se agregara automaticamente la vigencia
--=========================================================================================
CREATE   PROCEDURE [dbo].[sp_InsertHorarioDias]
    @HORARIOID INT,
    @DIAID INT,
    @USUARIO INT,
    @LIBRE BIT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT, XACT_ABORT ON;

    BEGIN TRY
        IF NOT EXISTS(SELECT 1
    FROM Dia
    WHERE id = @DIAID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET @Message = 'El dia no es valido';
        SET @CodeError = -1;
        RETURN;
    END

        IF NOT EXISTS (SELECT 1
    FROM Horario
    WHERE id = @HORARIOID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET @Message = 'El horario no es valido';
        SET @CodeError = -1;
        RETURN;
    END

    --     IF EXISTS (SELECT 1
    -- FROM HorarioDias
    -- WHERE diaId_fk = @DIAID AND horarioId_fk = @HORARIOID AND bEliminado = 0)
    --     BEGIN
    --     SET @State = -1;
    --     SET @Message = 'El dia ya fue ingresado para el mismo horario';
    --     RETURN;
    -- END
        
        INSERT INTO HorarioDias
        (horarioId_fk, diaId_fk, bLibre, nCreatedBy, tCreatedAt)
    VALUES
        (@HORARIOID, @DIAID, @LIBRE, @USUARIO, GETDATE());

        SET @Id = SCOPE_IDENTITY(); 

        --- Agrega la vigencia 
    --     INSERT INTO Vigencia
    --     (tFechaInicio, tFechaFin, horarioDiasId_fk, bEliminado, nCreatedBy, tCreatedAt, bTipo)
    -- SELECT TOP 1
    --     v.tFechaInicio,
    --     v.tFechaFin,
    --     @Id,
    --     0,
    --     @USUARIO,
    --     GETDATE(),
    --     0
    -- FROM Vigencia v
    --     INNER JOIN HorarioDias hd ON v.horarioDiasId_fk = hd.id
    --   --  INNER JOIN FechaLimite fl ON v.fechaLimiteId_pk = fl.id
    -- WHERE hd.horarioId_fk = @HORARIOID
    --     AND v.bTipo = 0
    --     AND v.bEliminado = 0
    -- ORDER BY v.tfechaFin DESC; 

        SET @Message = 'Dia creado correctamente';
        SET @CodeError = 0;
        SET @State = 1;

    END TRY
    BEGIN CATCH 
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
 

--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para crear un registro de marcacion
-- Parámetros: 'EMPLEADOID','EMPLEADOCOD','PUNCHSTATE', 'TERMINALID'
-- 'TERMINALSN', 'TERMINALALIAS'
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_InsertMarcacion]
    @EMPLEADOID INT,
    @EMPLEADOCOD VARCHAR (10),
    @PUNCHSTATE VARCHAR(250),
    @TERMINALID INT,
    @TERMINALSN VARCHAR(250),
    @TERMINALALIAS VARCHAR(250),
    @USUARIO INT,
    @Id INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
BEGIN TRY
    IF NULLIF(LTRIM(RTRIM(@TERMINALSN)), '') IS NULL
    BEGIN
        SET @Message = 'no se permite registrar espacios en blanco'
        SET @CodeError = -1;
        RETURN;
    END
    IF NULLIF(LTRIM(RTRIM(@TERMINALALIAS)), '') IS NULL
    BEGIN
        SET @Message = 'no se permite registrar espacios en blanco en el alias'
        SET @CodeError = -1;
        RETURN;
    END
    INSERT INTO Marcacion
        (emp_id, emp_code, punch_time, punch_state, terminal_sn, terminal_alias, terminal_id, nCreatedBy, tCreatedAt)
    VALUES
        ( @EMPLEADOID, @EMPLEADOCOD, GETDATE(), @PUNCHSTATE, @TERMINALSN, @TERMINALALIAS, @TERMINALID, @USUARIO, GETDATE())
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Marcación registrada correctamente'
        RETURN;
    END TRY
    BEGIN CATCH
        SET @Id = 0
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
 

-- DROP  PROCEDURE [dbo].[sp_InsertMarcacionCita]
CREATE   PROCEDURE [dbo].[sp_InsertMarcacionCita]
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
 

--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertMotivo]
-- Fecha:  23-09-2025
-- Descripcion: Procedimiento para crear un nuevo registro de Motivo
-- Parámetros: 'NOMBRE', 'DETALLE', 'USUARIO'
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_InsertMotivo]
    @NOMBRE VARCHAR (250),
    @DETALLE VARCHAR(250),
    @USUARIO INT,
    @B_DOCUMENTO BIT = 0,
    @State INT OUTPUT,
    @Message VARCHAR (250) OUTPUT,
    @CodeError INT OUTPUT,
    @Id INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY 
    IF EXISTS (SELECT 1
    FROM Motivo
    WHERE nombre = @NOMBRE  AND bEliminado = 0)
    BEGIN
        SET @ID = 0;
        SET @Message ='ya existe un motivo con ese titulo'
        SET @CodeError = -1;
        SET @State = -1;
        RETURN;
    END  
    IF NULLIF(LTRIM(@NOMBRE) , '') IS NULL
    BEGIN
        SET @ID = 0;
        SET @Message = 'no se permite espacios en blanco'
        SET @CodeError = -1;
        SET @State = -1;
        RETURN;
    END
    IF NOT @NOMBRE LIKE '%[a-zA-Z]%'
    BEGIN
        SET @ID = 0;
        SET @Message = 'no se permite ingresar números en el nombre'
        SET @CodeError = -1;
        SET @State = -1;
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM Motivo
    WHERE detalle = @DETALLE)
    BEGIN
        SET @ID = 0;
        SET @Message = 'ya existe un motivo con ese detalle'
        SET @CodeError = -1;
        SET @State = -1;
        RETURN;
    END
    IF NULLIF(LTRIM(@DETALLE), '') IS NULL
    BEGIN
        SET @ID = 0;
        SET @Message = 'No se permite espacios en blanco'
        SET @CodeError = -1;
        SET @State = -1;
        RETURN;
    END
    
    INSERT INTO Motivo
        (nombre, detalle, nCreatedBy, tCreatedAt, bDocumento)
    VALUES
        (@NOMBRE, @DETALLE, @USUARIO, GETDATE(), @B_DOCUMENTO);
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Motivo creado correctamente'
        SET @CodeError = 0;
        SET @State = 1;
    END TRY 
    BEGIN CATCH
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
 
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertTurnoModificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para crear un registro de turno Modificado 
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_InsertTurnoModificado]
    @IDROLUSUARIO INT = NULL,
    @IDTURNO INT,
    @HORA TIME(7),
    @TIPO  BIT,
    @FECHAINICIO DATE,
    @FECHAFIN DATE,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT

AS 
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS (
        SELECT 1
    FROM TurnoRegular
    WHERE id = @IDTURNO AND bEliminado = 0
    )
    BEGIN
        SET @State = -1;
        SET @Message = 'El Turno no es valido'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (
        SELECT 1
    FROM RolUsuario
    WHERE (@IDROLUSUARIO IS NULL OR id = @IDROLUSUARIO) AND bEliminado = 0
    )
    BEGIN 
        SET @State = -1;
        SET @Message = 'El RolUsuario no es valido'
        SET @CodeError =-1;
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM TurnoModificado 
    WHERE (turnoRegularId_fk = @IDTURNO) AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'El turno ya fue modificado'
        RETURN;
    END
    INSERT INTO TurnoModificado
        (rolUsuarioId_fk, turnoRegularId_fk, tHora, btipo, fechaInicio, fechaFin, nCreatedBy, tCreatedAt)
    VALUES
        (@IDROLUSUARIO, @IDTURNO, @HORA, 0, @FECHAINICIO, @FECHAFIN, @USUARIO, GETDATE())
        SET @Id = SCOPE_IDENTITY();
        SET @Message = 'Turno modificado creado correctamente'
        SET @CodeError = 0
    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @Message = ERROR_MESSAGE()
        SET @CodeError = ERROR_NUMBER()
        SET @State = -1;
    END CATCH
END
GO
 

--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[dbo].[dbo].[sp_InsertUnidadFeriado]
-- Fecha:  01-10-2025
-- Descripcion: Procedimiento para registrar los id de unidad y ferido
-- Parámetros: 'UNIDAD', 'FERIADO'
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_InsertUnidadFeriado]
    @UNIDAD INT,
    @FERIADO INT,
    @USUARIO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
    IF NOT EXISTS (SELECT 1
    FROM Unidad
    WHERE id = @UNIDAD) 
    BEGIN 
        SET @State =-1;
        SET @Message = 'la unidad no esa valida'
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM FechaFeriado 
    WHERE id = @FERIADO)
    BEGIN
        SET @Message = 'la fecha feriado no es valida'
        RETURN;
    END
    INSERT INTO UnidadFeriado (unidadId_pk, fechaFeriadoId_pk,nCreatedBy, tCreatedAt)
    VALUES (@UNIDAD, @FERIADO, @USUARIO, GETDATE())
        SET @Message = ' unidad feriado creado correctamente'
        SET @State = 1
        SET @CodeError= 0
    END TRY
    BEGIN CATCH 
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @State = 0
    END CATCH
END
GO
 
--=================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_InsertAsistenciaModificada]
-- Fecha:  26-09-2025
-- Descripcion: Procedimiento para actualizar un registro de asistencia modificada 
-- solo se perimita modificar el turno
--=================================================================================
CREATE   PROCEDURE [dbo].[sp_UpdateAsistenciaModificada]
    @USUARIO INT,
    @ID INT,
    @IDTURNO INT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM AsistenciaModificada 
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'Asistencia modificada no valida'
        RETURN;
    END
    IF EXISTS (SELECT 1
    FROM AsistenciaModificada
    WHERE turnoModificadoId_fk = @IDTURNO AND id <> @ID)
    BEGIN 
        SET @State = -1;
        SET @Message = 'El turno ya fue ingresado en la asistencia modificada'
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM TurnoModificado
    WHERE id = @IDTURNO AND bEliminado = 0 )
    BEGIN 
        SET @State = -1;
        SET @Message = 'turno mofidicado no valido'
        RETURN;
    END
    
    UPDATE AsistenciaModificada
        SET turnoModificadoId_fk = @IDTURNO,
            nUpdatedBy =COALESCE(nUpdatedBy, @USUARIO),
            tUpdatedAt = GETDATE()
        WHERE id = @ID
            SET @State = 0;
            SET @Message = 'Asistencia modificada actualizada correctamente'
            SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateFeriado]
-- Fecha:  27-09-2025
-- Descripcion: Procedimiento para actualizar datos de una denominacion de feriado 
-- Parámetros:
-- 'ID : el ID de un registro de la tabla DenominacionFeriado'
-- 'CODIGO: Es el codigo que se le asigna al registro puede ser alfanumerico
-- 'DENOMINACION: Es el nombre que se le asigna al feriado'
-- 'DESCRIPCION: Es la descripcion que se le asigna al feriado este campo no es obligatorio'
--=========================================================================================
CREATE   PROCEDURE [dbo].[sp_UpdateFeriado]
    @ID INT,
    @USUARIO INT,
    @CODIGO CHAR(10) = NULL,
    @DENOMINACION VARCHAR(250) = NULL,
    @DESCRIPCION VARCHAR(250) = NULL,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT 
AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;
    BEGIN TRY 
IF EXISTS (SELECT 1
        FROM DenominacionFeriado
        WHERE cDenominacion = @DENOMINACION AND bEliminado = 0 AND id <> @ID)
            BEGIN 
                SET @State =-1;
                SET @Message = 'Ya existe un registro con esta denominacion'
                RETURN;
            END
        
        IF EXISTS (SELECT 1
        FROM DenominacionFeriado
        WHERE codigo = @CODIGO AND bEliminado = 0 AND id <> @ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'el codigo ya fue registrado'
            RETURN;
        END
        UPDATE DenominacionFeriado
            SET codigo = COALESCE(@CODIGO, codigo),
                cDenominacion = COALESCE(@DENOMINACION, cDenominacion),
                cDescripcion =  COALESCE (@DESCRIPCION, cDescripcion),
                nUpdatedBy= @USUARIO,
                tUpdatedAt = GETDATE()
            WHERE 
                id = @ID;

                SET @State = 1;
                SET @Message = 'Actualizacion correcta'
                SET @CodeError = 0;
        END TRY
        BEGIN CATCH
            SET @State = -1;
            SET @Message = ERROR_MESSAGE();
            SET @CodeError = ERROR_NUMBER();
        END CATCH
END
GO
 

--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateHorioDias]
-- Fecha:  17-09-2025
-- Descripcion: Procedimiento para actualizar el HorarioDia
-- permite cambiar el estado bLibre
-- Parámetros:
-- 'IDHORARIODIA: id de hoarioDia  
-- 'LIBRE: es el estado que definie si un dia es libre dentro del horario dia
--  valor por defecto 0, si se le asigan un valor 1 el estado del dia cambiara 
--  a libre en consecuente eliminara todos los registros de las tablas relaciondas
--- con el horarioDia que se esta modificando'
--=========================================================================================
CREATE   PROCEDURE [dbo].[sp_UpdateHorarioDias]
    @IDHORARIODIA INT,
    @LIBRE BIT,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Verificar si existe el HorarioDia
        IF NOT EXISTS (
            SELECT 1
            FROM HorarioDias
            WHERE id = @IDHORARIODIA AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'horario dia no encontrado';
            SET @CodeError = -1;
            RETURN;
        END

        -- Actualizar el estado de bLibre
        UPDATE HorarioDias
        SET bLibre = @LIBRE
        WHERE id = @IDHORARIODIA;

        -- Si existen TurnoRegular relacionados, marcarlos como eliminados
        IF EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE HorarioDiasId_fk = @IDHORARIODIA
        )
        BEGIN
            UPDATE TurnoRegular
            SET bEliminado = 1
            WHERE HorarioDiasId_fk = @IDHORARIODIA;
        END

        -- Si existen TurnoExtendido relacionados, marcarlos como eliminados y eliminar ConectadoDias relacionados
        IF EXISTS (
            SELECT 1
            FROM TurnoExtendido
            WHERE HorarioDiasId_fk = @IDHORARIODIA
        )
        BEGIN
            UPDATE TurnoExtendido
            SET bEliminado = 1
            WHERE HorarioDiasId_fk = @IDHORARIODIA;

            DELETE CD
            FROM ConectadoDias AS CD
            INNER JOIN TurnoExtendido AS TE ON CD.TurnoExtendidoId_pk = TE.id
            WHERE TE.bEliminado = 0 AND TE.HorarioDiasId_fk = @IDHORARIODIA;
        END

        SET @State = 1;
        SET @Message = 'dia actualizado correctamente';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateMarcacion]
-- Fecha:  18-09-2025
-- Descripcion: Procedimiento para crear un registro de marcacion
-- Parámetros: 'ID', 'USUARIO','PUNCHSTATE', 'PUNCHSTIME'
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_UpdateMarcacion]
    @ID INT,
    @USUARIO INT,
    @PUNCHSTATE VARCHAR(5),
    @PUNCHTIME DATETIME,
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,
 XACT_ABORT ON;
    BEGIN TRY 
     IF NOT EXISTS (SELECT 1
     FROM Marcacion
     WHERE id = @ID AND bEliminado = 0)
     BEGIN
        SET @State = -1;
        SET @Message = 'Marcación no encontrada'
        SET @CodeError = -1;
        RETURN;
     END
    UPDATE Marcacion
    SET punch_time = COALESCE (@PUNCHTIME, punch_time),
        punch_state = COALESCE (@PUNCHSTATE, punch_state),
        nCreatedBy = @USUARIO,
        tCreatedAt = GETDATE()
    WHERE Id = @ID
        SET @State = 1;
        SET @Message = 'Actualización correcta'
        SET @CodeError= 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_UpdateTurnoModificado]
-- Fecha:  22-09-2025
-- Descripcion: Procedimiento para actualizar datos de un registros de turno Modificado 
--=======================================================================================
CREATE   PROCEDURE [dbo].[sp_UpdateTurnoModificado]
    @ID INT,
    @IDROLUSUARIO INT = NULL,
    @USUARIO INT,
    @TIPO INT,
    @HORA TIME(7),
    @State INT OUTPUT,
    @Message VARCHAR(250) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ,
    XACT_ABORT ON;
    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM TurnoModificado
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'No se encontro el turno modificado'
        SET @CodeError = -1;
        RETURN;
    END
    UPDATE TurnoModificado
    SET tHora = @HORA,
        bTipo = COALESCE(@TIPO, bTipo),
        rolUsuarioId_fk = COALESCE(@IDROLUSUARIO, rolUsuarioId_fk),
        nUpdatedBy = @USUARIO,
        tUpdatedAt = GETDATE()
    WHERE 
     id = @ID
        SET @State = -1;
        SET @Message = 'Tunno Modificado actualizado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_actualizarJustificacion]
FECHA: 28-01-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Actualizar una justificación lógica en la tabla Justificacion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_actualizarJustificacion]
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
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_AddCursoBasicoTurnoRegular]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite agregar un nuevo curso en el turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_AddCursoBasicoTurnoRegular]
  @CURSO_ID INT,
  @TURNO_REGULAR_ENTRADA INT,
  @TURNO_REGULAR_SALIDA INT,
  @ROL_USUARIO INT,
  @USUARIO INT,
  @State INT OUTPUT,
  @Message VARCHAR(250) OUTPUT,
  @Id INT OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO CursoSeccionBasica_TurnoRegular
    (syncCursoSeccionId, turnoRegularEntradaId, turnoRegularSalidaId, nCreatedBy, rolUsuarioId)
  VALUES
    (@CURSO_ID, @TURNO_REGULAR_ENTRADA, @TURNO_REGULAR_SALIDA, @USUARIO, @ROL_USUARIO);

  SET @State = 1;
  SET @Message = 'Curso agregado correctamente';
  SET @Id = SCOPE_IDENTITY();
  SET @CodeError = 0;
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_AddCursoTurnoRegular]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite agregar un nuevo curso en el turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_AddCursoTurnoRegular]
  @CURSO_ID INT,
  @TURNO_REGULAR_ENTRADA INT,
  @TURNO_REGULAR_SALIDA INT,
  @ROL_USUARIO_ID INT,
  @USUARIO INT,
  @State INT OUTPUT,
  @Message VARCHAR(250) OUTPUT,
  @Id INT OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO CursoSeccionPreUniversitaria_TurnoRegular
    (syncCursoSeccionPreUniversitariaId, turnoRegularEntradaId, turnoRegularSalidaId, nCreatedBy, rolUsuarioId)
  VALUES
    (@CURSO_ID, @TURNO_REGULAR_ENTRADA, @TURNO_REGULAR_SALIDA, @USUARIO, @ROL_USUARIO_ID);

  SET @State = 1;
  SET @Message = 'Curso agregado correctamente';
  SET @Id = SCOPE_IDENTITY();
  SET @CodeError = 0;
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_addJustificacionTurnoExtendido]
FECHA: 28/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Agregar registros a la tabla JustificacionTurnoExtendido


MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_addJustificacionTurnoExtendido]
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

  INSERT INTO JustificacionTurnoExtendido
    (justificacionId_fk, turnoExtendidoId_fk, bEliminado, nCreatedBy, tCreatedAt)
  VALUES
    (@JustificacionId, @TURNO_ID , 0, @USER_ID, GETDATE());

  SET @State = 1;
  SET @Message = 'Justificación de turno regular agregada exitosamente.';
  SET @CodeError = 0;
  SET @Id = SCOPE_IDENTITY();
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_addJustificacionTurnoRegular]
FECHA: 28/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Agregar registros a la tabla JustificacionTurnoRegular


MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_addJustificacionTurnoRegular]
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
GO
 

CREATE   PROCEDURE [dbo].[usp_addOutbox]
    @TOPIC AS NVARCHAR(200),
    @KEY AS NVARCHAR(200),
    @PAYLOAD AS NVARCHAR(MAX),
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY
    SET NOCOUNT
        , XACT_ABORT ON;
    INSERT INTO kafka_outbox
        (topic, [key], payload)
    VALUES
        (@TOPIC, @KEY, @PAYLOAD)

    SET @Id =SCOPE_IDENTITY();
    SET @Message = 'Usuario creado correctamente';
    SET @CodeError = 0;
    SET @State = 1;

    END TRY
    BEGIN CATCH    
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_addPermisosRegular]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Agregar registros a la tabla PermisoRegular

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_addPermisosRegular]
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
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_addPermisosTurnoExtendido]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Agregar registros a la tabla PermisoTurnoExtendido

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_addPermisosTurnoExtendido]
  @ROL_USUARIO_ID INT,
  @MOTIVO_ID INT,
  @FECHA DATE,
  @HORA_SALIDA TIME,
  @HORA_RETORNO_ESTIMADO TIME,
  @HORA_RETORNO_REAL TIME = NULL,
  @TURNO_EXTENDIDO_ID INT,
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

  INSERT INTO PermisoTurnoExtendido
    (permisoId_pk, turnoExtendidoId_pk, nCreatedBy)
  VALUES
    (@PERMISO_ID, @TURNO_EXTENDIDO_ID, @USER_ID);

  SET @State = 1;
  SET @Message = 'Permiso con turno extendido agregado exitosamente.';
  SET @CodeError = 0;
END
GO
 

/*======================================================================================================
Nombre: [dbo].[usp_addUsuarioAHorarioCita]
Autor: Gabriel Vasquez Uscuvilca
Fecha: 13-02-2026
OBJETIVO: Procedimiento para agregar un usuario a un horario de cita

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
 -    -             -             -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_addUsuarioAHorarioCita]
  @HORARIO_ID INT,
  @ROL_USUARIO_ID INT,
  @USER INT,
  @Id INT OUTPUT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

  INSERT INTO HorarioUsuario
    (horarioId_fk, rolUsuarioId_fk, bEliminado, tfechaInicio, tFechaFin, nCreatedBy, tCreatedAt)
  VALUES
    (@HORARIO_ID, @ROL_USUARIO_ID, 0, GETDATE(), GETDATE(), @USER, GETDATE());

    SET @Id = SCOPE_IDENTITY();
    SET @State = 1;
    SET @Message = 'Usuario agregado al horario de cita correctamente.';
    SET @CodeError = 0;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;

    SET @State = 0;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
  END CATCH;

END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_AsistenciaExtendida]
FECHA: 26-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar marcaciones reales por asistencia id de asistencia extendida

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_AsistenciaExtendida]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT 
        m.punch_time as marcacionReal
    FROM AsistenciaExtendida ae
        INNER JOIN Asistencia a on a.id = ae.asistenciaId_fk
        INNER JOIN Marcacion m on m.id = ae.marcacionId_fk
    WHERE 
    m.bEliminado = 0 AND
    a.bEliminado = 0 AND
    ae.bEliminado = 0 AND
    ae.asistenciaId_fk = @ASISTENCIA_ID
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_AsistenciaModificada]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar marcaciones reales por asistencia id de asistencia modificada

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_AsistenciaModificada]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT 
        m.punch_time as marcacionReal
    FROM AsistenciaModificada am
        INNER JOIN Asistencia a on a.id = am.asistenciaId_fk
        INNER JOIN Marcacion m on m.id = am.marcacionId_fk
    WHERE 
    m.bEliminado = 0 AND
    a.bEliminado = 0 AND
    am.bEliminado = 0 AND
    am.asistenciaId_fk = @ASISTENCIA_ID
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_AsistenciaRegular]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar marcaciones reales por asistencia id de asistencia regular

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_AsistenciaRegular]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT 
        m.punch_time as marcacionReal
    FROM AsistenciaRegular ar
        INNER JOIN Asistencia a on a.id = ar.asistenciaId_fk
        INNER JOIN Marcacion m on m.id = ar.marcacionId_fk
    WHERE 
    m.bEliminado = 0 AND
    a.bEliminado = 0 AND
    ar.bEliminado = 0 AND
    ar.asistenciaId_fk = @ASISTENCIA_ID
END
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
 
/*======================================================================================================
NOMBRE: [dbo].[usp_crearCitaHorario]
FECHA: 13-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite crear un horario para una cita.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
-      -             -           -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_crearHorarioCita]
  @TITULO VARCHAR(255),
  @USER INT,
  @Id INT OUTPUT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  BEGIN TRY
        INSERT INTO Horario
        (cTitulo, horaDia, bGeneral, bExtendido, bRotativo, nCreatedBy, tCreatedAt)
  VALUES
    (@TITULO,'10', 1, 0, 0, @USER, GETDATE());
        IF @@ROWCOUNT > 0
        BEGIN
    SET @Id = SCOPE_IDENTITY();
    SET @State = 0;
    SET @Message = 'El horario de cita fue creado correctamente.';
  END
        ELSE
        BEGIN
    SET @State = -1;
    SET @Message = 'No se pudo crear el horario de cita.';
  END
    END TRY
    BEGIN CATCH
        SET @State = -2;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteAsistenciaExtendida]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteAsistenciaExtendida]
    @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM AsistenciaExtendida
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1
            SET @Message = 'La asistencia no existe o ha sido eliminado';

            RETURN
        END

        UPDATE AsistenciaExtendida
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1
            SET @Message = 'Fallo en la eliminacion';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteAsistenciaRegular]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteAsistenciaRegular]
    @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM AsistenciaRegular
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1
            SET @Message = 'La asistencia no existe o ha sido eliminado';

            RETURN
        END

        UPDATE AsistenciaRegular
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1
            SET @Message = 'Fallo en la eliminacion';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

CREATE   PROCEDURE [dbo].[usp_DeleteAsistenciasByLicencia]
  @ROL_USUARIO_ID INT,
  @FECHA_INICIO DATE,
  @FECHA_FIN DATE,
  @USER INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Obtener los IDs de asistencias en el rango de fechas para el rolUsuario
        DECLARE @AsistenciaIds TABLE (id INT);

        INSERT INTO @AsistenciaIds
            (id)
        SELECT a.id
        FROM Asistencia a
        WHERE a.rolUsuarioid_fk = @ROL_USUARIO_ID
            AND a.tFecha >= @FECHA_INICIO
            AND a.tFecha <= @FECHA_FIN
            AND a.bEliminado = 0;

                IF NOT EXISTS (SELECT 1
        FROM @AsistenciaIds)
                BEGIN
            SET @State = 0;
            SET @Message = 'No se encontraron asistencias para eliminar en el rango de fechas.';
            SET @CodeError = 0;
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 2. Eliminar registros en ControlUnidadAsistencia
        DELETE cua
        FROM ControlUnidadAsistencia cua
    INNER JOIN @AsistenciaIds ai ON cua.asistenciaId_fk = ai.id;

        -- 3. Eliminar registros en RolControlAsistencia
        DELETE rca
        FROM RolControlAsistencia rca
    INNER JOIN @AsistenciaIds ai ON rca.asistenciaId_fk = ai.id;

        -- 4. Eliminar registros en ControlRolUsuarioAsistencia
        DELETE crua
        FROM ControlRolUsuarioAsistencia crua
    INNER JOIN @AsistenciaIds ai ON crua.asistenciaId_fk = ai.id;

        -- 5. Eliminar las asistencias
    --     DELETE a
    --     FROM Asistencia a
    -- INNER JOIN @AsistenciaIds ai ON a.id = ai.id;

        COMMIT TRANSACTION;

        SET @State = 0;
        SET @Message = 'Asistencias y controles eliminados exitosamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteBiometrico]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar el registro de un biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteBiometrico] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El biométrico no existe o ya fue eliminado.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE biometricoId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El biometrico ya tiene detalles, no puede eliminar';

            RETURN;
        END;

        UPDATE Biometrico
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación  exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteCita]
FECHA: 26-09-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO:Procedimiento para eliminar de forma logica el registro de una cita por ID

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteCita] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    IF NOT EXISTS (
            SELECT 1
            FROM Cita
            WHERE id = @ID
                AND bEliminado = 0
            )
    BEGIN
        SET @State = - 2;
        SET @Message = 'La cita no existe o ya fue eliminada.';

        RETURN;
    END;

    IF EXISTS (
            SELECT 1
            FROM Cita
            WHERE id = @ID
                AND bCancelado = 0
                AND bEliminado = 0
            )
    BEGIN
        SET @State = - 3;
        SET @Message = 'No se puede eliminar una cita que está en uso o activa.';

        RETURN;
    END;

    IF @USER IS NULL
        OR @USER <= 0
    BEGIN
        SET @State = - 4;
        SET @Message = 'El usuario que realizo la eliminacion no es válido.';

        RETURN;
    END;

    UPDATE Cita
    SET nUpdatedBy = @USER
        , tUpdatedAt = GETDATE()
        , bEliminado = 1
    WHERE id = @ID

    IF (@@ROWCOUNT > 0)
    BEGIN
        SET @State = 0;
        SET @Message = 'Eliminación exitosa';
    END
    ELSE
    BEGIN
        SET @State = - 1;
        SET @Message = 'Fallo en la eliminación';
    END
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteConectadoDias]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Eliminar un registro en ConectadoDias

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteConectadoDias] @TURNOEXTENDIDOID INT
    , @DIASID INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @TURNOEXTENDIDOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El turnoExtendido no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Dia
                WHERE id = @DIASID
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El día especificado no existe.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM ConectadoDias
                WHERE turnoExtendidoId_pk = @TURNOEXTENDIDOID
                    AND diasId_pk = @DIASID
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El registro ConectadoDias no existe.';

            RETURN;
        END;

        -- IF EXISTS (
        --         SELECT 1
        --         FROM TurnoExtendido AS TE
        --         INNER JOIN HorarioDias AS HD
        --             ON TE.horarioDiasId_fk = HD.id
        --             AND HD.bEliminado = 0
        --         WHERE TE.id = @TURNOEXTENDIDOID
        --             AND TE.bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 5;
        --     SET @Message = 'El turnoExtendido está en uso, no se puede eliminar.';

        --     RETURN;
        -- END;

        DELETE
        FROM ConectadoDias
        WHERE turnoExtendidoId_pk = @TURNOEXTENDIDOID
            AND diasId_pk = @DIASID;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Falla al eliminar.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControl]
FECHA: 18-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteControl]
    @CONTROL_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY

        IF EXISTS (SELECT 1 FROM ControlUnidad cu WHERE cu.controlId_fk = @CONTROL_ID AND cu.bEliminado = 0) OR 
           EXISTS (SELECT 1 FROM ControlRolUsuario cru WHERE cru.controlId_fk = @CONTROL_ID AND cru.bEliminado = 0)  OR 
           EXISTS (SELECT 1 FROM RolControl rc WHERE rc.controlId_fk = @CONTROL_ID AND rc.bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se puede eliminar, el control está en uso.'
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS ( SELECT 1 FROM [Controles] WHERE id = @CONTROL_ID and bEliminado = 0)
            BEGIN
                SET @State = -1;
                SET @Message = 'Registro fue eliminado o no existe.'
                SET @CodeError = -1;
            RETURN;
        END


        UPDATE CONTROLES 
            SET bEliminado = 1
        WHERE Id = @CONTROL_ID
        
        SET @State = 1;
        SET @Message = 'Control eliminado correctamente';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControlRolUsuario]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Elimina (lógico) un registro en la tabla ControlRolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteControlRolUsuario]
    @ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Verificar que exista
        IF NOT EXISTS (SELECT 1 FROM ControlRolUsuario WHERE Id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró el registro o ya fue eliminado.';
            SET @CodeError = -1; 
            RETURN;
        END

        -- Eliminado lógico
        UPDATE ControlRolUsuario
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE Id = @ID;

        SET @State = 1;
        SET @Message = 'Registro eliminado correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControlRolUsuarioAsistencia]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar asistencia 

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE    PROCEDURE [dbo].[usp_DeleteControlRolUsuarioAsistencia]
    @ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        IF NOT EXISTS (SELECT 1 FROM RolControlAsistencia WHERE id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro de RolControlAsistencia no existe o ya está eliminado.';
            SET @CodeError = -1;
            ROLLBACK TRAN;
            RETURN;
        END

        UPDATE RolControlAsistencia
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @State = 1;
        SET @Message = 'RolControlAsistencia eliminado correctamente.';
        SET @CodeError = 0;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControlRolUsuarioAsitencia]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar asistencia con que estado esta el usuario rol y que control se utlizo

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteControlRolUsuarioAsitencia]
    @ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1 FROM ControlRolUsuarioAsistencia WHERE id = @ID AND bEliminado = 0)
        BEGIN 
            SET @State = -1;
            SET @Message = 'El registro de ControlRolUsuarioAsistencia no existe o ya está eliminado'
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE ControlRolUsuarioAsistencia
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID

        SET @State = 1;
        SET @Message = 'ControlRolUsuarioAsistencia eliminado correctamente'
        SET @CodeError = 0

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControlUnidad]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar (lógicamente) un registro en la tabla ControlUnidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteControlUnidad]
    @Id INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar que el registro exista y no esté ya eliminado
        IF NOT EXISTS (SELECT 1 
                       FROM ControlUnidad 
                       WHERE id = @Id AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró el registro de ControlUnidad o ya fue eliminado.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Eliminar (lógicamente)
        UPDATE ControlUnidad
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @Id;

        SET @State = 1;
        SET @Message = 'Control Unidad eliminado correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteControlUnidadAsistencia]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar asistencia con que estado esta el usuario rol y que control se utlizo

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteControlUnidadAsistencia]
    @ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (SELECT 1
    FROM ControlUnidadAsistencia
    WHERE id = @ID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET @Message = 'El registro de ControlUnidadAsistencia no existe o ya está eliminado.';
        SET @CodeError = -1;
        RETURN;
    END

        UPDATE ControlUnidadAsistencia
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @State = 0;
        SET @Message = 'ControlUnidadAsistencia eliminado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [DBO].[usp_DeleteControlVacaciones]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar datos de control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteControlVacaciones] 
    @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM ControlVacaciones
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El periodo vacacional no existe o ha sido eliminado';

            RETURN
        END

        IF EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE controlVacacionalId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El control vacacional está en uso.';

            RETURN;
        END

        UPDATE ControlVacaciones
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1
            SET @Message = 'Fallo en la eliminacion';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
    NOMBRE: [dbo].[usp_DeleteCursoSeccionPreUniversitarioTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Eliminar la relación entre curso sección preuniversitaria y turno regular
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
     -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteCursoSeccionPreUniversitarioTurnoRegular]
    @ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM CursoSeccionPreUniversitaria_TurnoRegular
            WHERE id = @ID AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró la asignación especificada para eliminar.';
            SET @CodeError = -1;
            RETURN;
        END

        UPDATE CursoSeccionPreUniversitaria_TurnoRegular
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @State = 1;
        SET @Message = 'Asignación eliminada exitosamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        RETURN;
    END CATCH

END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteDetalleBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar (lógicamente) un detalle biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteDetalleBiometrico] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message NVARCHAR(200) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        SET NOCOUNT ON;

        IF NOT EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE id = @id
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El detalleBiometrico, no existe o está eliminado';

            RETURN;
        END;


        IF EXISTS (
                SELECT 1
                FROM AsistenciaRegular
                WHERE detalleBiometricoId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'Esta siendo usado, en AsistenciRegular';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM AsistenciaExtendida
                WHERE detalleBiometricoId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Esta siendo usado, en AsistenciExtendida';

            RETURN;
        END;

        UPDATE DetalleBiometrico
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la eliminacion.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [DBO].[usp_DeleteEstadoAsistencia]
FECHA: 25-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar datos de control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteEstadoAsistencia] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM EstadoAsistencia
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El estado asistencia no existe o ha sido eliminado';

            RETURN
        END

        IF EXISTS (
                SELECT 1
                FROM ControlRolUsuarioAsistencia
                WHERE estadoAsistenciaId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El estado asistencia está en uso.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM ControlUnidadAsistencia
                WHERE estadoAsistenciaId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El estado asistencia está en uso.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM RolControlAsistencia
                WHERE estadoAsistenciaId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El estado asistencia está en uso.';

            RETURN;
        END

        UPDATE EstadoAsistencia
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1
            SET @Message = 'Fallo en la eliminacion';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteHorario]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite Eliminar un horario que no este en uso.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE     PROCEDURE [dbo].[usp_DeleteHorario]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF NOT EXISTS (SELECT 1
    FROM Horario
    WHERE id = @ID AND bEliminado = 0)
        BEGIN
        SELECT @State = -2, @Message = 'El horario no existe o ya ha sido eliminado.';
        RETURN;
    END

        --  Validar si está asignado a usuarios 
    --     IF EXISTS (SELECT 1
    -- FROM HorarioUsuario
    -- WHERE horarioId_fk = @ID AND bEliminado = 0)
    --     BEGIN
    --     SELECT @State = -3, @Message = 'El horario está asignado a un usuario activo, no se puede eliminar.';
    --     RETURN;
    -- END

        IF EXISTS (
            SELECT 1
        FROM AsistenciaRegular AR
            INNER JOIN TurnoRegular TR ON AR.TurnoRegularId_fk = TR.id
            INNER JOIN HorarioDias HD ON TR.horarioDiasId_fk = HD.id
        WHERE HD.horarioId_fk = @ID
        ) OR EXISTS (
            SELECT 1
        FROM AsistenciaExtendida AE
            INNER JOIN TurnoExtendido TE ON AE.TurnoExtendidoId_fk = TE.id
            INNER JOIN HorarioDias HD ON TE.horarioDiasId_fk = HD.id
        WHERE HD.horarioId_fk = @ID
        )
        BEGIN
        SELECT @State = -5, @Message = 'El horario ya cuenta con registros de asistencia. No se puede eliminar.';
        RETURN;
    END

        BEGIN TRANSACTION;
            
            UPDATE TM
            SET bEliminado = 1
            FROM TurnoModificado TM
            INNER JOIN TurnoRegular TR ON TM.turnoRegularId_fk = TR.id
            INNER JOIN HorarioDias HD ON TR.horarioDiasId_fk = HD.id
            WHERE HD.horarioId_fk = @ID AND TM.bEliminado = 0;

            UPDATE TR
            SET bEliminado = 1
            FROM TurnoRegular TR
            INNER JOIN HorarioDias HD ON TR.horarioDiasId_fk = HD.id
            WHERE HD.horarioId_fk = @ID AND TR.bEliminado = 0;

            UPDATE TE
            SET bEliminado = 1
            FROM TurnoExtendido TE
            INNER JOIN HorarioDias HD ON TE.horarioDiasId_fk = HD.id
            WHERE HD.horarioId_fk = @ID AND TE.bEliminado = 0;

            UPDATE Vigencia 
            SET bEliminado = 1
            FROM Vigencia V
            INNER JOIN HorarioDias HD ON V.horarioDiasId_fk = HD.id
            WHERE HD.horarioId_fk = @ID AND V.bEliminado = 0;

            UPDATE HorarioDias
            SET bEliminado = 1
            WHERE horarioId_fk = @ID AND bEliminado = 0;
            
            UPDATE HorarioUsuario 
            SET bEliminado = 1 
            WHERE horarioId_fk = @ID AND bEliminado = 0

            UPDATE Horario
            SET bEliminado = 1, 
                nUpdatedBy = @USER, 
                tUpdatedAt = GETDATE()
            WHERE id = @ID;

        COMMIT TRANSACTION;

        SET @State = 0;
        SET @Message = 'Horario eliminado correctamente.';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [DBO].[usp_DeleteHorarioUsuario]
FECHA: 03-10-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar datos de control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
create   PROCEDURE [dbo].[usp_DeleteHorarioUsuario]
    @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM HorarioUsuario
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El horario usuario no existe o ha sido eliminado';

            RETURN
        END

        UPDATE HorarioUsuario
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1
            SET @Message = 'Fallo en la eliminacion';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteLicencia]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite eliminar una licencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteLicencia]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
    FROM Licencia
    WHERE id = @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 2;
        SET @Message = 'La licencia no existe o ya fue eliminada.';

        RETURN;
    END;


        UPDATE Licencia
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID;

        IF (@@ROWCOUNT > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Eliminación exitosa';
    END
        ELSE
        BEGIN
        SET @State = - 1;
        SET @Message = 'Fallo en la eliminación';
    END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
CREATE   PROCEDURE [dbo].[usp_DeleteOneSituacion]
  @Id INT,
  @User INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM Situacion WHERE Id = @Id)
    BEGIN
      SET @State = -1;
      SET @Message = 'Situación no encontrada';
      SET @CodeError = -1;
      RETURN;
    END

    -- Eliminar parcialmente
    update Situacion
      SET bEliminado = 1
    WHERE id = @Id

    SET @State = 0;
    SET @Message = 'Situación eliminada correctamente';
    SET @CodeError = 0;
  END TRY
  BEGIN CATCH
    SET @State = 1;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
  END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [DBO].[usp_DeletePeriodoVacacional]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Eliminar datos control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeletePeriodoVacacional] 
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El periodo vacacional no existe o ha sido eliminado';

            RETURN
        END

        UPDATE PeriodoVacacional
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID;



        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            DECLARE @diasConsumidos INT;
            SELECT @diasConsumidos = nDiasConsumidos
            FROM PeriodoVacacional WHERE id = @ID;

            UPDATE ControlVacaciones
            SET nDiasTomados = nDiasTomados - @diasConsumidos
            WHERE id = (SELECT controlVacacionalId_fk FROM PeriodoVacacional WHERE id = @ID);

            SET @State = 0
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1
            SET @Message = 'Fallo en la eliminacion';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_DeletePermiso]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar un permiso (lógicamente)

MODIFICACIONES:
NRO   FECHA       USUARIO   MODIFICACION
 -       -          -           - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeletePermiso] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o fue eliminado';

            RETURN;
        END
        IF EXISTS (
                SELECT 1
                FROM PermisoTurnoRegular
                WHERE permisoId_pk = @ID
                ) 
            OR EXISTS (
                SELECT 1
                FROM PermisoTurnoExtendido
                WHERE permisoId_pk = @ID

                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El permiso está en uso y no se puede eliminar';

            RETURN;
        END

        UPDATE Permiso
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la eliminación';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeletePermisoTurnoExtendidor]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar el registro de un permisoTurnoExtendido.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeletePermisoTurnoExtendido] @PERMISOID INT
    , @TURNOID INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @TURNOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El turnoExtendido no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @PERMISOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM PermisoTurnoRegular
                WHERE permisoId_pk = @PERMISOID
                    AND turnoRegularId_pk = @TURNOID
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'No existe el registro a eliminar.';

            RETURN;
        END;

        DELETE
        FROM PermisoTurnoExtendido
        WHERE permisoId_pk = @PERMISOID
            AND turnoExtendidoId_pk = @TURNOID;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la eliminación';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_DeletePermisoTurnoRegular]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Eliminar el registro de un permisoTurnoRegular

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeletePermisoTurnoRegular] @PERMISOID INT
    , @TURNOID INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoRegular
                WHERE id = @TURNOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El turnoRegular no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @PERMISOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM PermisoTurnoRegular
                WHERE permisoId_pk = @PERMISOID
                    AND turnoRegularId_pk = @TURNOID
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'No existe el registro a eliminar.';

            RETURN;
        END;

        DELETE
        FROM PermisoTurnoRegular
        WHERE permisoId_pk = @PERMISOID
            AND turnoRegularId_pk = @TURNOID;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la eliminación';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteRol]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar un Rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteRol]
    @ROL_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY

    IF EXISTS ( SELECT 1 FROM RolControl WHERE rolId_fk = @ROL_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: el está vinculada a [Control].'
            SET @CodeError = -1;
        RETURN;
    END

        
    IF EXISTS ( SELECT 1 FROM RolUsuario WHERE rolId_fk = @ROL_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [Usuario].'
            SET @CodeError = -1;
        RETURN;
    END

       
    IF NOT EXISTS ( SELECT 1 FROM Rol WHERE id = @ROL_ID AND bEliminado = 0 )
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
        RETURN;
    END

    -- Eliminación lógica
    UPDATE Rol
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = SYSDATETIME()
        WHERE id = @ROL_ID;

    SET @State = 1;
    SET @Message = 'Rol eliminado correctamente';
    SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteRolControl]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar (lógicamente) un registro en la tabla RolControl

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteRolControl]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar existencia
        IF NOT EXISTS (SELECT 1 FROM RolControl WHERE Id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro de RolControl no existe o ya está eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

          -- Validar existencia
        IF EXISTS (SELECT 1 FROM RolControlAsistencia WHERE rolControlId_fk = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El RolControl seleccionado está en uso por RolControlAsistencia y no puede eliminarse."';
            SET @CodeError = -1;
            RETURN;
        END

        -- Eliminación lógica
        UPDATE RolControl
        SET bEliminado = 1,
            nUpdatedBy = @USER,     
            tCreatedAt = GETDATE()  
        WHERE Id = @ID;

        SET @State = 1;
        SET @Message = 'RolControl eliminado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteRolesDeUsuario]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar roles asignados a usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteRolDeUsuario]
    @ROL_USUARIO_ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        -- Validar si existe el rol y está en uso en otras tablas
        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROL_USUARIO_ID
                    -- AND usuarioId_fk = @USUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = - 1;

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM RolUsuario RU
                WHERE RU.id = @ROL_USUARIO_ID
                    -- AND RU.rolId_fk = @ROLID
                    AND RU.bEliminado = 0
                    AND (
                        EXISTS (
                            SELECT 1
                            FROM GradoSupervisado GS
                            WHERE GS.rolUsuarioId_pk = RU.id
                            )
                        OR EXISTS (
                            SELECT 1
                            FROM Retirado RE
                            WHERE RE.rolUsuarioid_fk = RU.id
                            )
                        OR EXISTS (
                            SELECT 1
                            FROM HorarioUsuario HO
                            WHERE HO.rolUsuarioid_fk = RU.id
                            )
                        OR EXISTS (
                            SELECT 1
                            FROM ControlRolUsuario CORO
                            WHERE CORO.rolUsuarioid_fk = RU.id
                            )
                        )
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se puede eliminar el rolUsuario porque está en uso [Control Rol] [Horario Usuario] [Retirado] [Grado Supervisado]';
            SET @CodeError = - 1;

            RETURN;
        END

        -- Marcar como eliminado
        UPDATE RolUsuario
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ROL_USUARIO_ID
            -- AND rolId_fk = @ROLID
            AND bEliminado = 0;

        SET @State = 1;
        SET @Message = 'Rol eliminado correctamente';
        SET @CodeError = 0;
    END TRY

    BEGIN CATCH
        SET @State = - 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
--==============================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_DeleteSupervisor]
-- Fecha: 06-10-2025
-- Descripcion: Procedimiento para eliminar de forma logica un registro de la tabla Supervisor
-- Parámetros: 
-- @USUARIO_ID: id de un registro de la tabla Sync_Usuario (int)
-- @UNIDAD_ID: id de un registro de la tabla Unidad (int)
-- @USUARIO: Id del usuario que realiza la eliminacion (int)
--============================================================================================
CREATE   PROCEDURE [dbo].[usp_DeleteSupervisor]
    @UNIDAD_ID INT,
    @USUARIO_ID INT,
    @USUARIO INT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY
  

    UPDATE Supervisor
        SET bEliminado = 1,
            nUpdatedBy = @USUARIO,
            tUpdatedAt = GETDATE()
        WHERE usuarioId_pk = @USUARIO_ID OR unidadId_pk = @UNIDAD_ID
        SET @State = 1
        SET @Message = 'Eliminado correctamente'
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

CREATE   PROCEDURE usp_DeleteSyncUsuarioPersona
    @ID INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS(SELECT 1
    FROM Sync_UsuarioPersona
    WHERE id = @ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'El usuario no existe';
        SET @CodeError = -1;
        RETURN;
    END

    DELETE Sync_UsuarioPersona
    WHERE id = @ID

    SET @State = 0;
    SET @Message = 'Usuario eliminado correctamente';
    SET @CodeError = 0;
    END TRY
    BEGIN CATCH    
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteTurnoExtendido]
FECHA: 17/10/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite la eliminación logica de turnos extendidos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE     PROCEDURE [dbo].[usp_DeleteTurnoExtendido]
    @ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Actualizar el estado del turno extendido a eliminado (por ejemplo, Estado = 0)
        UPDATE TurnoExtendido
        SET 
            bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE 
            ID = @ID;

        IF @@ROWCOUNT = 0
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró el turno extendido con el ID proporcionado.';
            SET @CodeError = 1;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @State = 1;
        SET @Message = 'Turno extendido eliminado correctamente.';
        SET @CodeError = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine R. Yora
OBJETIVO: Permite eliminar un turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteTurnoRegular] @ID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoRegular
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El turnoRegular no existe o ha sido eliminado'

            RETURN
        END

        IF EXISTS (
                SELECT 1
                FROM AsistenciaRegular
                WHERE turnoRegularId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3
            SET @Message = 'El turno esta en uso, en AsistenciaRegular'

            RETURN
        END

        IF EXISTS (
                SELECT 1
                FROM TurnoModificado
                WHERE turnoRegularId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El turno esta en uso, tiene Turnos Modificados activos.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM JustificacionTurnoRegular
                WHERE turnoRegularId_fk = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5
            SET @Message = 'El turno esta en uso, tienne JustificacionTurnoRegular'

            RETURN
        END

        UPDATE TurnoRegular
        SET bEliminado = 1
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Eliminación  exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteUnidad]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar una unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteUnidad]
    @UNIDAD_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY

        IF EXISTS ( SELECT 1 FROM ControlUnidad WHERE unidadId_fk = @UNIDAD_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [Control Unidad].'
            SET @CodeError = -1;
            RETURN; 
        END

        
        IF EXISTS ( SELECT 1 FROM Supervisor WHERE unidadId_pk = @UNIDAD_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [Supervisor].'
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS ( SELECT 1 FROM Rol WHERE unidadId_fk = @UNIDAD_ID and bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [Rol].'
            SET @CodeError = -1;
            RETURN;
        END


        IF EXISTS ( SELECT 1 FROM UnidadFeriado WHERE unidadId_pk = @UNIDAD_ID)
        BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: la unidad está vinculada a [UnidadFeriado].'
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS ( SELECT 1 FROM Unidad WHERE id = @UNIDAD_ID AND bEliminado = 0 )
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        -- Eliminación lógica
        UPDATE Unidad
            SET bEliminado = 1,
                nUpdatedBy = @USER,
                tUpdatedAt = SYSDATETIME()
            WHERE id = @UNIDAD_ID;

        SET @State = 1;
        SET @Message = 'Unidad eliminada correctamente';
        SET @CodeError = 0;
    
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO
 
/*======================================================================================================
Nombre: [dbo].[usp_deleteUsuarioDeHorario]
Autor: Gabriel Vasquez Uscuvilca
Fecha: 13-02-2026
OBJETIVO: Procedimiento para eliminar un usuario de un horario de cita

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
 -    -             -             -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_deleteUsuarioDeHorario]
  @HORARIO_ID INT,
  @ROL_USUARIO_ID INT,
  @USER INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

    DELETE FROM HorarioUsuario
    WHERE horarioId_fk = @HORARIO_ID AND rolUsuarioId_fk = @ROL_USUARIO_ID;

    SET @State = 1;
    SET @Message = 'Usuario eliminado del horario de cita correctamente.';
    SET @CodeError = 0;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;

    SET @State = 0;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
  END CATCH;

END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_DeleteVigencia]
FECHA: 30-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar (soft delete) una vigencia según su horario y fecha límite

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_DeleteVigencia]
    @VIGENCIA_ID INT,
    @HORARIO_DIA_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar existencia
        IF NOT EXISTS (
            SELECT 1
    FROM Vigencia
    WHERE id = @VIGENCIA_ID
        AND horarioDiasId_fk = @HORARIO_DIA_ID
        AND bEliminado = 0
        )
        BEGIN
        SET @State = -1;
        SET @Message = 'La vigencia no existe o ya fue eliminada.';
        SET @CodeError = -1;
        RETURN;
    END;

        UPDATE Vigencia
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @VIGENCIA_ID
        AND horarioDiasId_fk = @HORARIO_DIA_ID;

        SET @State = 1;
        SET @Message = 'Vigencia eliminada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
 
/*======================================================================================================
NOMBRE: [dbo].[usp_editarPermiso]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Actualizar registros en la tabla Permiso

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_editarPermiso]
  @PERMISO_ID INT,
  @MOTIVO_ID INT = NULL,
  @HORA_RETORNO_REAL TIME = NULL,
  @USER_ID INT,

  @State INT OUTPUT,
  @Message VARCHAR (255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE Permiso
  SET motivoId_fk = COALESCE(@MOTIVO_ID, motivoId_fk),
      tHoraRetornoReal = COALESCE(@HORA_RETORNO_REAL, tHoraRetornoReal),
      tUpdatedAt = GETDATE(),
      nCreatedBy = @USER_ID
  WHERE id = @PERMISO_ID
    AND bEliminado = 0;

  SET @State = 1;
  SET @Message = 'Permiso actualizado exitosamente.';
  SET @CodeError = 0;
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_EliminarAsistencia]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Elimina lógicamente un registro de asistencia (marcándolo como eliminado)

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_EliminarAsistencia]
    @ASISTENCIA_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (
            SELECT 1
            FROM AsistenciaRegular
            WHERE asistenciaId_fk = @ASISTENCIA_ID AND bEliminado = 0)
            BEGIN
            SET @State = -1;
            SET @Message = 'Operación no permitida: el está vinculada a [Asistencia Regular].';
            SET @CodeError = -1;
            ROLLBACK TRANSACTION;
            RETURN;
        END
        IF NOT EXISTS (
            SELECT 1
            FROM Asistencia
            WHERE id = @ASISTENCIA_ID AND bEliminado = 0)
            BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró la asistencia o ya fue eliminada.';
            SET @CodeError = -1;
            ROLLBACK TRANSACTION;
            RETURN;
        END

        UPDATE Asistencia
        SET bEliminado = 1,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ASISTENCIA_ID;

        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Asistencia eliminada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_EliminarFeriadoUnidad]
FECHA: 07-02-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Eliminar un feriado de una unidad organizativa.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_EliminarFeriadoUnidad]
  @UNIDAD_ID INT,
  @FECHA_FERIADO_ID INT,
  @State INT OUTPUT,
  @Message VARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    IF EXISTS (SELECT 1
      FROM UnidadFeriado
      WHERE unidadId_pk = @UNIDAD_ID
        AND fechaFeriadoId_pk = @FECHA_FERIADO_ID
    )
    BEGIN
      DELETE FROM UnidadFeriado
      WHERE unidadId_pk = @UNIDAD_ID
        AND fechaFeriadoId_pk = @FECHA_FERIADO_ID;

      SET @Message = 'Feriado para unidad eliminado correctamente.';
      SET @State = 1;
      SET @CodeError = 0;
    END
    ELSE
    BEGIN
      SET @Message = 'El feriado para la unidad organizativa no existe.';
      SET @State = -1;
      SET @CodeError = -1;
    END
  END TRY
  BEGIN CATCH
    SET @Message = ERROR_MESSAGE();
    SET @State = -1;
    SET @CodeError = ERROR_NUMBER();
  END CATCH

END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_eliminarGradoSupervisado]
FECHA: 18-02-2026
AUTOR: Gabriel
OBJETIVO: Eliminar lógicamente un grado supervisado

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   18-02-2026   Gabriel   Creación de procedimiento alineado al repository
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_eliminarGradoSupervisado]
  @ID_GRADO CHAR(3),
  @ROL_USUARIO_ID INT,
  @USER INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @Id INT OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
        SET @State = -1;
        SET @Message = 'No se pudo eliminar el registro.';
        SET @Id = NULL;
        SET @CodeError = 0;

        IF NOT EXISTS (
                SELECT 1
  FROM GradoSupervisado
  WHERE idGrado_pk = @ID_GRADO
    AND rolUsuarioId_pk = @ROL_USUARIO_ID
    AND bEliminado = 0
                )
        BEGIN
    SET @State = -2;
    SET @Message = 'El grado supervisado no existe o ya fue eliminado.';

    RETURN;
  END

        UPDATE GradoSupervisado
        SET bEliminado = 1
        WHERE idGrado_pk = @ID_GRADO
    AND rolUsuarioId_pk = @ROL_USUARIO_ID;

        IF (@@ROWCOUNT > 0)
        BEGIN
    SET @State = 0;
    SET @Message = 'Eliminación exitosa.';
    SET @Id = 0;
  END
        ELSE
        BEGIN
    SET @State = -1;
    SET @Message = 'No se afectó ningún registro.';
  END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @Id = NULL;
    END CATCH
END
GO
 

CREATE   PROCEDURE [dbo].[usp_eliminarHorarioCita]
  @ID_HORARIO INT,
  @USER INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    IF EXISTS (
      SELECT 1
  FROM HorarioUsuario
  WHERE horarioId_fk = @ID_HORARIO
    AND bEliminado = 0
    )
    BEGIN
    SET @State = -1;
    SET @Message = 'No se puede eliminar el horario de cita porque tiene usuarios asignados.';
    SET @CodeError = 0;
  END
    ELSE IF EXISTS (
      SELECT 1
  FROM Horario
  WHERE id = @ID_HORARIO
    AND bEliminado = 0
    )
    BEGIN
    UPDATE Horario
      SET bEliminado = 1,
          nUpdatedBy = @USER,
          tUpdatedAt = GETDATE()
      WHERE id = @ID_HORARIO
      AND bEliminado = 0;

    IF @@ROWCOUNT > 0
      BEGIN
      SET @State = 0;
      SET @Message = 'El horario de cita fue eliminado correctamente.';
      SET @CodeError = 0;
    END
      ELSE
      BEGIN
      SET @State = -1;
      SET @Message = 'No se pudo eliminar el horario de cita.';
      SET @CodeError = 0;
    END
  END
    ELSE
    BEGIN
    SET @State = -1;
    SET @Message = 'El horario de cita no existe o ya fue eliminado.';
    SET @CodeError = 0;
  END
  END TRY
  BEGIN CATCH
    SET @State = -2;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
  END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_eliminarJustificacion]
FECHA: 08-01-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Eliminar una justificación lógica en la tabla Justificacion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_eliminarJustificacion]
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
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_eliminarMarcarCita]
FECHA: 17-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite eliminar la marcacion de una cita solo si corresponde a la fecha actual.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCION
1     17-02-2026   Gabriel       Version inicial.
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_eliminarMarcarCita]
	@ID INT,
	@USER INT,
	@State INT OUTPUT,
	@Message VARCHAR(255) OUTPUT,
	@CodeError INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		IF NOT EXISTS (
			SELECT 1
			FROM Cita
			WHERE id = @ID AND bEliminado = 0
		)
		BEGIN
			SET @State = -1;
			SET @Message = 'La cita no existe.';
			RETURN;
		END

		IF EXISTS (
			SELECT 1
			FROM Cita
			WHERE id = @ID AND horaMarcacion IS NULL AND bEliminado = 0
		)
		BEGIN
			SET @State = -1;
			SET @Message = 'La cita no tiene una marcacion registrada.';
			RETURN;
		END

		IF EXISTS (
			SELECT 1
			FROM Cita
			WHERE id = @ID AND bEliminado = 0
				AND fecha <> CONVERT(DATE, GETDATE())
		)
		BEGIN
			SET @State = -1;
			SET @Message = 'Solo se puede eliminar la marcacion en la fecha de hoy.';
			RETURN;
		END

		UPDATE Cita
		SET horaMarcacion = NULL,
				nUpdatedBy = @USER,
				tUpdatedAt = GETDATE()
		WHERE id = @ID;

		IF @@ROWCOUNT > 0
		BEGIN
			SET @State = 0;
			SET @Message = 'La marcacion de la cita fue eliminada correctamente.';
		END
		ELSE
		BEGIN
			SET @State = -1;
			SET @Message = 'No se pudo eliminar la marcacion de la cita.';
		END
	END TRY
	BEGIN CATCH
		SET @State = -2;
		SET @Message = ERROR_MESSAGE();
		SET @CodeError = ERROR_NUMBER();
	END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_eliminarPermiso]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Eliminar un permiso lógico en la tabla Permiso

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_eliminarPermiso]
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
 

/*======================================================================================================
NOMBRE: [dbo].[usp_GenerarAsistenciaBatch]
FECHA: 10/02/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los horarios de múltiples usuarios y generar asistencias en batch para optimizar
el rendimiento cuando se procesan varios usuarios a la vez.

MODIFICACIONES:
NRO  FECHA       USUARIO              MODIFICACION
 1   10/02/2026  Gabriel Vasquez      Versión batch con TVP para múltiples usuarios
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GenerarAsistenciaBatch]
  @HorarioUsuarios HorarioUsuarioTableType READONLY,
  @FECHA DATE = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Primero calculamos la fecha final a usar
  DECLARE @FechaFinal DATE;
  SET @FechaFinal = ISNULL(@FECHA, CAST(GETDATE() AS DATE));

  DECLARE @DatosAsistencia TABLE
  (
    horarioId INT,
    horario NVARCHAR(100),
    dia NVARCHAR(50),
    turnoEntradaId INT,
    horaEntrada TIME,
    turnoSalidaId INT,
    horaSalida TIME,
    tipoTurno NVARCHAR(50),
    diaLibre NVARCHAR(2),
    conectadoDiaId INT,
    vigenciaInicio DATE,
    vigenciaFin DATE,
    rolUsuarioId INT -- Agregado para manejar múltiples usuarios
  );

  -- Usar @FechaFinal para calcular el día de la semana
  DECLARE @Dia NVARCHAR(50) = FORMAT(@FechaFinal, 'dddd', 'es-ES');
  DECLARE @DiaAnterior NVARCHAR(50) = FORMAT(DATEADD(DAY, -1, @FechaFinal), 'dddd', 'es-ES');

  -- CTE que procesa TODOS los horarios y usuarios en una sola consulta
  WITH
    TurnosNumerados
    AS
    (
      SELECT
        h.id AS horarioId,
        h.cTitulo AS horario,
        d.cTitulo AS dia,
        d.id AS diaId,
        hd.bLibre,
        tr.id AS turnoRegularId,
        tr.horaInicio AS horaTurnoRegular,
        te.id AS turnoExtendidoId,
        te.horaInicio AS horaTurnoExtendido,
        te.horaFin AS horaFinTurnoExtendido,
        -- Identificar tipo de turno
        CASE 
          WHEN te.id IS NOT NULL THEN 'Extendido'
          WHEN tr.id IS NOT NULL THEN 'Regular'
          ELSE NULL
        END AS tipoTurno,
        -- Numerar los turnos regulares por día
        ROW_NUMBER() OVER (PARTITION BY hu.RolUsuarioId, hd.id ORDER BY COALESCE(tr.horaInicio, te.horaInicio)) AS numeroTurno,
        cd.diasId_pk AS conectadoDiaId,
        v.tFechaInicio AS vigenciaInicio,
        v.tFechaFin AS vigenciaFin,
        hu.RolUsuarioId
      -- Incluir el RolUsuarioId
      FROM @HorarioUsuarios hu -- JOIN con la tabla de parámetros
        INNER JOIN Horario h ON h.id = hu.HorarioId
        INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
        INNER JOIN Dia d ON d.id = hd.diaId_fk
        LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id
        LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id
        LEFT JOIN ConectadoDias cd ON cd.turnoExtendidoId_pk = te.id
        LEFT JOIN Vigencia v ON v.horarioDiasId_fk = hd.id AND v.bActivo = 1
      WHERE h.id = hu.HorarioId AND @FechaFinal BETWEEN v.tFechaInicio AND v.tFechaFin
    ),
    TurnosEmparejados
    AS
    (
      SELECT
        t1.horarioId,
        t1.horario,
        t1.dia,
        t1.diaId,
        t1.bLibre,
        -- Turno de entrada
        COALESCE(t1.turnoRegularId, t1.turnoExtendidoId) AS turnoEntradaId,
        COALESCE(t1.horaTurnoRegular, t1.horaTurnoExtendido) AS horaEntrada,
        -- Turno de salida
        COALESCE(t2.turnoRegularId, t1.turnoExtendidoId) AS turnoSalidaId,
        COALESCE(t2.horaTurnoRegular, t1.horaFinTurnoExtendido) AS horaSalida,
        -- Tipo de turno
        t1.tipoTurno,
        t1.conectadoDiaId,
        t1.vigenciaInicio,
        t1.vigenciaFin,
        t1.rolUsuarioId
      FROM TurnosNumerados t1
        LEFT JOIN TurnosNumerados t2
        ON t1.diaId = t2.diaId
          AND t1.rolUsuarioId = t2.rolUsuarioId -- También matchear por usuario
          AND t1.numeroTurno % 2 = 1 -- Solo turnos impares (entrada)
          AND t2.numeroTurno = t1.numeroTurno + 1
      -- El siguiente turno (salida)
      WHERE t1.numeroTurno % 2 = 1 OR t1.turnoExtendidoId IS NOT NULL
    )

  -- Insertar todos los datos filtrados en la tabla temporal
  INSERT INTO @DatosAsistencia
    (
    horarioId,
    horario,
    dia,
    turnoEntradaId,
    horaEntrada,
    turnoSalidaId,
    horaSalida,
    tipoTurno,
    diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin,
    rolUsuarioId
    )
  SELECT
    horarioId,
    horario,
    dia,
    turnoEntradaId,
    horaEntrada,
    turnoSalidaId,
    horaSalida,
    tipoTurno,
    CASE WHEN bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin,
    rolUsuarioId
  FROM TurnosEmparejados
  WHERE 
    (turnoEntradaId IS NOT NULL OR bLibre = 1)
    AND (
      (dia COLLATE SQL_Latin1_General_CP1_CI_AI = @Dia AND turnoEntradaId IS NOT NULL)
    OR (dia COLLATE SQL_Latin1_General_CP1_CI_AI = @DiaAnterior AND tipoTurno = 'Extendido')
    );

  -- Insertar TODAS las asistencias en una sola operación
  INSERT INTO Asistencia
    (
    horaEntrada,
    horaSalida,
    vigenciaFin,
    vigenciaInicio,
    rolUsuarioid_fk,
    tFecha,
    tCreatedAt,
    turnoEntradaid,
    turnoSalidaid,
    nCreatedBy,
    esRegular
    )
  SELECT
    d.horaEntrada,
    d.horaSalida,
    d.vigenciaFin,
    d.vigenciaInicio,
    d.rolUsuarioId,
    @FechaFinal,
    GETDATE(),
    d.turnoEntradaId,
    d.turnoSalidaId,
    1,
    CASE WHEN d.conectadoDiaId IS NOT NULL THEN 0 ELSE 1 END AS esRegular
  FROM @DatosAsistencia d
  WHERE NOT EXISTS (
    SELECT 1
  FROM Asistencia a
  WHERE a.rolUsuarioid_fk = d.rolUsuarioId
    AND ISNULL(a.turnoEntradaid, -1) = ISNULL(d.turnoEntradaId, -1)
    AND ISNULL(a.turnoSalidaid, -1) = ISNULL(d.turnoSalidaId, -1)
    AND a.tFecha = @FechaFinal
  );

  -- Retornar TODAS las asistencias generadas
  SELECT
    a.id,
    a.horaEntrada,
    a.horaSalida,
    a.vigenciaFin,
    a.vigenciaInicio,
    a.turnoEntradaid,
    a.turnoSalidaid,
    a.tFecha,
    a.rolUsuarioid_fk AS rolUsuarioId,
    a.esRegular
  FROM Asistencia a
    INNER JOIN @HorarioUsuarios hu ON hu.RolUsuarioId = a.rolUsuarioid_fk
  WHERE  a.tFecha = @FechaFinal
  ORDER BY a.rolUsuarioid_fk, a.horaEntrada;

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_generarAsistenciaWithFecha]
FECHA: 20/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los horarios de un usuario a partir de su RolUsuarioId y genear asistencia a partir
del horario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   20/02/2026  Gabriel    Se agregó filtro de vigencia para los horarios
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_generarAsistenciaWithFecha]
  @HORARIO_ID INT,
  @ROL_USUARIO_ID INT,
  @FECHA DATE
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @DatosAsistencia TABLE
        (
    horarioId INT,
    horario NVARCHAR(100),
    dia NVARCHAR(50),
    turnoEntradaId INT,
    horaEntrada TIME,
    turnoSalidaId INT,
    horaSalida TIME,
    tipoTurno NVARCHAR(50),
    diaLibre NVARCHAR(2),
    conectadoDiaId INT,
    vigenciaInicio DATE,
    vigenciaFin DATE
        );

  DECLARE @Dia NVARCHAR(50) = FORMAT(@FECHA, 'dddd', 'es-ES');
  DECLARE @DiaAnterior NVARCHAR(50) = FORMAT(DATEADD(DAY, -1, @FECHA), 'dddd', 'es-ES');

  WITH
    TurnosNumerados
    AS
    (
      SELECT
        h.id AS horarioId,
        h.cTitulo AS horario,
        d.cTitulo AS dia,
        d.id AS diaId,
        hd.bLibre,
        tr.id AS turnoRegularId,
        tr.horaInicio AS horaTurnoRegular,
        te.id AS turnoExtendidoId,
        te.horaInicio AS horaTurnoExtendido,
        te.horaFin AS horaFinTurnoExtendido,
        -- Identificar tipo de turno
        CASE 
                WHEN te.id IS NOT NULL THEN 'Extendido'
                WHEN tr.id IS NOT NULL THEN 'Regular'
                ELSE NULL
              END AS tipoTurno,
        -- Numerar los turnos regulares por día
        ROW_NUMBER() OVER (PARTITION BY hd.id ORDER BY COALESCE(tr.horaInicio, te.horaInicio)) AS numeroTurno,
        cd.diasId_pk AS conectadoDiaId,
        v.tFechaInicio AS vigenciaInicio,
        v.tFechaFin AS vigenciaFin
      FROM Horario h
        INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
        INNER JOIN Dia d ON d.id = hd.diaId_fk
        LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id
        LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id
        LEFT JOIN ConectadoDias cd on cd.turnoExtendidoId_pk = te.id
        LEFT JOIN Vigencia v on v.horarioDiasId_fk = hd.id and v.bActivo = 1
      WHERE h.id = @HORARIO_ID AND @FECHA BETWEEN v.tFechaInicio AND v.tFechaFin

    ),
    TurnosEmparejados
    AS
    (
      SELECT
        t1.horarioId,
        t1.horario,
        t1.dia,
        t1.diaId,
        t1.bLibre,
        -- Turno de entrada
        COALESCE(t1.turnoRegularId, t1.turnoExtendidoId) AS turnoEntradaId,
        COALESCE(t1.horaTurnoRegular, t1.horaTurnoExtendido) AS horaEntrada,
        -- Turno de salida
        COALESCE(t2.turnoRegularId, t1.turnoExtendidoId) AS turnoSalidaId,
        COALESCE(t2.horaTurnoRegular, t1.horaFinTurnoExtendido) AS horaSalida,
        -- Tipo de turno
        t1.tipoTurno,
        t1.conectadoDiaId,
        t1.vigenciaInicio,
        t1.vigenciaFin
      FROM TurnosNumerados t1
        LEFT JOIN TurnosNumerados t2
        ON t1.diaId = t2.diaId
          AND t1.numeroTurno % 2 = 1 -- Solo turnos impares (entrada)
          AND t2.numeroTurno = t1.numeroTurno + 1
      -- El siguiente turno (salida)
      WHERE t1.numeroTurno % 2 = 1 OR t1.turnoExtendidoId IS NOT NULL
    )

  INSERT INTO @DatosAsistencia
    (
    horarioId,
    horario,
    dia,
    turnoEntradaId,
    horaEntrada,
    turnoSalidaId,
    horaSalida,
    tipoTurno,
    diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin
    )
  SELECT
    horarioId,
    horario,
    dia,
    turnoEntradaId,
    horaEntrada,
    turnoSalidaId,
    horaSalida,
   tipoTurno,
    CASE WHEN bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin
  FROM TurnosEmparejados
  WHERE             
            (turnoEntradaId IS NOT NULL OR bLibre = 1)
    AND dia COLLATE SQL_Latin1_General_CP1_CI_AI = @Dia AND turnoEntradaId IS NOT NULL
    OR ( dia COLLATE SQL_Latin1_General_CP1_CI_AI = @DiaAnterior and tipoTurno = 'Extendido');

  INSERT INTO Asistencia
    (horaEntrada, horaSalida, vigenciaFin, vigenciaInicio, rolUsuarioid_fk, tFecha, tCreatedAt, turnoEntradaid, turnoSalidaid, nCreatedBy, esRegular)
  SELECT
    d.horaEntrada,
    d.horaSalida,
    d.vigenciaFin,
    d.vigenciaInicio,
    @ROL_USUARIO_ID, -- RolUsuarioId
    CAST(@FECHA AS DATE),
    GETDATE(),
    d.turnoEntradaId,
    d.turnoSalidaId,
    1,
    CASE WHEN d.conectadoDiaId is not null then 0 else 1 end as esRegular
  FROM @DatosAsistencia d
  WHERE NOT EXISTS (
            SELECT 1
  FROM Asistencia a
  WHERE a.rolUsuarioid_fk = @ROL_USUARIO_ID
    AND ISNULL(a.turnoEntradaid, -1) = ISNULL(d.turnoEntradaId, -1)
    AND ISNULL(a.turnoSalidaid, -1) = ISNULL(d.turnoSalidaId, -1)
    AND a.tFecha = CAST(@FECHA AS DATE)
          );

  SELECT
    id,
    horaEntrada,
    horaSalida,
    vigenciaFin,
    vigenciaInicio,
    turnoEntradaid,
    turnoSalidaid,
    tFecha,
    rolUsuarioid_fk rolUsuarioId,
    esRegular
  FROM Asistencia
  WHERE rolUsuarioid_fk = @ROL_USUARIO_ID AND tFecha = CAST(@FECHA AS DATE);

END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetAllRolUsuario]
FECHA: 20-01-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite listar todas los RolUsuario existentes por usuarioId.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetAllRolUsuario]
  @USUARIO_ID INT,
  @UNIDAD_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT RU.id
        , RU.usuarioId_fk AS usuarioId
        , U.cUsuario AS usuario
        , RU.rolId_fk AS rolId
        , R.cTitulo AS rol
  FROM RolUsuario AS RU
    INNER JOIN Rol AS R
    ON RU.rolId_fk = R.id
    INNER JOIN Sync_Usuario AS U
    ON RU.usuarioId_fk = U.id
  WHERE RU.usuarioId_fk = @USUARIO_ID AND R.unidadId_fk = @UNIDAD_ID AND RU.bEliminado = 0;

END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetAreasAcademicas]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener las áreas académicas disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetAreasAcademicas]
  @TEMPORADA_ID INT,
  @NIVEL_ID INT,
  @CENTRO_ESTUDIOS_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    idAreaAcademica AS id,
    areaAcademica AS areaAcademica
  FROM
    Sync_CursoSeccionPreUniversitaria
  WHERE 
    idTemporada = @TEMPORADA_ID
    AND idNivel = @NIVEL_ID
    AND idCentroEstudios = @CENTRO_ESTUDIOS_ID
  GROUP BY 
    idAreaAcademica, areaAcademica
  ORDER BY 
    areaAcademica ASC;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistencia]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar una asistencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetAsistencia]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT id, horaEntrada, horaSalida
    FROM Asistencia
    WHERE 
        id = @ASISTENCIA_ID AND
        bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistenciaExtendida]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listas las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetAsistenciaExtendida]
AS
BEGIN
    SELECT AE.Id AS id
        , AE.turnoExtendidoId_fk AS id_turno
        , AE.asistenciaId_fk AS id_asistencia
        , AE.marcacionId_fk AS id_marcacion
        , AE.detalleBiometricoId_fk AS id_biometrico
        , CONVERT(CHAR(10),A.tFecha,103) AS fecha
        , DB.cNombre AS biometrico
        , DB.ubicacion AS ubicacion
        , CONVERT(CHAR(8),M.punch_time,108) AS hora
    FROM AsistenciaExtendida AE
    INNER JOIN Asistencia A ON AE.asistenciaId_fk = A.id
    INNER JOIN DetalleBiometrico DB ON AE.detalleBiometricoId_fk = DB.id
    INNER JOIN Marcacion M ON AE.marcacionId_fk = M.id
    WHERE AE.bEliminado = 0
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistenciaExtendidaById]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listas las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetAsistenciaExtendidaById]
@ID INT
AS
BEGIN
    SELECT AE.Id AS id
        , AE.turnoExtendidoId_fk AS id_turno
        , AE.asistenciaId_fk AS id_asistencia
        , AE.marcacionId_fk AS id_marcacion
        , AE.detalleBiometricoId_fk AS id_biometrico
        , CONVERT(CHAR(10), A.tFecha, 103) AS fecha
        , DB.cNombre AS biometrico
        , DB.ubicacion AS ubicacion
        , CONVERT(CHAR(8), M.punch_time, 108) AS hora
    FROM AsistenciaExtendida AE
    INNER JOIN Asistencia A ON AE.asistenciaId_fk = A.id
    INNER JOIN DetalleBiometrico DB ON AE.detalleBiometricoId_fk = DB.id
    INNER JOIN Marcacion M ON AE.marcacionId_fk = M.id
    WHERE AE.bEliminado = 0 AND AE.Id = @ID
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getAsistenciaId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener los datos de una asistencia por su Id, incluyendo permisos, justificaciones y turnos modificados.

MODIFICACIONES:
NRO  FECHA          USUARIO                      MODIFICACION
     
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getAsistenciaId]
  @FECHA DATE,
  @TURNO_ID INT,
  @ROL_USUARIO_ID INT,
  @ES_REGULAR BIT = 1
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    a.id asistenciaId
  FROM Asistencia a
  WHERE CAST(a.tFecha AS DATE) = @FECHA
    AND a.rolUsuarioId_fk = @ROL_USUARIO_ID
    AND a.turnoEntradaid = @TURNO_ID
    AND a.bEliminado = 0
    AND a.esRegular = @ES_REGULAR;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistenciaRegular]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listas las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetAsistenciaRegular]
AS
BEGIN
    SELECT AR.Id AS id
        , AR.turnoRegularId_fk AS id_turno
        , AR.asistenciaId_fk AS id_asistencia
        , AR.marcacionId_fk AS id_marcacion
        , AR.detalleBiometricoId_fk AS id_detalleBiometrico
        , U.cUsuario AS usuario
        , U.cNombre AS nombre
        , RU.usuarioId_fk AS id_usuario
        , CONVERT(CHAR(10),A.tFecha,103) AS fecha
        , DB.cNombre AS biometrico
        , DB.ubicacion AS ubicacion
        , CONVERT(CHAR(8),M.punch_time,108) AS hora
    FROM AsistenciaRegular AR
        INNER JOIN Asistencia A ON AR.asistenciaId_fk = A.id
        INNER JOIN Marcacion M ON AR.marcacionId_fk = M.id
        INNER JOIN Sync_Usuario U ON M.emp_id = U.id
        INNER JOIN RolUsuario RU ON U.id = RU.usuarioId_fk
        INNER JOIN DetalleBiometrico DB ON AR.detalleBiometricoId_fk = DB.id
        INNER JOIN TurnoRegular TR ON AR.turnoRegularId_fk = TR.id
    WHERE AR.bEliminado = 0
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetAsistenciaRegularById]
FECHA: 18-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listas las asistencias regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetAsistenciaRegularById]
@ID INT
AS
BEGIN
    SELECT AR.Id AS id
        , AR.turnoRegularId_fk AS id_turno
        , AR.asistenciaId_fk AS id_asistencia
        , AR.marcacionId_fk AS id_marcacion
        , AR.detalleBiometricoId_fk AS id_detalleBiometrico
        , CONVERT(CHAR(10), A.tFecha, 103) AS fecha
        , DB.cNombre AS biometrico
        , DB.ubicacion AS ubicacion
        , CONVERT(CHAR(8), M.punch_time, 108) AS hora
    FROM AsistenciaRegular AR 
    INNER JOIN Asistencia A ON AR.asistenciaId_fk = A.id
    INNER JOIN Marcacion M ON AR.marcacionId_fk = M.id
    INNER JOIN DetalleBiometrico DB ON AR.detalleBiometricoId_fk = DB.id
    INNER JOIN TurnoRegular TR ON AR.turnoRegularId_fk = TR.id
    WHERE AR.bEliminado = 0 AND AR.id = @ID
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getAsistenciasCalendario]
FECHA: 11-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los usuarios con sus roles

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getAsistenciasCalendario]
  @ROL_USUARIO_ID INT,
  @HORARIO_ID INT,
  @MES VARCHAR(15),
  @ANIO VARCHAR(4)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    distinct
    a.id asistenciaId,
    tr.horaInicio,
    a.horaEntrada,
    a.horaSalida,
    d.cTitulo dia,
    a.tFecha fecha ,
    hd.horarioId_fk horarioId,
    a.turnoEntradaid,
    a.turnoSalidaid,
    CASE
      WHEN cru.nMinutosTarde is not null THEN cru.nMinutosTarde
      WHEN cua.nMinutosTarde is not null THEN cua.nMinutosTarde
      WHEN crua.nMinutosTarde is not null THEN crua.nMinutosTarde
      ELSE 0
    END AS minutosTardanza,
    CASE
      WHEN cru.id IS NOT NULL THEN ea.cNombre
      WHEN cua.id IS NOT NULL THEN ea2.cNombre
      WHEN crua.id IS NOT NULL THEN ea3.cNombre
      ELSE 'Pendiente'
    END AS tipoAsistencia
  FROM Asistencia a
    INNER JOIN TurnoRegular tr on tr.id = a.turnoEntradaid
    INNER JOIN HorarioDias hd on hd.id = tr.horarioDiasId_fk
    INNER JOIN Dia d on d.id = hd.diaId_fk
    LEFT JOIN RolControlAsistencia cru on cru.asistenciaId_fk = a.id
    LEFT JOIN EstadoAsistencia ea on ea.id = cru.estadoAsistenciaId_fk
    LEFT JOIN ControlUnidadAsistencia cua on cua.asistenciaId_fk = a.id
    LEFT JOIN EstadoAsistencia ea2 on ea2.id = cua.estadoAsistenciaId_fk
    LEFT JOIN ControlRolUsuarioAsistencia crua on crua.asistenciaId_fk = a.id
    LEFT JOIN EstadoAsistencia ea3 on ea3.id = crua.estadoAsistenciaId_fk
  WHERE rolUsuarioid_fk = @ROL_USUARIO_ID and hd.horarioId_fk = @HORARIO_ID

    AND YEAR(a.tFecha) = @ANIO AND MONTH(a.tFecha) = @MES
    and a.bEliminado = 0 and tr.bEliminado = 0 and hd.bEliminado = 0 and d.bEliminado = 0
    and (cru.bEliminado = 0 or cru.bEliminado is null) and (cua.bEliminado = 0 or cua.bEliminado is null) and (crua.bEliminado = 0 or crua.bEliminado is null)
  ORDER BY a.tFecha
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_getAsistenciasPorId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener los datos de una asistencia por su Id, incluyendo permisos, justificaciones y turnos modificados.

MODIFICACIONES:
NRO  FECHA          USUARIO                      MODIFICACION
 1   26-01-2026     Gabriel Vásquez Uscuvilca    Se agregó verificación de permisos, justificaciones y turnos modificados
 2   27-01-2026     Gabriel Vásquez Uscuvilca    Se cambió a devolver listas de permisos y justificaciones con sus turnos
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getAsistenciasPorId]
  @ASISTENCIA_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @FECHA DATE;
  DECLARE @ROL_USUARIO_ID INT;

  -- Obtener la fecha y rolUsuarioId de la asistencia
  SELECT
    @FECHA = CAST(tFecha AS DATE),
    @ROL_USUARIO_ID = rolUsuarioId_fk
  FROM Asistencia
  WHERE id = @ASISTENCIA_ID AND bEliminado = 0;

  -- Si no existe la asistencia, retornar vacío
  IF @FECHA IS NULL
  BEGIN
    SELECT
      NULL AS id,
      NULL AS fecha,
      NULL AS rolUsuarioId,
      NULL AS horaEntrada,
      NULL AS horaSalida,
      NULL AS vigenciaInicio,
      NULL AS vigenciaFin,
      NULL AS turnoEntradaId,
      NULL AS turnoSalidaId,
      NULL AS esRegular,
      NULL AS tieneTurnoModificado,
      NULL AS turnoModificadoId,
      NULL AS turnoModificadoHora,
      NULL AS turnoModificadoTipo,
      NULL AS permisos,
      NULL AS justificaciones;

    RETURN;
  END

  -- PRIMER RESULTSET: Datos de asistencia con arrays JSON de permisos y justificaciones
  SELECT
    a.id,
    a.tFecha AS fecha,
    a.rolUsuarioid_fk AS rolUsuarioId,
    a.horaEntrada,
    a.horaSalida,
    a.vigenciaInicio,
    a.vigenciaFin,
    a.turnoEntradaId,
    a.turnoSalidaId,
    a.esRegular,

    -- Verificación de Turno Modificado
    CASE 
      WHEN EXISTS (
        SELECT 1
    FROM TurnoModificado tm
    WHERE tm.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND @FECHA BETWEEN tm.fechaInicio AND tm.fechaFin
      AND tm.bEliminado = 0
      ) THEN 1 
      ELSE 0 
    END AS tieneTurnoModificado,

    (SELECT TOP 1
      tm.id
    FROM TurnoModificado tm
    WHERE tm.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND @FECHA BETWEEN tm.fechaInicio AND tm.fechaFin
      AND tm.bEliminado = 0
    ) AS turnoModificadoId,

    (SELECT TOP 1
      tm.tHora
    FROM TurnoModificado tm
    WHERE tm.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND @FECHA BETWEEN tm.fechaInicio AND tm.fechaFin
      AND tm.bEliminado = 0
    ) AS turnoModificadoHora,

    (SELECT TOP 1
      tm.btipo
    FROM TurnoModificado tm
    WHERE tm.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND @FECHA BETWEEN tm.fechaInicio AND tm.fechaFin
      AND tm.bEliminado = 0
    ) AS turnoModificadoTipo,

    -- Array JSON de permisos con sus turnos
    (
      SELECT
      p.id AS permisoId,
      COALESCE(ptr.turnoRegularId_pk, pte.turnoExtendidoId_pk) AS turnoId,
      CASE WHEN pte.permisoId_pk IS NOT NULL THEN 1 ELSE 0 END AS esExtendido
    FROM Permiso p
      LEFT JOIN PermisoTurnoRegular ptr ON p.id = ptr.permisoId_pk
      LEFT JOIN PermisoTurnoExtendido pte ON p.id = pte.permisoId_pk
    WHERE p.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND p.tfecha = @FECHA
      AND p.bEliminado = 0
      AND (ptr.turnoRegularId_pk IS NOT NULL OR pte.turnoExtendidoId_pk IS NOT NULL)
    FOR JSON PATH
    ) AS permisos,

    -- Array JSON de justificaciones con sus turnos
    (
      SELECT
      j.id AS justificacionId,
      COALESCE(jtr.turnoRegularId_fk, jte.turnoExtendidoId_fk) AS turnoId,
      CASE WHEN jte.justificacionId_fk IS NOT NULL THEN 1 ELSE 0 END AS esExtendido
    FROM Justificacion j
      LEFT JOIN JustificacionTurnoRegular jtr ON j.id = jtr.justificacionId_fk
      LEFT JOIN JustificacionTurnoExtendido jte ON j.id = jte.justificacionId_fk
    WHERE j.rolUsuarioId_fk = @ROL_USUARIO_ID
      AND j.fecha = @FECHA
      AND j.bEliminado = 0
      AND (jtr.turnoRegularId_fk IS NOT NULL OR jte.turnoExtendidoId_fk IS NOT NULL)
    FOR JSON PATH
    ) AS justificaciones

  FROM Asistencia a
  WHERE a.id = @ASISTENCIA_ID AND a.bEliminado = 0;
END
GO



/*======================================================================================================
NOMBRE: [dbo].[usp_GetBiometricos]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite listar todos los biometricos activos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetBiometricos]
AS
BEGIN
    SELECT B.id
        , B.marca
        , B.tipoBD
        , CASE 
            WHEN COUNT(DB.id) > 0
                THEN 1
            ELSE 0
            END AS enUso
    FROM Biometrico AS B
    LEFT JOIN DetalleBiometrico AS DB
        ON DB.biometricoId_fk = B.id
            AND DB.bEliminado = 0
    WHERE B.bEliminado = 0
    GROUP BY B.id
        , B.marca
        , B.tipoBD;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetBiometricoWithDetalle]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite obtener la lista de todos los biometricos con todos sus detalles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetBiometricoWithDetalle] @BIOMETRICOID INT
AS
BEGIN
    SELECT B.id
        , B.marca
        , B.tipoBD
        , DB.cNombre
        , DB.ip
        , DB.ubicacion
        , DB.serie
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , CASE 
            WHEN COUNT(DB.id) > 0
                THEN 1
            ELSE 0
            END AS enUso
    FROM Biometrico AS B
    LEFT JOIN DetalleBiometrico AS DB
        ON DB.biometricoId_fk = B.id
            AND DB.bEliminado = 0
    WHERE B.id = @BIOMETRICOID
        AND B.bEliminado = 0
    GROUP BY B.id
        , B.marca
        , B.tipoBD
        , DB.biometricoId_fk
        , DB.cNombre
        , DB.ip
        , DB.ubicacion
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , DB.serie;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetCentroDeEstudios]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los centros de estudios disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCentroDeEstudios]
  @TEMPORADA_ID INT,
  @NIVEL_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    idCentroEstudios AS id,
    centroEstudios AS centroEstudios
  FROM
    Sync_CursoSeccionPreUniversitaria
  WHERE idNivel = @NIVEL_ID
    AND idTemporada = @TEMPORADA_ID
  GROUP BY 
    idCentroEstudios, centroEstudios
  ORDER BY 
    idCentroEstudios DESC;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getCitasByUsuarioId]
FECHA: 13-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los horarios para una cita.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
-      -             -           -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getCitasByUsuarioId]
  @ROL_USUARIO_ID INT,
  @HORARIO_ID INT
AS
BEGIN
  SET NOCOUNT ON;
  SELECT
    c.id,
    c.nombre,
    c.cDescripcion AS descripcion,
    c.bCancelado AS cancelado,
    c.hora,
    c.fecha,
    c.horaMarcacion
  FROM Cita c
    INNER JOIN HorarioUsuario hu on hu.id = c.horarioUsuarioId_fk
  WHERE hu.rolUsuarioId_fk = @ROL_USUARIO_ID AND hu.horarioId_fk = @HORARIO_ID AND c.bEliminado = 0
  ORDER BY c.fecha DESC, c.hora DESC;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetConectadoDiasByIds]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Obtener un registro de ConectadoDias por IDs.
          
MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetConectadoDiasByIds] @TURNOEXTENDIDOID INT
    , @DIASID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CD.turnoExtendidoId_pk
        , CD.diasId_pk
        , D.cTitulo AS Dia
        , TE.horaInicio
        , TE.horaFin
        -- , HD.id AS HorarioDiasId
        -- , HD.horarioId_fk AS HorarioId
    FROM ConectadoDias AS CD
    INNER JOIN Dia AS D
        ON CD.diasId_pk = D.id
    INNER JOIN TurnoExtendido AS TE
        ON CD.turnoExtendidoId_pk = TE.id
    -- INNER JOIN HorarioDias AS HD
    --     ON TE.horarioDiasId_fk = HD.id
    WHERE CD.turnoExtendidoId_pk = @TURNOEXTENDIDOID
        AND CD.diasId_pk = @DIASID
        AND D.bEliminado = 0
        AND TE.bEliminado = 0
        -- AND HD.bEliminado = 0
    GROUP BY CD.turnoExtendidoId_pk
        , CD.diasId_pk
        , D.cTitulo
        , TE.horaInicio
        , TE.horaFin
        -- , HD.id
        -- , HD.horarioId_fk;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlesRolUsuario]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles de rolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetControlesRolUsuario]
    @ROL_CONTROL_ID INT
AS
BEGIN
    SELECT 
        cru.id AS id,
        cru.rolUsuarioId_fk AS rolUsuarioId,
        cru.controlId_fk AS controlId,
        R.cTitulo AS rol,
        SU.cUsuario AS usuario,
        SU.cNombre+' '+SU.cApellido AS nombre,
        SUN.cTitulo AS unidad,
        c.nLimiteFalta AS limiteFalta,
        c.nLimiteMarcacion AS limiteMarcacion,
        c.nTolerancia AS tolerancia,
        CASE 
            WHEN EXISTS (SELECT 1 FROM ControlRolUsuarioAsistencia CRUA WHERE CRUA.controlRolUsuarioId_fk = cru.id)
            THEN 1
        ELSE 0 
        END AS uso
    FROM ControlRolUsuario cru
        INNER JOIN CONTROLES c on c.Id = cru.controlId_fk
        INNER JOIN RolUsuario RU ON cru.rolUsuarioId_fk = RU.id
        INNER JOIN Rol R on RU.rolId_fk = R.id
        INNER JOIN Unidad U ON R.unidadId_fk = U.id
        INNER JOIN Sync_Unidad SUN ON U.unidadOrgId_fk = SUN.id
        INNER JOIN Sync_Usuario SU ON RU.usuarioId_fk = SU.id

    WHERE 
        cru.bEliminado = 0 AND
        c.bEliminado = 0 AND
        -- (@ROL_USUARIO_ID IS NULL OR cru.rolUsuarioId_fk = @ROL_USUARIO_ID);
        cru.controlId_fk = @ROL_CONTROL_ID;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlesUnidad]
FECHA: 26-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles por unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE    PROCEDURE [dbo].[usp_GetControlesUnidad]
    @UNIDAD_ID INT = NULL
AS
BEGIN
    SELECT 
        cu.unidadId_fk AS unidadId,
        c.nLimiteFalta AS limiteFalta,
        c.nLimiteMarcacion AS limiteMarcacion,
        c.nTolerancia AS tolerancia
    FROM ControlUnidad cu
        INNER JOIN Controles c on c.Id = cu.controlId_fk
    WHERE 
        cu.bEliminado = 0 AND
        c.bEliminado = 0 AND
        (@UNIDAD_ID IS NULL OR cu.unidadId_fk = @UNIDAD_ID);
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getControlPorRolUsuarioId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Reprocesar asistencia de usuarios en el sistema.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getControlPorRolUsuarioId]
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
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlRoles]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles por rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
01   16-12-2025  fluna      Añadir nombre de rol y unidad
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetControlRoles]
    @ROL_CONTROL_ID INT
AS
BEGIN
    SELECT rc.id AS id
           , rc.rolId_fk AS rolId
        , R.cTitulo AS rol
        , SU.cTitulo AS unidad
        , c.nLimiteFalta AS limiteFalta
        , c.nLimiteMarcacion AS limiteMarcacion
        , c.nTolerancia AS tolerancia
        ,  CASE 
            WHEN EXISTS (SELECT 1 FROM RolControlAsistencia RCA WHERE RCA.rolControlId_fk = rc.id)
            THEN 1
        ELSE 0 
        END AS uso
    FROM RolControl rc
        INNER JOIN CONTROLES c ON c.Id = rc.controlId_fk
        INNER JOIN ROL R ON rc.rolId_fk = R.id
        INNER JOIN Unidad U ON R.unidadId_fk = U.id
        INNER JOIN Sync_Unidad SU on U.unidadOrgId_fk = SU.id
    WHERE rc.bEliminado = 0
        AND c.bEliminado = 0
        AND
        rc.controlId_fk = @ROL_CONTROL_ID;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlRolUsuarioAsistencia]
FECHA: 26-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener el estado de la asistencia con el control que se usó en este caso [ControlRolUsuario]

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE    PROCEDURE [dbo].[usp_GetControlRolUsuarioAsistencia]
    @ID INT = NULL,
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT
        cru.id,
        a.id as asistenciaId,
        ea.id as estadoAsistenciaId,
        ea.cNombre as estadoAsitencia,
        c.nTolerancia as tolerancia,
        c.nLimiteFalta as limiteFalta,
        c.nLimiteMarcacion as limiteMarcacion,
        cru.id rolControlId
    FROM ControlRolUsuarioAsistencia crua
        INNER JOIN ControlRolUsuario cru on cru.id = crua.controlRolUsuarioId_fk
        INNER JOIN [Controles] c on c.id = cru.controlId_fk
        INNER JOIN EstadoAsistencia ea on ea.id = crua.estadoAsistenciaId_fk
        INNER JOIN Asistencia a on a.id = crua.asistenciaId_fk
    WHERE 
        cru.bEliminado = 0 AND
        crua.bEliminado = 0 AND
        cru.bEliminado = 0 AND
        c.bEliminado = 0 AND
        ea.bEliminado = 0 AND
        a.bEliminado = 0 AND
       -- (@ID IS NULL OR crua.id = @ID) AND
        (@ASISTENCIA_ID IS NULL OR a.id = @ASISTENCIA_ID)
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlUnidadAsistenciaEstado]
FECHA: 26-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Visualizar el estado de asistencia 

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetControlUnidadAsistenciaEstado]
    @ID INT = NULL,
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT
        a.id as asistenciaId,
        ea.id as estadoAsistenciaId,
        ea.cNombre as estadoAsitencia,
        c.nTolerancia as tolerancia,
        c.nLimiteFalta as limiteFalta,
        c.nLimiteMarcacion as limiteMarcacion,
        cu.id CONTROL_UNIDAD_ID
    FROM ControlUnidadAsistencia cua
        INNER JOIN ControlUnidad cu on cu.id = cua.controlUnidadId_fk
        INNER JOIN Controles c on c.id = cu.controlId_fk
        INNER JOIN EstadoAsistencia ea on ea.id = cua.estadoAsistenciaId_fk
        INNER JOIN Asistencia a on a.id = cua.asistenciaId_fk
    WHERE 
        cu.bEliminado = 0 AND
        cua.bEliminado = 0 AND
        cu.bEliminado = 0 AND
        c.bEliminado = 0 AND
        ea.bEliminado = 0 AND
        a.bEliminado = 0 AND
        (@ID IS NULL OR cua.id = @ID) AND
        (@ASISTENCIA_ID IS NULL OR a.id = @ASISTENCIA_ID)
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlVacaciones]
FECHA: 23-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar el control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetControlVacaciones]
    @ACTIVOS BIT = NULL
AS
BEGIN
    SELECT CV.id
        , su2.id AS usuarioId
        , su2.cNombre + ' ' + su2.cApellido AS nombreUsuario
        , r.cTitulo AS rolUsuario
        , CV.rolUsuarioId_fk AS rolUsuarioId
        , CV.nDiasDisponibles AS diasDisponibles
        , CV.nDiasTomados AS diasTomados
        , CV.bAprobado AS aprobado
        , CV.nAprobadoBy AS idaprobado
        , su.cNombre + ' ' + su.cApellido AS aprobadoPor
        , suni.cTitulo AS unidadOrganizacional
        , u.id as unidadId
    FROM ControlVacaciones CV
        LEFT JOIN Sync_Usuario su on su.id = cv.nAprobadoBy
        LEFT JOIN RolUsuario ru on ru.id = cv.rolUsuarioId_fk and ru.bEliminado = 0
        LEFT JOIN Rol r on r.id = ru.rolId_fk and r.bEliminado = 0
        INNER JOIN Unidad u on u.id = r.unidadId_fk
        INNER JOIN Sync_Unidad  suni on suni.id = u.unidadOrgId_fk
        LEFT JOIN Sync_Usuario su2 on su2.id = ru.usuarioId_fk
    WHERE cv.bEliminado = 0
        AND (@ACTIVOS IS NULL OR cv.bActivo = @ACTIVOS) 
END
GO


CREATE   PROCEDURE [dbo].[usp_GetControlVacacionesById]
    @Id INT
AS
BEGIN
    SELECT CV.id
        , su2.id AS usuarioId
        , su2.cNombre + ' ' + su2.cApellido AS nombreUsuario
        , r.cTitulo AS rolUsuario
        , CV.rolUsuarioId_fk AS rolUsuarioId
        , CV.nDiasDisponibles AS diasDisponibles
        , CV.nDiasTomados AS diasTomados
        , CV.bAprobado AS aprobado
        , CV.nAprobadoBy AS idaprobado
        , su.cNombre + ' ' + su.cApellido AS aprobadoPor
        , suni.cTitulo AS unidadOrganizacional
        , u.id as unidadId
    FROM ControlVacaciones CV
        LEFT JOIN Sync_Usuario su on su.id = cv.nAprobadoBy
        LEFT JOIN RolUsuario ru on ru.id = cv.rolUsuarioId_fk and ru.bEliminado = 0
        LEFT JOIN Rol r on r.id = ru.rolId_fk and r.bEliminado = 0
        INNER JOIN Unidad u on u.id = r.unidadId_fk
        INNER JOIN Sync_Unidad  suni on suni.id = u.unidadOrgId_fk
        LEFT JOIN Sync_Usuario su2 on su2.id = ru.usuarioId_fk
    WHERE cv.bEliminado = 0 AND CV.id = @Id
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetControlVacacionesByUsuarioId]
FECHA: 23-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar el control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetControlVacacionesByUsuarioId] 
    @IDROLUSUARIO INT
AS
BEGIN
    SELECT CV.id
        , CV.rolUsuarioId_fk AS id_rolUsuario
        , CV.nDiasDisponibles AS diasDisponibles
        , CV.nDiasTomados AS diasTomados
        , CV.bAprobado AS aprobado
        , CV.nAprobadoBy AS idaprobado
    FROM ControlVacaciones CV
    WHERE rolUsuarioId_fk = @IDROLUSUARIO
        AND bEliminado = 0
END
GO


/*======================================================================================================
    NOMBRE: [dbo].[usp_GetCursoPreUniversitarioTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Obtener registros de la tabla CursoSeccionPreUniversitaria_TurnoRegular que pertencen a un turno regular específico
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCursoPreUniversitarioTurnoRegular]
    @TURNO_REGULAR_ENTRADA_ID INT,
    @TURNO_REGULAR_SALIDA_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        csptr.id,
        cspu.cursoPreUniversitario as curso,
        -- cspu.cAula as aula,
        trEntrada.horaInicio as horaInicio,
        trSalida.horaInicio as horaFin,
        cspu.centroEstudios as centroDeEstudios
    FROM CursoSeccionPreUniversitaria_TurnoRegular csptr
        INNER JOIN Sync_CursoSeccionPreUniversitaria cspu
            ON csptr.syncCursoSeccionPreUniversitariaId = cspu.id
        INNER JOIN TurnoRegular trEntrada
            ON csptr.turnoRegularEntradaId = trEntrada.id
        INNER JOIN TurnoRegular trSalida
            ON csptr.turnoRegularSalidaId = trSalida.id
    WHERE csptr.turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID
      AND csptr.turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID
      AND csptr.bEliminado = 0
      AND trEntrada.bEliminado = 0
      AND trSalida.bEliminado = 0
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetCursosBasicos]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los cursos preuniversitarios disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCursosBasicos]
  @PERIODO_LECTIVO_ID INT,
  @ETAPA_EDUCATIVA VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    id AS id,
    cCursoEducacionBasica AS cursoBasico
  FROM
    Sync_CursoSeccionBasica
  WHERE idPeriodoLectivo = @PERIODO_LECTIVO_ID AND cEtapaEducativa = @ETAPA_EDUCATIVA

END
GO


/*======================================================================================================
    NOMBRE: [dbo].[usp_GetCursoSeccionBasicaTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Obtener registros de la tabla CursoSeccionBasica_TurnoRegular que pertencen a un turno regular específico
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCursoSeccionBasicaTurnoRegular]
    @TURNO_REGULAR_ENTRADA_ID INT,
    @TURNO_REGULAR_SALIDA_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        csbtr.id,
        csb.cCursoEducacionBasica as curso,
        -- csb.cSeccion as seccion,
        trEntrada.horaInicio as horaInicio,
        trSalida.horaInicio as horaFin
    FROM CursoSeccionBasica_TurnoRegular csbtr
        INNER JOIN TurnoRegular trEntrada
            ON csbtr.turnoRegularEntradaId = trEntrada.id
        INNER JOIN TurnoRegular trSalida
            ON csbtr.turnoRegularSalidaId = trSalida.id
        INNER JOIN Sync_CursoSeccionBasica csb
            ON csbtr.syncCursoSeccionId = csb.id
    WHERE csbtr.turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID
      AND csbtr.turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID
      AND csbtr.bEliminado = 0
      AND trEntrada.bEliminado = 0
      AND trSalida.bEliminado = 0
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetCursosPreUniversitarios]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los cursos preuniversitarios disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCursosPreUniversitarios]
  @TEMPORADA_ID INT,
  @NIVEL_ID INT,
  @CENTRO_ESTUDIOS_ID INT,
  @AREA_ACADEMICA_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    id as id,
    cursoPreUniversitario AS cursoPreUniversitario,
    idCursoPreUniversitario AS idCursoPreUniversitario
  FROM
    Sync_CursoSeccionPreUniversitaria

  WHERE 
    idNivel = @NIVEL_ID
    AND idTemporada = @TEMPORADA_ID
    AND idCentroEstudios = @CENTRO_ESTUDIOS_ID
    AND idAreaAcademica = @AREA_ACADEMICA_ID
  GROUP BY 
    idCursoPreUniversitario, cursoPreUniversitario, id

END
GO


/*======================================================================================================
    NOMBRE: [dbo].[usp_GetCursosSeccionBasica]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Listar Cursos de Sección

    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCursosSeccionBasica]
    @PERIODO_LECTIVO_ID INT = NULL
AS
BEGIN
    SELECT
        id as cursoId,
        cCursoEducacionBasica as curso,
        -- nSeccionId as seccionId,
        -- cSeccion as seccion,
        cEtapaEducativa as grado,
        cNivelEducativo as nivel,
        idPeriodoLectivo as periodoLectivo
    FROM Sync_CursoSeccionBasica
    WHERE idPeriodoLectivo = @PERIODO_LECTIVO_ID
END
GO


/*======================================================================================================
    NOMBRE: [dbo].[usp_GetCursosSeccionPreUniversitaria]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Listar Cursos de Sección Pre Universitaria

    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetCursosSeccionPreUniversitaria]
    @TEMPORADA_ID INT
AS
BEGIN
    SELECT
        id as cursoId,
        cursoPreUniversitario as curso,
        -- cAula as aula,
        centroEstudios as centroDeEstudios,
        areaAcademica as areaAcademica,
        areaCurricular as areaCurricular,
        idTemporada as temporadaId,
        idPeriodoLectivo as periodoLectivoId
    FROM Sync_CursoSeccionPreUniversitaria
    WHERE idTemporada = @TEMPORADA_ID
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los biometricos, no eliminados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetDetalleBiometrico]
    @BIOMETRICO_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON

    SELECT DB.id id

        , DB.cNombre nombre
        , DB.ip ip
        , DB.serie serie
        , DB.ubicacion ubicacion
        , DB.bHuella huella
        , DB.bRostro rostro
        , DB.bTarjeta tarjeta
        , B.id biometricoId
      
        , CASE 
            WHEN COUNT(DISTINCT AR.id) > 0
            OR COUNT(DISTINCT AM.id) > 0
            OR COUNT(DISTINCT AE.id) > 0
                THEN 1
            ELSE 0
            END AS uso
    FROM DetalleBiometrico DB
        INNER JOIN Biometrico B
        ON B.id = DB.biometricoId_fk
            AND B.bEliminado = 0
        LEFT JOIN AsistenciaRegular AR
        ON AR.detalleBiometricoId_fk = DB.id
            AND AR.bEliminado = 0
        LEFT JOIN AsistenciaModificada AM
        ON AM.detalleBiometricoId_fk = DB.id
            AND AM.bEliminado = 0
        LEFT JOIN AsistenciaExtendida AE
        ON AE.detalleBiometricoId_fk = DB.id
            AND AE.bEliminado = 0
    WHERE DB.bEliminado = 0
        AND (@BIOMETRICO_ID IS NULL OR DB.biometricoId_fk = @BIOMETRICO_ID)
    GROUP BY DB.id
        , DB.cNombre
        , DB.ip
        , DB.serie
        , DB.ubicacion
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , B.id

END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleBiometricoById]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los biometricos, por ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetDetalleBiometricoById] @DETALLEID INT
AS
BEGIN
    SET NOCOUNT ON

    SELECT DB.id
        , DB.cNombre
        , DB.ip
        , DB.serie
        , DB.ubicacion
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , B.marca
        , B.tipoBD
        , CASE 
            WHEN COUNT(DISTINCT AR.id) > 0
                OR COUNT(DISTINCT AM.id) > 0
                OR COUNT(DISTINCT AE.id) > 0
                THEN 1
            ELSE 0
            END AS EnUso
    FROM DetalleBiometrico AS DB
    INNER JOIN Biometrico AS B
        ON B.id = DB.biometricoId_fk
    LEFT JOIN AsistenciaRegular AR
        ON AR.detalleBiometricoId_fk = DB.id
            AND AR.bEliminado = 0
    LEFT JOIN AsistenciaModificada AM
        ON AM.detalleBiometricoId_fk = DB.id
            AND AM.bEliminado = 0
    LEFT JOIN AsistenciaExtendida AE
        ON AE.detalleBiometricoId_fk = DB.id
            AND AE.bEliminado = 0
    WHERE DB.id = @DETALLEID
        AND b.bEliminado = 0
        AND DB.bEliminado = 0
    GROUP BY DB.id
        , DB.cNombre
        , DB.ip
        , DB.serie
        , DB.ubicacion
        , DB.bHuella
        , DB.bRostro
        , DB.bTarjeta
        , B.marca
        , B.tipoBD;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleHorarioGeneral]
FECHA: 17-09-2025
AUTOR: Admer Vasquez Uscuvilca
OBJETIVO: Lista los turnos de horario ya sea turno extendido o regular

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE     PROCEDURE [dbo].[usp_GetDetalleHorarioGeneral]
  @HORARIO_ID INT,
  @ROL_USUARIO_ID INT,
  @FECHA_INICIO DATE,
  @FECHA_FIN DATE

AS
BEGIN
  SET NOCOUNT ON;

  WITH
    TurnosNumerados
    AS
    (
      SELECT
        h.id AS horarioId,
        h.cTitulo AS horario,
        d.cTitulo AS dia,
        d.id AS diaId,
        hd.bLibre,
        tr.id AS turnoRegularId,
        tr.horaInicio AS horaTurnoRegular,
        te.id AS turnoExtendidoId,
        te.horaInicio AS horaTurnoExtendido,
        te.horaFin AS horaFinTurnoExtendido,
        -- CASE 
        --   WHEN p.id is not null OR p2.id is not null THEN 1
        --   ELSE 0
        -- END AS permiso,
        -- CASE 
        --   WHEN j.id is not null OR j2.id is not null THEN 1
        --   ELSE 0
        -- END AS justificacion,
        -- Identificar tipo de turno
        CASE 
      WHEN te.id IS NOT NULL THEN 'Extendido'
      WHEN tr.id IS NOT NULL THEN 'Regular'
      ELSE NULL
    END AS tipoTurno,
        -- Numerar los turnos regulares por día
        ROW_NUMBER() OVER (PARTITION BY hd.id ORDER BY COALESCE(tr.horaInicio, te.horaInicio)) AS numeroTurno,
        cd.diasId_pk AS conectadoDiaId,
        v.tFechaInicio AS vigenciaInicio,
        v.tFechaFin AS vigenciaFin
      FROM Horario h
        INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
        INNER JOIN Dia d ON d.id = hd.diaId_fk
        LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id and tr.bEliminado = 0

        LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id and te.bEliminado = 0

        LEFT JOIN ConectadoDias cd on cd.turnoExtendidoId_pk = te.id
        LEFT JOIN Vigencia v on v.horarioDiasId_fk = hd.id and v.bActivo = 1
      WHERE h.id = @HORARIO_ID 
        AND v.tFechaInicio >= @FECHA_INICIO
        AND v.tFechaFin <= @FECHA_FIN
    ),
    TurnosEmparejados
    AS
    (
      SELECT
        t1.horarioId,
        t1.horario,
        t1.dia,
        t1.diaId,
        t1.bLibre,
        -- Turno de entrada
        COALESCE(t1.turnoRegularId, t1.turnoExtendidoId) AS turnoEntradaId,
        COALESCE(t1.horaTurnoRegular, t1.horaTurnoExtendido) AS horaEntrada,
        -- Turno de salida
        COALESCE(t2.turnoRegularId, t1.turnoExtendidoId) AS turnoSalidaId,
        COALESCE(t2.horaTurnoRegular, t1.horaFinTurnoExtendido) AS horaSalida,
        -- Tipo de turno
        t1.tipoTurno,
        t1.conectadoDiaId,
        t1.vigenciaInicio,
        t1.vigenciaFin
        
      -- t1.permiso,
      -- t1.justificacion
      FROM TurnosNumerados t1
        LEFT JOIN TurnosNumerados t2
        ON t1.diaId = t2.diaId
          AND t1.numeroTurno % 2 = 1 -- Solo turnos impares (entrada)
          AND t2.numeroTurno = t1.numeroTurno + 1
      -- El siguiente turno (salida)
      WHERE t1.numeroTurno % 2 = 1 OR t1.turnoExtendidoId IS NOT NULL
    )
  SELECT
    horarioId,
    horario,
    dia,
    diaId,
    turnoEntradaId,
    CONVERT(VARCHAR(8), horaEntrada, 108) AS horaEntrada,
    turnoSalidaId,
    CONVERT(VARCHAR(8), horaSalida, 108) AS horaSalida,
    tipoTurno,
    CASE WHEN bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin
  -- permiso,
  -- justificacion
  FROM TurnosEmparejados
  WHERE (turnoEntradaId IS NOT NULL OR bLibre = 1)
  ORDER BY diaId, horaEntrada;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleHorarioTurnoRegular]
FECHA: 01-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Detalle de horario de turno regulares

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetDetalleHorarioTurnoRegular]
    @HORARIO_ID INT = NULL
AS
BEGIN
    ;WITH
        Entradas
        AS
        (
            SELECT
                tr.id turnoEntradaId,
                h.id AS horarioId,
                h.cTitulo AS horario,
                d.cTitulo AS dia,
                tr.horaInicio AS horaEntrada,
                ROW_NUMBER() OVER (PARTITION BY h.id, d.id ORDER BY tr.orden) AS rn,
                hd.bLibre,
                csbtr.id as cursoPreUniversitarioTurnoRegularId, -- representa el id CursoTurnoRegular
                csps.cursoPreUniversitario as curso,
                csps.centroEstudios as centroEstudios,
                ru.id as rolUsuarioId,
                su.cNombre as nombre,
                su.cApellido as apellido
            FROM Horario h
                INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
                INNER JOIN Dia d ON d.id = hd.diaId_fk
                LEFT JOIN TurnoRegular tr
                ON tr.horarioDiasId_fk = hd.id
                    AND tr.bEliminado = 0
                    AND tr.bTipo = 0
                left JOIN CursoSeccionPreUniversitaria_TurnoRegular csbtr
                ON csbtr.turnoRegularEntradaId = tr.id
                    AND csbtr.bEliminado = 0
                left JOIN Sync_CursoSeccionPreUniversitaria csps
                ON csps.id = csbtr.syncCursoSeccionPreUniversitariaId
                LEFT JOIN RolUsuario ru ON ru.id = csbtr.rolUsuarioId
                LEFT JOIN Sync_Usuario su ON  su.id = ru.usuarioId_fk
            WHERE h.bEliminado = 0
                AND hd.bEliminado = 0
                AND d.bEliminado = 0
                AND h.id = @HORARIO_ID
        ),
        Salidas
        AS
        (
            SELECT
                tr.id turnoSalidaId,
                h.id AS horarioId,
                d.cTitulo AS dia,
                tr.horaInicio AS horaSalida,
                ROW_NUMBER() OVER (PARTITION BY h.id, d.id ORDER BY tr.orden) AS rn
            FROM Horario h
                INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
                INNER JOIN Dia d ON d.id = hd.diaId_fk
                LEFT JOIN TurnoRegular tr
                ON tr.horarioDiasId_fk = hd.id
                    AND tr.bEliminado = 0
                    AND tr.bTipo = 1
            WHERE h.bEliminado = 0
                AND hd.bEliminado = 0
                AND d.bEliminado = 0
                AND h.id = @HORARIO_ID
        )
    SELECT
        e.horarioId,
        e.horario,
        e.dia,
        e.turnoEntradaId,
        e.horaEntrada,
        s.turnoSalidaId,
        s.horaSalida,
        e.cursoPreUniversitarioTurnoRegularId,
        e.curso,
        e.centroEstudios,
        e.rolUsuarioId,
        e.nombre,
        e.apellido,
        CASE WHEN e.bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre
    FROM Entradas e
        LEFT JOIN Salidas s
        ON e.horarioId = s.horarioId
            AND e.dia = s.dia
            AND e.rn = s.rn
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetDetalleHorarioTurnoRegularEscolar]
FECHA: 01-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Detalle de horario de turno regulares para el modo escolar

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetDetalleHorarioTurnoRegularEscolar]
    @HORARIO_ID INT = NULL
AS
BEGIN
    ;WITH
        Entradas
        AS
        (
            SELECT
                tr.id turnoEntradaId,
                h.id AS horarioId,
                h.cTitulo AS horario,
                d.cTitulo AS dia,
                tr.horaInicio AS horaEntrada,
                ROW_NUMBER() OVER (PARTITION BY h.id, d.id ORDER BY tr.orden) AS rn,
                hd.bLibre,
                csbtr.id as cursoBasicoTurnoRegularId , -- representa el id CursoTurnoRegular
                csps.cCursoEducacionBasica as curso,
                csps.cEtapaEducativa as grado,
                csps.cNivelEducativo as nivel,
                'Colegio' as centroEstudios,
                ru.id as rolUsuarioId,
                su.cNombre as nombre,
                su.cApellido as apellido
            FROM Horario h
                INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
                INNER JOIN Dia d ON d.id = hd.diaId_fk
                LEFT JOIN TurnoRegular tr
                ON tr.horarioDiasId_fk = hd.id
                    AND tr.bEliminado = 0
                    AND tr.bTipo = 0
                left JOIN CursoSeccionBasica_TurnoRegular csbtr
                ON csbtr.turnoRegularEntradaId = tr.id
                    AND csbtr.bEliminado = 0
                left JOIN Sync_CursoSeccionBasica csps
                ON csps.id = csbtr.syncCursoSeccionId
                LEFT JOIN RolUsuario ru ON ru.id = csbtr.rolUsuarioId AND ru.bEliminado = 0
                LEFT JOIN Sync_Usuario su ON su.id = ru.usuarioId_fk
            WHERE h.bEliminado = 0
                AND hd.bEliminado = 0
                AND d.bEliminado = 0
                AND h.id =  @HORARIO_ID 
        ),
        Salidas
        AS
        (
            SELECT
                tr.id turnoSalidaId,
                h.id AS horarioId,
                d.cTitulo AS dia,
                tr.horaInicio AS horaSalida,
                ROW_NUMBER() OVER (PARTITION BY h.id, d.id ORDER BY tr.orden) AS rn
            FROM Horario h
                INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
                INNER JOIN Dia d ON d.id = hd.diaId_fk
                LEFT JOIN TurnoRegular tr
                ON tr.horarioDiasId_fk = hd.id
                    AND tr.bEliminado = 0
                    AND tr.bTipo = 1
            WHERE h.bEliminado = 0
                AND hd.bEliminado = 0
                AND d.bEliminado = 0
                AND h.id =  @HORARIO_ID 
        )
    SELECT
        e.horarioId,
        e.horario,
        e.dia,
        e.turnoEntradaId,
        e.horaEntrada,
        s.turnoSalidaId,
        s.horaSalida,
        e.cursoBasicoTurnoRegularId,
        e.curso,
        e.nivel,
        e.centroEstudios,
        e.grado,
        e.rolUsuarioId,
        e.nombre,
        e.apellido,
        CASE WHEN e.bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre
    FROM Entradas e
        LEFT JOIN Salidas s
        ON e.horarioId = s.horarioId
            AND e.dia = s.dia
            AND e.rn = s.rn
END
GO


--=================================================================================
CREATE   PROCEDURE [dbo].[usp_GetDias]
AS
BEGIN 
    SELECT id as id, orden, ctitulo as titulo, cAbreviatura as abreviatura
    FROM Dia
    WHERE bEliminado = 0
    ORDER BY orden  ASC
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_getEstadoAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener el estado de la asistencia de un usuario en una fecha determinada.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getEstadoAsistencia]
AS
BEGIN
  SET NOCOUNT ON;

  SELECT id, cNombre estado FROM EstadoAsistencia;
END
GO

CREATE   PROCEDURE [dbo].[usp_GetEstadoAsistenciaMarcaciones]
  @ASISTENCIA_ID INT
AS
BEGIN
  SET NOCOUNT ON
  SELECT
    CASE 
      WHEN crua.id is not null THEN crua.estadoEntrada + ' - ' + crua.estadoSalida 
      WHEN cua.id is not null THEN cua.estadoEntrada + ' - ' + cua.estadoSalida 
      WHEN rca.id is not null THEN rca.estadoEntrada + ' - ' + rca.estadoSalida 
      ELSE 'No registrado'
    END AS estadoAsistencia,
    CASE 
      WHEN a.esRegular = 1 THEN 
        (
          SELECT CONVERT(VARCHAR(5), m.punch_time, 108) AS marcacion
    FROM AsistenciaRegular ar
      INNER JOIN Marcacion m ON ar.marcacionId_fk = m.id
    WHERE ar.asistenciaId_fk = a.id AND ar.bEliminado = 0
    FOR JSON PATH
        )
      WHEN a.esRegular = 0 THEN 
        (
          SELECT CONVERT(VARCHAR(5), m.punch_time, 108) AS marcacion
    FROM AsistenciaExtendida anr
      INNER JOIN Marcacion m ON anr.marcacionId_fk = m.id
    WHERE anr.asistenciaId_fk = a.id AND anr.bEliminado = 0
    FOR JSON PATH
        )
      ELSE 'No registrado'
    END as marcaciones

  FROM
    Asistencia a
    LEFT JOIN ControlRolUsuarioAsistencia crua ON a.id = crua.asistenciaId_fk and crua.bEliminado = 0
    LEFT JOIN ControlUnidadAsistencia cua ON a.id = cua.asistenciaId_fk AND cua.bEliminado = 0
    LEFT JOIN RolControlAsistencia rca ON a.id = rca.asistenciaId_fk AND rca.bEliminado = 0
  WHERE a.id = @ASISTENCIA_ID
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetEtapasEducativas]
FECHA: 01-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Lista de etapas educativas

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetEtapasEducativas]
  @PERIODO_LECTIVO_ID INT,
  @NIVEL_EDUCATIVO VARCHAR(50)
AS
BEGIN
  SELECT
    cEtapaEducativa as nombre
  FROM Sync_ConfiguracionEtapa
  WHERE idPeriodoLectivo = @PERIODO_LECTIVO_ID
    AND cNivelEducativo = @NIVEL_EDUCATIVO
  GROUP BY cEtapaEducativa
  ORDER BY cEtapaEducativa
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetFeriadosUnidad]
FECHA: 07-02-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener los feriados de una unidad organizativa para un año específico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetFeriadosUnidad]
  @UNIDAD_ID INT,
  @ANIO_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT 
    uf.unidadId_pk as unidadId
    ,uf.fechaFeriadoId_pk as fechaFeriadoId
    ,ff.fecha as fecha
    ,su.cTitulo as unidadOrganizativa
    ,ff.anioId_fk as anioId
    ,sa.cDescripcion as anio
    ,df.id as denominacionFeriadoId
    ,df.cDenominacion as denominacionFeriado
  FROM UnidadFeriado uf
    INNER JOIN FechaFeriado ff ON ff.id = uf.fechaFeriadoId_pk
    INNER JOIN DenominacionFeriado df ON df.id = ff.denominacionFeriadoId_fk
    INNER JOIN Unidad u ON u.id = uf.unidadId_pk
    INNER JOIN Sync_Unidad su ON su.id = u.unidadOrgId_fk
    INNER JOIN Sync_Anio sa ON sa.id = ff.anioId_fk
  WHERE sa.id = @ANIO_ID
    AND u.id = @UNIDAD_ID

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetFeriadosUnidad]
FECHA: 07-02-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener los feriados de una unidad organizativa para un año específico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetFeriadoUnidad]
  @UNIDAD_ID INT,
  @FECHA_FERIADO_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    uf.unidadId_pk as unidadId
    , uf.fechaFeriadoId_pk as fechaFeriadoId
    , ff.fecha as fecha
    , su.cTitulo as unidadOrganizativa
    , ff.anioId_fk as anioId
    , sa.cDescripcion as anio
    , df.id as denominacionFeriadoId
    , df.cDenominacion as denominacionFeriado
  FROM UnidadFeriado uf
    INNER JOIN FechaFeriado ff ON ff.id = uf.fechaFeriadoId_pk
    INNER JOIN DenominacionFeriado df ON df.id = ff.denominacionFeriadoId_fk
    INNER JOIN Unidad u ON u.id = uf.unidadId_pk
    INNER JOIN Sync_Unidad su ON su.id = u.unidadOrgId_fk
    INNER JOIN Sync_Anio sa ON sa.id = ff.anioId_fk

  WHERE uf.unidadId_pk = @UNIDAD_ID
    AND uf.fechaFeriadoId_pk = @FECHA_FERIADO_ID

END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioByUsuario]
FECHA: 10-02-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: muestra el los horarios relacionados a un rolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorarioByUsuario]
    @ROL_USUARIO INT = NULL
AS
BEGIN

    SELECT
        H.id AS id
        , H.id as idHorario
, U.cNombre AS nombre
, U.cApellido AS apellido
, U.cDni AS dni
, r.cTitulo AS rol
, UO.cTitulo AS unidad
, H.cTitulo AS titulo
, H.bRegular AS regular
, H.bExtendido AS extendido
, H.bRotativo AS rotativo
, H.bGeneral AS general
, H.horaDia
, T.cTemporada AS temporada
, T.idPeriodoLectivo AS periodoId
, T.idTemporada AS temporadaId
, T.cPeriodoLectivo as periodoLectivo
, RU.id AS idRolUsuario
, CAST(HU.tfechaInicio as VARCHAR(10)) AS fechaInicio
, CAST(HU.tFechaFin as VARCHAR(10)) AS fechaFin
, HU.id AS idHorarioUsuario
, CASE  
             WHEN H.idTemporada = T.idTemporada THEN 1
             ELSE 0
            END  as horarioAcademico
, CASE 
            WHEN COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS diasAsignados
        , COUNT(DISTINCT HD.id) AS cantidadDias
, CASE WHEN GETDATE() BETWEEN HU.tfechaInicio AND HU.tFechaFin THEN 'Vigente'
        WHEN GETDATE() < HU.tfechaInicio THEN 'Proximo'
        ELSE 'Expirado'
END AS estado
    FROM HorarioUsuario HU
        INNER JOIN Horario H ON  HU.horarioId_fk = H.id
        LEFT JOIN HorarioDias HD ON HD.horarioId_fk = H.id
        INNER JOIN RolUsuario RU ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario U ON RU.usuarioId_fk = U.id
        INNER JOIN Rol R ON RU.rolId_fk = R.id
        LEFT JOIN Unidad UD ON R.unidadId_fk = UD.id
        LEFT JOIN Sync_Unidad UO ON UD.unidadOrgId_fk = UO.id
        LEFT JOIN Sync_Temporada T ON H.idTemporada = T.idTemporada
    WHERE RU.id = @ROL_USUARIO AND HU.bEliminado = 0
    GROUP BY H.id
    ,U.cNombre
    ,U.cApellido
    ,U.cDni
    ,R.cTitulo
    ,UO.cTitulo
    ,H.cTitulo
    ,H.bRegular
    ,H.bExtendido
    ,H.bRotativo
    ,H.bGeneral
    ,H.horaDia
    ,RU.id
    ,HU.tfechaInicio
    ,HU.tFechaFin
    ,T.idPeriodoLectivo
    ,T.idTemporada
    ,T.cPeriodoLectivo
    ,T.cTemporada
    ,H.idTemporada
    , HU.id
    ORDER BY H.id DESC

END
GO


--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetHorarioCurso]
-- Fecha:  24-10-2025
-- Descripcion: Procedimiento para mostrar Todos los cursos de un Horario Academico
-- Parámetros: 'HORARIOID
--=======================================================================================
CREATE   PROCEDURE [dbo].[usp_GetHorarioCurso]
    @HORARIOID INT

AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        t.id AS Id_turno,
        h.cTitulo AS Horario,
        d.cTitulo AS Dia,
        t.horaInicio AS Hora,
        Tipo = CASE 
        WHEN t.bTipo = 1 THEN 'Salida'
        WHEN t.bTipo = 0 THEN 'Entrada'
    END,
        Turno = CASE 
        WHEN (t.orden + 1) / 2 = FLOOR((t.orden + 1) / 2)
        THEN 'Turno' + CONVERT(varchar, (t.orden + 1) / 2)
    END,
        cp.cursoPreUniversitario AS Curso
        -- cp.cAula
    FROM TurnoRegular AS t
        INNER JOIN HorarioDias AS hd
        ON t.horarioDiasId_fk = hd.id
        INNER JOIN Horario AS h
        ON hd.horarioId_fk = h.id
        INNER JOIN Dia AS d
        ON hd.diaId_fk = d.id
        INNER JOIN CursoSeccionPreUniversitaria_TurnoRegular AS ct
        ON (ct.turnoRegularEntradaId = t.id OR ct.turnoRegularSalidaId = t.id )
        INNER JOIN Sync_CursoSeccionPreUniversitaria AS cp
        ON ct.syncCursoSeccionPreUniversitariaId = cp.id
    WHERE h.id = @HORARIOID
        AND t.bEliminado = 0
    ORDER BY d.orden ASC

END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioDiaById]
FECHA: 10-10-2025
AUTOR: Vasquez Uscuvilca, Admer
OBJETIVO: Permite Obtener un horario dia por su ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorarioDiaById]
    @HORARIODIA_ID INT
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        hd.id AS horarioDiaId,
        h.id AS horarioId,
        h.cTitulo as nombreHorario,
        d.cTitulo as dia,
        CASE WHEN hd.bLibre = 1 THEN 'SI' ELSE 'NO' END AS libre,
        v.tfechaInicio AS fechaInicio,
        v.tfechaFin AS fechaFin
    FROM HorarioDias hd
        INNER JOIN Horario h on h.id = hd.horarioId_fk
        INNER JOIN Dia d on d.id = hd.diaId_fk
        LEFT JOIN Vigencia v on v.horarioDiasId_fk = hd.id
        -- LEFT JOIN FechaLimite fl on fl.id = v.fechaLimiteId_pk
    WHERE hd.id = @HORARIODIA_ID AND 
        h.bEliminado = 0 AND 
        hd.bEliminado = 0 AND
        d.bEliminado = 0 AND
        (v.bEliminado = 0 OR v.bEliminado IS NULL)
        -- AND (fl.bEliminado = 0 OR fl.bEliminado IS NULL);
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarios]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los horarios registrados que tiene asignados un HorarioDias

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorarios]
    @ROL_USUARIO_ID INT = NULL
AS
BEGIN
    SELECT H.id
        , H.cTitulo AS titulo
        , H.horaDia
        , H.bGeneral AS general
        , H.bExtendido AS extendido
        , H.bRotativo AS rotativo
        , H.bRegular AS regular
        , T.cTemporada AS temporada
        , T.idPeriodoLectivo AS periodoId
        , T.idTemporada AS temporadaId
        , T.cPeriodoLectivo as periodoLectivo
        , CASE  
             WHEN H.idTemporada = T.idTemporada THEN 1
             ELSE 0
            END  as horarioAcademico
        , CASE 
            WHEN COUNT(DISTINCT HU.id) > 0
            OR COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS enUso
        , CASE 
            WHEN COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS diasAsignados
        , COUNT(DISTINCT HD.id) AS cantidadDias
    -- , COUNT(DISTINCT HU.id) AS cantidadUsuarios
    FROM Horario H
        LEFT JOIN HorarioDias HD
        ON HD.horarioId_fk = H.id
            AND HD.bEliminado = 0
        LEFT JOIN HorarioUsuario HU
        ON HU.horarioId_fk = H.id
            AND HU.bEliminado = 0
        LEFT JOIN Sync_Temporada T ON H.idTemporada = T.idTemporada
    WHERE H.bEliminado = 0 
        AND (@ROL_USUARIO_ID IS NULL OR HU.rolUsuarioId_fk = @ROL_USUARIO_ID)
        AND  EXISTS(
            SELECT 1 FROM horarioDias 
            WHERE H.Id = hd.horarioId_fk AND HD.bEliminado = 0
        )
    GROUP BY H.id
        , H.cTitulo
        , H.horaDia
        , H.bGeneral
        , H.bExtendido
        , H.bRotativo
        , H.bRegular
        , T.cTemporada
        , T.cPeriodoLectivo
        , T.idTemporada
        , H.idTemporada
        , T.idPeriodoLectivo
    ORDER BY h.id DESC
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorariosBy]
FECHA: 17-09-2025
AUTOR: Admer Vasquez Uscuvilca
OBJETIVO: Lista todos los horarios por si son regulares o extendidas segun el parametro enviado

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorariosBy]
  @EsExtendido BIT = NULL,
  @EsRegular BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    IF @EsRegular = 1 AND @EsExtendido IS NULL
      BEGIN 
        SELECT 
          distinct
          h.id,
          h.cTitulo as titulo,
          h.bGeneral as general,
          h.bExtendido as extendido,
          h.bRotativo as rotativo
          -- para contar los dias asociados a cada horario
          , (
              SELECT COUNT(*) 
              FROM HorarioDias hd 
              WHERE hd.horarioId_fk = h.id
            ) AS cantidadDias
        FROM 
            Horario h  
        INNER JOIN HorarioDias hd ON h.id = hd.horarioId_fk
        INNER JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id
      END
    ELSE
      BEGIN
         SELECT 
          distinct
          h.id,
          h.cTitulo as titulo,
          h.bGeneral as general,
          h.bExtendido as extendido,
          h.bRotativo as rotativo
          -- para contar los dias asociados a cada horario
          , (
              SELECT COUNT(*) 
              FROM HorarioDias hd 
              WHERE hd.horarioId_fk = h.id
            ) AS CantidadDias
        FROM 
            Horario h  
        INNER JOIN HorarioDias hd ON h.id = hd.horarioId_fk
        INNER JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id
    END
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorariosById]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Obtener un horario por ID y cantidad de registros en HorarioDias

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorariosById] @HORARIOID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT H.id
        , H.cTitulo AS titulo
        , H.horaDia
        , H.bGeneral
        , H.bExtendido
        , H.bRotativo
        , CASE 
            WHEN COUNT(DISTINCT HU.id) > 0
                OR COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS enUso
        , CASE 
            WHEN COUNT(DISTINCT HD.id) > 0
                THEN 1
            ELSE 0
            END AS diasAsignados
        , COUNT(DISTINCT HD.id) AS cantidadDias
        -- , COUNT(DISTINCT HU.id) AS cantidadUsuarios
    FROM Horario H
    LEFT JOIN HorarioDias HD
        ON HD.horarioId_fk = H.id
            AND HD.bEliminado = 0
    LEFT JOIN HorarioUsuario HU
        ON HU.horarioId_fk = H.id
            AND HU.bEliminado = 0
    WHERE H.bEliminado = 0
        AND H.id = @HORARIOID
    GROUP BY H.id
        , H.cTitulo
        , H.horaDia
        , H.bGeneral
        , H.bExtendido
        , H.bRotativo;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorariosByRolUsuarioId]
FECHA: 25-02-2026
AUTOR: Gabriel Vasquez
OBJETIVO: Permite obtener los horarios de un usuario por su RolUsuarioId

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorariosByRolUsuarioId]
  @ROL_USUARIO_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    hu.horarioId_fk AS horarioId
  FROM
    HorarioUsuario hu
  WHERE hu.rolUsuarioId_fk = @ROL_USUARIO_ID
    and hu.bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getHorariosCita]
FECHA: 13-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los horarios para una cita.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
-      -             -           -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getHorariosCita]
AS
BEGIN
  SET NOCOUNT ON;
  SELECT h.id, h.cTitulo AS titulo
  FROM Horario h
  WHERE NOT EXISTS (
    SELECT 1
    FROM HorarioDias hd
    WHERE h.id = hd.horarioId_fk AND hd.bEliminado = 0 AND h.bEliminado = 0
  )
    AND h.bEliminado = 0;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorariosDocente]
FECHA: 17-09-2025
AUTOR: Admer Vasquez Uscuvilca
OBJETIVO: Lista todos los horarios de los docentes segun la temporada enviada ( los docentes
solo tienen configurado temporada ) 

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorariosDocente]
  @TEMPORADA_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    distinct
    h.id,
    h.cTitulo as titulo,
    h.bGeneral as general,
    h.bExtendido as extendido,
    h.bRotativo as rotativo
    -- para contar los dias asociados a cada horario
    , (
        SELECT COUNT(*)
    FROM HorarioDias hd
    WHERE hd.horarioId_fk = h.id
      ) AS cantidadDias
  FROM
    Horario h
    LEFT JOIN HorarioDias hd ON h.id = hd.horarioId_fk
  WHERE h.idTemporada is not null and h.idTemporada = @TEMPORADA_ID AND h.bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getHorariosPorRolUsuarioId]
FECHA: 20/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los horarios de un usuario a partir de su RolUsuarioId y genear asistencia a partir
del horario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   20/02/2026  Gabriel    Se agregó filtro de vigencia para los horarios
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getHorariosPorRolUsuarioId]
  @HORARIO_ID INT,
  @ROL_USUARIO_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @DatosAsistencia TABLE
        (
    horarioId INT,
    horario NVARCHAR(100),
    dia NVARCHAR(50),
    turnoEntradaId INT,
    horaEntrada TIME,
    turnoSalidaId INT,
    horaSalida TIME,
    tipoTurno NVARCHAR(50),
    diaLibre NVARCHAR(2),
    conectadoDiaId INT,
    vigenciaInicio DATE,
    vigenciaFin DATE
        );

  DECLARE @Dia NVARCHAR(50) = FORMAT(GETDATE(), 'dddd', 'es-ES');
  DECLARE @DiaAnterior NVARCHAR(50) = FORMAT(DATEADD(DAY, -1, GETDATE()), 'dddd', 'es-ES');

  WITH
    TurnosNumerados
    AS
    (
      SELECT
        h.id AS horarioId,
        h.cTitulo AS horario,
        d.cTitulo AS dia,
        d.id AS diaId,
        hd.bLibre,
        tr.id AS turnoRegularId,
        tr.horaInicio AS horaTurnoRegular,
        te.id AS turnoExtendidoId,
        te.horaInicio AS horaTurnoExtendido,
        te.horaFin AS horaFinTurnoExtendido,
        -- Identificar tipo de turno
        CASE 
                WHEN te.id IS NOT NULL THEN 'Extendido'
                WHEN tr.id IS NOT NULL THEN 'Regular'
                ELSE NULL
              END AS tipoTurno,
        -- Numerar los turnos regulares por día
        ROW_NUMBER() OVER (PARTITION BY hd.id ORDER BY COALESCE(tr.horaInicio, te.horaInicio)) AS numeroTurno,
        cd.diasId_pk AS conectadoDiaId,
        v.tFechaInicio AS vigenciaInicio,
        v.tFechaFin AS vigenciaFin
      FROM Horario h
        INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
        INNER JOIN Dia d ON d.id = hd.diaId_fk
        LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id
        LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id
        LEFT JOIN ConectadoDias cd on cd.turnoExtendidoId_pk = te.id
        LEFT JOIN Vigencia v on v.horarioDiasId_fk = hd.id and v.bActivo = 1
      WHERE h.id = @HORARIO_ID AND GETDATE() BETWEEN v.tFechaInicio AND v.tFechaFin

    ),
    TurnosEmparejados
    AS
    (
      SELECT
        t1.horarioId,
        t1.horario,
        t1.dia,
        t1.diaId,
        t1.bLibre,
        -- Turno de entrada
        COALESCE(t1.turnoRegularId, t1.turnoExtendidoId) AS turnoEntradaId,
        COALESCE(t1.horaTurnoRegular, t1.horaTurnoExtendido) AS horaEntrada,
        -- Turno de salida
        COALESCE(t2.turnoRegularId, t1.turnoExtendidoId) AS turnoSalidaId,
        COALESCE(t2.horaTurnoRegular, t1.horaFinTurnoExtendido) AS horaSalida,
        -- Tipo de turno
        t1.tipoTurno,
        t1.conectadoDiaId,
        t1.vigenciaInicio,
        t1.vigenciaFin
      FROM TurnosNumerados t1
        LEFT JOIN TurnosNumerados t2
        ON t1.diaId = t2.diaId
          AND t1.numeroTurno % 2 = 1 -- Solo turnos impares (entrada)
          AND t2.numeroTurno = t1.numeroTurno + 1
      -- El siguiente turno (salida)
      WHERE t1.numeroTurno % 2 = 1 OR t1.turnoExtendidoId IS NOT NULL
    )

  INSERT INTO @DatosAsistencia
    (
    horarioId,
    horario,
    dia,
    turnoEntradaId,
    horaEntrada,
    turnoSalidaId,
    horaSalida,
    tipoTurno,
    diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin
    )
  SELECT
    horarioId,
    horario,
    dia,
    turnoEntradaId,
    horaEntrada,
    turnoSalidaId,
    horaSalida,
    tipoTurno,
    CASE WHEN bLibre = 1 THEN 'SI' ELSE 'NO' END AS diaLibre,
    conectadoDiaId,
    vigenciaInicio,
    vigenciaFin
  FROM TurnosEmparejados
  WHERE             
            (turnoEntradaId IS NOT NULL OR bLibre = 1)
    AND dia COLLATE SQL_Latin1_General_CP1_CI_AI = @Dia AND turnoEntradaId IS NOT NULL
    OR ( dia COLLATE SQL_Latin1_General_CP1_CI_AI = @DiaAnterior and tipoTurno = 'Extendido');

  INSERT INTO Asistencia
    (horaEntrada, horaSalida, vigenciaFin, vigenciaInicio, rolUsuarioid_fk, tFecha, tCreatedAt, turnoEntradaid, turnoSalidaid, nCreatedBy, esRegular)
  SELECT
    d.horaEntrada,
    d.horaSalida,
    d.vigenciaFin,
    d.vigenciaInicio,
    @ROL_USUARIO_ID, -- RolUsuarioId
    CAST(GETDATE() AS DATE),
    GETDATE(),
    d.turnoEntradaId,
    d.turnoSalidaId,
    1,
    CASE WHEN d.conectadoDiaId is not null then 0 else 1 end as esRegular
  FROM @DatosAsistencia d
  WHERE NOT EXISTS (
            SELECT 1
  FROM Asistencia a
  WHERE a.rolUsuarioid_fk = @ROL_USUARIO_ID
    AND ISNULL(a.turnoEntradaid, -1) = ISNULL(d.turnoEntradaId, -1)
    AND ISNULL(a.turnoSalidaid, -1) = ISNULL(d.turnoSalidaId, -1)
    AND a.tFecha = CAST(GETDATE() AS DATE)
          );

  SELECT
    id,
    horaEntrada,
    horaSalida,
    vigenciaFin,
    vigenciaInicio,
    turnoEntradaid,
    turnoSalidaid,
    tFecha,
    rolUsuarioid_fk rolUsuarioId,
    esRegular
  FROM Asistencia
  WHERE rolUsuarioid_fk = @ROL_USUARIO_ID AND tFecha = CAST(GETDATE() AS DATE);

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioUsuario]
FECHA: 03-10-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar horario usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorarioUsuario]
AS
BEGIN
    SELECT HU.id
        , HU.horarioId_fk AS idHorario
        , HU.rolUsuarioId_fk AS idRolUsuario
        , SU.cApellido AS apellidos
        , SU.cNombre AS nombre
        , CAST(HU.tfechaInicio as VARCHAR(10)) AS fechaInicio
        , CAST(HU.tFechaFin as VARCHAR(10)) AS fechaFin
        , H.cTitulo AS tituloHorario
        , RU.usuarioId_fk AS idUsuario
        , SU.cUsuario AS usuario
    FROM HorarioUsuario HU
        INNER JOIN HORARIO H
        ON HU.horarioId_fk = H.id
        INNER JOIN RolUsuario RU
        ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario SU
        ON RU.usuarioId_fk = SU.id
    WHERE HU.bEliminado = 0
    ORDER BY HU.id DESC
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioUsuarioById]
FECHA: 03-10-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar horario usuario por id

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 01  05/01/2026  fluna      añadir nombre de usuario
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorarioUsuarioById]
  @IDHORARIOUSUARIO INT
AS
BEGIN
  SELECT HU.id
        , HU.horarioId_fk AS idHorario
        , HU.rolUsuarioId_fk AS idRolUsuario
        , HU.tfechaInicio AS fechaInicio
        , HU.tFechaFin AS fechaFin
        , H.cTitulo AS tituloHorario
        , RU.usuarioId_fk AS idUsuario
        , SU.cUsuario AS usuario
        , SU.cNombre+' '+SU.cApellido AS nombre
  FROM HorarioUsuario HU
    INNER JOIN HORARIO H ON HU.horarioId_fk = H.id
    INNER JOIN RolUsuario RU ON HU.rolUsuarioId_fk = RU.id
    INNER JOIN Sync_Usuario SU ON RU.usuarioId_fk = SU.id
  WHERE HU.bEliminado = 0
    AND HU.id = @IDHORARIOUSUARIO
END
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetHorarioUsuarioByUsuarioId]
FECHA: 20-01-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: muestra el Horario completo a partir del id de usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetHorarioUsuarioByUsuarioId]
    @ROL_USUARIO_ID INT = NULL,
    @HORARIO_ID INT = NULL
AS
BEGIN
    SELECT
        HU.id,
        HU.horarioId_fk AS idHorario,
        H.cTitulo AS titulo,
        H.horaDia AS horas,
        -- HU.rolUsuarioId_fk AS idRolUsuario,
        SU.cApellido AS apellidos,
        SU.cNombre AS nombre,
        HU.tfechaInicio AS fechaInicio,
        HU.tFechaFin AS fechaFin,
        RU.usuarioId_fk AS idUsuario,
        SU.cUsuario AS usuario,
        D.cTitulo AS dia,
        HD.id AS horarioDiaId,
        TR.horaInicio,
        tipo = CASE 
 WHEN  TR.bTipo = 1  THEN 'Salida'
 WHEN TR.bTipo = 0  THEN 'Entrada'
 END
    FROM HorarioUsuario HU
        INNER JOIN HORARIO H
        ON HU.horarioId_fk = H.id
        INNER JOIN HorarioDias HD
        ON HD.horarioId_fk = H.id
        INNER JOIN Dia D
        ON HD.diaId_fk = D.id
        LEFT JOIN TurnoRegular TR
        ON HD.id = TR.horarioDiasId_fk
        LEFT JOIN TurnoExtendido TE 
        ON HD.id = TE.horarioDiasId_fk
        INNER JOIN RolUsuario RU
        ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario SU
        ON RU.usuarioId_fk = SU.id
    WHERE  HU.bEliminado = 0 AND H.bEliminado = 0 AND TR.bEliminado = 0
        AND RU.id = @ROL_USUARIO_ID AND H.id = @HORARIO_ID
    GROUP BY H.id,
      HU.id,
    HU.horarioId_fk,
    H.cTitulo ,
    H.horaDia,
    -- HU.rolUsuarioId_fk AS idRolUsuario,
    SU.cApellido ,
    SU.cNombre,
    HU.tfechaInicio,
    HU.tFechaFin,
    RU.usuarioId_fk,
    SU.cUsuario,
    D.cTitulo,
    HD.id,
    TR.horaInicio,
    TR.bTipo,
     d.orden
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getJustificacionesExtendidos]
FECHA: 28/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los horarios de un usuario a partir de su RolUsuarioId y genear asistencia a partir
del horario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getJustificacionesExtendidos]
  @TURNO_ID INT,
  @FECHA DATE
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    j.id as justificacionId,
    j.fecha as fechaJustificacion,
    j.cDetalle as detalleJustificacion,
    j.motivoId_fk as motivoId,
    m.nombre as nombreMotivo,
    te.id as turnoId,
    te.horaInicio as horaInicioTurno
  FROM Justificacion j
    INNER JOIN JustificacionTurnoExtendido jte on jte.justificacionId_fk = j.id and jte.bEliminado = 0
    INNER JOIN TurnoExtendido te on te.id = jte.turnoExtendidoId_fk
    INNER JOIN Motivo m on m.id = j.motivoId_fk and m.bEliminado = 0
  WHERE
  te.id = @TURNO_ID and j.fecha = @FECHA and j.bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getJustificacionesRegulares]
FECHA: 28/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los horarios de un usuario a partir de su RolUsuarioId y genear asistencia a partir
del horario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getJustificacionesRegulares]
  @TURNO_ID INT,
  @FECHA DATE
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    j.id as justificacionId,
    j.fecha as fechaJustificacion,
    j.cDetalle as detalleJustificacion,
    j.motivoId_fk as motivoId,
    m.nombre as nombreMotivo,
    tr.id as turnoId,
    tr.horaInicio as horaInicioTurno
  FROM
    Justificacion j
    INNER JOIN JustificacionTurnoRegular jtr on jtr.justificacionId_fk = j.id and jtr.bEliminado = 0
    INNER JOIN TurnoRegular tr on tr.id = jtr.turnoRegularId_fk AND tr.bEliminado = 0
    INNER JOIN Motivo m on m.id = j.motivoId_fk and m.bEliminado = 0
  WHERE
      tr.id =  @TURNO_ID AND j.fecha = @FECHA AND j.bEliminado = 0;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetLicencia]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Obtener una licencia específica de todas las licencias.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetLicencia]
AS
BEGIN
    SELECT L.id
        , L.rolUsuarioId_fk AS rolUsuarioId
        , usuarioId_fk as usuarioId
        , U.cNombre + ' ' + U.cApellido AS nombreUsuario
        , U.cUsuario AS usuario
        , L.motivoId_fk AS motivoId
        , M.nombre AS motivoNombre
        , r.cTitulo AS rol
        , L.titulo as licenciaTitulo
        , L.detalle as licenciaDetalle
        , CONVERT(VARCHAR(10), L.tFechaInicio, 120) AS fechaInicio
        , CONVERT(VARCHAR(10), L.tFechaFin, 120) AS fechaFin
        , un.id AS unidadId
        , su.cTitulo AS unidadTitulo
    FROM Licencia AS L
        INNER JOIN Motivo AS M
        ON M.id = L.motivoId_fk
        INNER JOIN RolUsuario AS RU
        ON RU.id = L.rolUsuarioId_fk
        INNER JOIN Rol r
        ON r.id = RU.rolId_fk
        INNER JOIN Unidad un
        ON un.id = r.unidadId_fk
        INNER JOIN Sync_Unidad AS SU
        ON SU.id = un.unidadOrgId_fk
        INNER JOIN Sync_Usuario AS U
        ON U.id = RU.usuarioId_fk
    WHERE L.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
    ORDER BY L.tFechaInicio DESC
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetLicenciaById]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Obtener una licencia específica por ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetLicenciaById]
    @LICENCIAID INT
AS
BEGIN
    SELECT L.id
        , L.rolUsuarioId_fk AS rolUsuarioId
        , usuarioId_fk as usuarioId
        , U.cNombre + ' ' + U.cApellido AS nombreUsuario
        , U.cUsuario AS usuario
        , L.motivoId_fk AS motivoId
        , M.nombre AS motivoNombre
        , r.cTitulo AS rol
        , L.titulo AS licenciaTitulo
        , L.detalle as licenciaDetalle
        , CONVERT(VARCHAR(10), L.tFechaInicio, 120) AS fechaInicio
        , CONVERT(VARCHAR(10), L.tFechaFin, 120) AS fechaFin
        , un.id AS unidadId
        , su.cTitulo AS unidadTitulo
    FROM Licencia AS L
        INNER JOIN Motivo AS M
        ON M.id = L.motivoId_fk
        INNER JOIN RolUsuario AS RU
        ON RU.id = L.rolUsuarioId_fk
        INNER JOIN Rol r
        ON r.id = RU.rolId_fk
        INNER JOIN Unidad un
        ON un.id = r.unidadId_fk
        INNER JOIN Sync_Unidad AS SU
        ON SU.id = un.unidadOrgId_fk
        INNER JOIN Sync_Usuario AS U
        ON U.id = RU.usuarioId_fk
    WHERE L.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
        AND L.id = @LICENCIAID
    ORDER BY L.tFechaInicio DESC
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetLicenciaByMotivoId]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Obtener una licencia específica por ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetLicenciaByMotivoId] @MOTIVOID INT
AS
BEGIN
    SELECT L.motivoId_fk AS motivoId
        , L.id AS licenciaId
        , L.rolUsuarioId_fk AS rolUsuario
        , M.nombre
        , M.detalle AS detalleMotivo
        , L.titulo
        , L.detalle AS detalleLicencia
        , CONVERT(VARCHAR(10), L.tFechaInicio, 120) AS fechaInicio
        , CONVERT(VARCHAR(10), L.tFechaFin, 120) AS fechaFin
    FROM Licencia AS L
    INNER JOIN Motivo AS M
        ON M.id = L.motivoId_fk
    INNER JOIN RolUsuario AS RU
        ON RU.id = L.rolUsuarioId_fk
    WHERE L.motivoId_fk = @MOTIVOID
        AND L.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getListarGradosSupervisados]
FECHA: 18-02-2026
AUTOR: Gabriel
OBJETIVO: Listar grados supervisados filtrados por nivel

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   18-02-2026   Gabriel   Creación de procedimiento alineado al repository
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getListarGradosSupervisados]
  @NIVEL_ID CHAR(4)
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    SU.cNombre + ' ' + SU.cApellido AS nombreCompleto,
    R.cTitulo AS rol,
    GN.cGrado AS grado,
    GN.idGrado AS gradoId,
    GN.IdNivel AS nivelId,
    GN.cNivel AS nivel, 
    RU.id AS rolUsuarioId
  FROM GradoSupervisado GS
    INNER JOIN RolUsuario RU ON RU.id = GS.rolUsuarioId_pk
    INNER JOIN Rol R ON R.id = RU.rolId_fk
    INNER JOIN Sync_Usuario SU ON SU.id = RU.usuarioId_fk
    INNER JOIN Sync_GradoNivel GN ON GN.idGrado = GS.idGrado_pk
  WHERE GS.bEliminado = 0
    AND RU.bEliminado = 0
    AND R.bEliminado = 0
    AND GN.IdNivel = @NIVEL_ID;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetManyConectadoDias]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Listar todos los registros de ConectadoDias.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE     PROCEDURE [dbo].[usp_GetManyConectadoDias]
    @TURNO_EXTENDIDO_ID INT 
AS
BEGIN
    SELECT CD.turnoExtendidoId_pk AS turnoExtendidoId
        , CD.diasId_pk AS diasId
        , D.cTitulo AS Dia
        , TE.horaInicio
        , TE.horaFin
    FROM ConectadoDias AS CD
    INNER JOIN TurnoExtendido AS TE
        ON CD.turnoExtendidoId_pk = TE.id
    INNER JOIN Dia AS D
        ON CD.diasId_pk = D.id
    WHERE TE.bEliminado = 0
        AND D.bEliminado = 0
        AND TE.id = @TURNO_EXTENDIDO_ID
END
GO

--=========================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[sp_GetManyHorioDias]
-- Fecha:  17-09-2025
-- Descripcion: Procedimiento para mostrar todos los registros de horarioDia
--=========================================================================================
CREATE   PROCEDURE [dbo].[usp_GetManyHorarioDias]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        h.id AS Id_Horario, hd.id, h.cTitulo AS Nombre_Horario,
        d.cTitulo AS Dia,
        libre = CASE 
  WHEN  bLibre = 1 THEN 'si'
  WHEN  bLibre = 0 THEN 'No'
  END,
        hd.bEliminado, v.tfechaInicio, v.tfechaFin
    FROM HorarioDias AS hd
        INNER JOIN Horario AS h ON hd.horarioId_fk = h.id
        INNER JOIN Dia AS d ON hd.diaId_fk = d.id
        LEFT JOIN Vigencia AS v ON v.horarioDiasId_fk = hd.id
        WHERE hd.bEliminado = 0

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetManyPermiso]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite obtener la lista de permisos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetManyPermiso]
AS
BEGIN
    SELECT rolUsuarioId_fk
        , motivoId_fk 
        , M.nombre AS tituloMotivo
        , P.tfecha
        , P.tHoraSalida
        , P.tHoraRetornoEstimado
        , P.tHoraRetornoReal
        , RU.usuarioId_fk AS rolUsuario
    FROM Permiso AS P
    INNER JOIN Motivo AS M
        ON P.motivoId_fk = M.id
    INNER JOIN RolUsuario AS RU
        ON RU.id = P.rolUsuarioId_fk
    WHERE P.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetManySituacion]
FECHA: 31-07-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Lista todas las situaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetManySituacion]
AS
BEGIN

  SELECT s.id, s.cNombre nombre, s.nOrden orden,  (
    SELECT COUNT(*) 
    FROM ProyectoSituacion ps
    WHERE ps.id_situacion_fk = s.id
      AND ps.bEliminado = 0
  ) 
  AS uso FROM Situacion s
    WHERE bEliminado = 0
END
GO

CREATE   PROCEDURE [dbo].[usp_GetMarcacionCitas]
    @USUARIO INT
AS
BEGIN
    SELECT
        C.id AS citaId,
        U.cNombre AS usuario,
        C.horarioUsuarioId_fk as horarioUsuarioId,
        C.cDescripcion AS descripcion,
        C.fecha AS fecha,
        C.hora AS hora,
        M.punch_time AS fechaMarcacion,
        M.punch_state
    FROM Cita AS C
        INNER JOIN HorarioUsuario HU ON C.horarioUsuarioId_fk = HU.id
        INNER JOIN RolUsuario RU ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario U ON RU.usuarioId_fk = U.id
        INNER JOIN Marcacion M ON U.id = M.emp_id
    WHERE 
    U.id = @USUARIO
        AND CAST(M.punch_time AS DATE) = CAST(C.fecha AS DATE)
        AND C.bCancelado = 0;

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetMarcaciones]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Obtener las marcaciones regulares para una unidad y rango de fechas.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetMarcaciones]
  @UNIDAD_ID INT,
  @FECHA_INICIO DATE,
  @FECHA_FIN DATE,
  @USUARIO VARCHAR(100) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  -- Marcaciones Regulares
      SELECT
      a.id asistenciaId,
      su.cNombre + ' ' + su.cApellido AS nombreCompleto,
      m.punch_time AS horaMarcacion,
      ru.id AS rolUsuarioId,
      m.terminal_alias,
      'regular' AS tipoAsistencia,
      CASE
        WHEN cua.asistenciaId_fk IS NOT NULL
        OR rca.asistenciaId_fk IS NOT NULL
        OR crua.asistenciaId_fk IS NOT NULL
        THEN 'procesado'
        ELSE 'no procesado'
      END AS estadoProcesado,
      CASE
        WHEN ea1.cNombre IS NOT NULL THEN ea1.cNombre
        WHEN ea2.cNombre IS NOT NULL THEN ea2.cNombre
        WHEN ea3.cNombre IS NOT NULL THEN ea3.cNombre
        ELSE 'NO_PROCESADO'
      END AS codigoEstadoProcesado,
      a.horaEntrada,
      a.horaSalida,
      dbio.cNombre AS detalleBiometricoNombre
    FROM Asistencia a
      INNER JOIN AsistenciaRegular ar on ar.asistenciaId_fk = a.id and ar.bEliminado = 0
          LEFT JOIN DetalleBiometrico dbio on dbio.id = ar.detalleBiometricoId_fk and dbio.bEliminado = 0 
      INNER JOIN Marcacion m on m.id = ar.marcacionId_fk and m.bEliminado = 0
      INNER JOIN RolUsuario ru on ru.id = a.rolUsuarioid_fk and ru.bEliminado = 0
      INNER JOIN Rol r on r.id = ru.rolId_fk and r.bEliminado = 0 and r.unidadId_fk = @UNIDAD_ID
      INNER JOIN Sync_Usuario su on su.id = ru.usuarioId_fk
      LEFT JOIN ControlUnidadAsistencia cua ON cua.asistenciaId_fk = a.id AND cua.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea1 on ea1.id = cua.estadoAsistenciaId_fk and ea1.bEliminado = 0
      LEFT JOIN RolControlAsistencia rca ON rca.asistenciaId_fk = a.id AND rca.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea2 on ea2.id = rca.estadoAsistenciaId_fk and ea2.bEliminado = 0
      LEFT JOIN ControlRolUsuarioAsistencia crua ON crua.asistenciaId_fk = a.id AND crua.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea3 on ea3.id = crua.estadoAsistenciaId_fk and ea3.bEliminado = 0
    WHERE CONVERT(DATE, a.tFecha) BETWEEN @FECHA_INICIO AND @FECHA_FIN
      AND ( @USUARIO IS NULL OR su.cUsuario LIKE '%' + @USUARIO + '%' )

  UNION ALL

    -- Marcaciones Extendidas
    SELECT
      a.id asistenciaId,
      su.cNombre + ' ' + su.cApellido AS nombreCompleto,
      m.punch_time AS horaMarcacion,
      ru.id AS rolUsuarioId,
      m.terminal_alias,
      'extendida' AS tipoAsistencia,
      CASE
        WHEN cua.asistenciaId_fk IS NOT NULL
        OR rca.asistenciaId_fk IS NOT NULL
        OR crua.asistenciaId_fk IS NOT NULL
        THEN 'procesado'
        ELSE 'no procesado'
      END AS estadoProcesado,
      CASE
        WHEN ea1.cNombre IS NOT NULL THEN ea1.cNombre
        WHEN ea2.cNombre IS NOT NULL THEN ea2.cNombre
        WHEN ea3.cNombre IS NOT NULL THEN ea3.cNombre
        ELSE 'NO_PROCESADO'
      END AS codigoEstadoProcesado,
      a.horaEntrada,
      a.horaSalida,
      dbio.cNombre AS detalleBiometricoNombre
    FROM Asistencia a
      INNER JOIN AsistenciaExtendida ae on ae.asistenciaId_fk = a.id and ae.bEliminado = 0
          LEFT JOIN DetalleBiometrico dbio on dbio.id = ae.detalleBiometricoId_fk and dbio.bEliminado = 0 
      INNER JOIN Marcacion m on m.id = ae.marcacionId_fk and m.bEliminado = 0
      INNER JOIN RolUsuario ru on ru.id = a.rolUsuarioid_fk and ru.bEliminado = 0
      INNER JOIN Rol r on r.id = ru.rolId_fk and r.bEliminado = 0 and r.unidadId_fk = @UNIDAD_ID
      INNER JOIN Sync_Usuario su on su.id = ru.usuarioId_fk
      LEFT JOIN ControlUnidadAsistencia cua ON cua.asistenciaId_fk = a.id AND cua.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea1 on ea1.id = cua.estadoAsistenciaId_fk and ea1.bEliminado = 0
      LEFT JOIN RolControlAsistencia rca ON rca.asistenciaId_fk = a.id AND rca.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea2 on ea2.id = rca.estadoAsistenciaId_fk and ea2.bEliminado = 0
      LEFT JOIN ControlRolUsuarioAsistencia crua ON crua.asistenciaId_fk = a.id AND crua.bEliminado = 0
        LEFT JOIN EstadoAsistencia ea3 on ea3.id = crua.estadoAsistenciaId_fk and ea3.bEliminado = 0
    WHERE CONVERT(DATE, a.tFecha) BETWEEN @FECHA_INICIO AND @FECHA_FIN
      AND ( @USUARIO IS NULL OR su.cUsuario LIKE '%' + @USUARIO + '%' )

  ORDER BY horaMarcacion DESC
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getMarcacionesExtendidasPorAsistenciaId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Reprocesar asistencia de usuarios en el sistema.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getMarcacionesExtendidasPorAsistenciaId]
  @ASISTENCIA_ID INT,
  @ROL_USUARIO_ID INT
AS
BEGIN
  SELECT
    a.id as asistenciaId,
    ae.id as asistenciaRegularId,
    a.horaEntrada,
    a.horaSalida,
    ae.marcacionId_fk,
    a.rolUsuarioid_fk,
    m.punch_time,
    ptr.permisoId_pk permisoTurnoExtendidoId,
    ptr.tCreatedAt permisoTurnoExtendidoFecha,
    jtr.justificacionId_fk justificacionTurnoExtendidoId,
    jtr.tCreatedAt justificacionTurnoExtendidoFecha
  FROM Asistencia a
    LEFT JOIN AsistenciaExtendida ae on a.id = ae.asistenciaId_fk AND ae.bEliminado = 0
    INNER JOIN Marcacion m on m.id = ae.marcacionId_fk AND m.bEliminado = 0
    LEFT JOIN JustificacionTurnoExtendido jtr on jtr.turnoExtendidoId_fk = ae.turnoExtendidoId_fk
    LEFT JOIN PermisoTurnoExtendido ptr on ptr.turnoExtendidoId_pk = ae.turnoExtendidoId_fk
  WHERE a.id =  @ASISTENCIA_ID AND rolUsuarioid_fk = @ROL_USUARIO_ID
    AND a.bEliminado = 0
END
GO
CREATE   PROCEDURE [dbo].[usp_getMarcacionesPorAsistenciaId]
  @ASISTENCIA_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  -- Consulta principal: Asistencia Regular
  IF EXISTS (
    SELECT 1
  FROM Asistencia a
    LEFT JOIN AsistenciaRegular ar ON a.id = ar.asistenciaId_fk AND ar.bEliminado = 0
    INNER JOIN Marcacion m ON m.id = ar.marcacionId_fk AND m.bEliminado = 0
  WHERE a.id = @ASISTENCIA_ID AND a.bEliminado = 0
  )
  BEGIN
    SELECT
      a.id as asistenciaId,
      ar.id as asistenciaRegularId,
      a.horaEntrada,
      a.horaSalida,
      ar.marcacionId_fk,
      a.rolUsuarioId_fk,
      m.punch_time,
      -- ptr.permisoId_pk permisoTurnoRegularId,
      -- ptr.tCreatedAt permisoTurnoRegularFecha,
      -- jtr.justificacionId_fk justificacionTurnoRegularId,
      -- jtr.tCreatedAt justificacionTurnoRegularFecha,
      -- tm.tHora turnoModificadoHora,
      -- tm.id turnoModificadoId,
      -- CASE 
      --   WHEN tm.btipo = 1 THEN 'SALIDA'
      --   WHEN tm.btipo = 0 THEN 'ENTRADA'
      --   ELSE NULL
      -- END AS turnoModificadoTipo,
      'regular' AS tipoAsistencia,
      null diaConectado,
      m.terminal_alias status
    FROM Asistencia a
      LEFT JOIN AsistenciaRegular ar ON a.id = ar.asistenciaId_fk AND ar.bEliminado = 0
      INNER JOIN Marcacion m ON m.id = ar.marcacionId_fk AND m.bEliminado = 0
      -- LEFT JOIN TurnoModificado tm ON tm.turnoRegularId_fk = ar.turnoRegularId_fk AND tm.bEliminado = 0
      -- LEFT JOIN JustificacionTurnoRegular jtr ON jtr.turnoRegularId_fk = ar.turnoRegularId_fk
      -- LEFT JOIN PermisoTurnoRegular ptr ON ptr.turnoRegularId_pk = ar.turnoRegularId_fk
    WHERE a.id = @ASISTENCIA_ID
      AND a.bEliminado = 0
  END
  ELSE
  BEGIN
    -- Consulta alternativa: Asistencia Extendida
    SELECT
      a.id as asistenciaId,
      ae.id as asistenciaRegularId,
      a.horaEntrada,
      a.horaSalida,
      ae.marcacionId_fk,
      a.rolUsuarioid_fk,
      m.punch_time,
      -- ptr.permisoId_pk permisoTurnoExtendidoId,
      -- ptr.tCreatedAt permisoTurnoExtendidoFecha,
      -- jtr.justificacionId_fk justificacionTurnoExtendidoId,
      -- jtr.tCreatedAt justificacionTurnoExtendidoFecha,
      NULL as turnoModificadoHora,
      NULL as turnoModificadoId,
      NULL as turnoModificadoTipo,
      'extendida' AS tipoAsistencia,
      -- d.cTitulo diaConectado,
      m.terminal_alias status
    FROM Asistencia a
      LEFT JOIN AsistenciaExtendida ae ON a.id = ae.asistenciaId_fk AND ae.bEliminado = 0
      INNER JOIN Marcacion m ON m.id = ae.marcacionId_fk AND m.bEliminado = 0
      -- LEFT JOIN JustificacionTurnoExtendido jtr ON jtr.turnoExtendidoId_fk = ae.turnoExtendidoId_fk
      -- LEFT JOIN PermisoTurnoExtendido ptr ON ptr.turnoExtendidoId_pk = ae.turnoExtendidoId_fk
      -- LEFT JOIN ConectadoDias cd ON cd.turnoExtendidoId_pk = ae.turnoExtendidoId_fk
      -- INNER JOIN Dia d ON d.id = cd.diasId_pk AND d.bEliminado = 0
    WHERE a.id = @ASISTENCIA_ID
      AND a.bEliminado = 0
  END
END
GO

--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetMarcacionUsuarioId]
-- Fecha:  18-12-2025
-- Descripcion: Procedimiento para listar registros de marcacion por el id de usuario
-- Parámetros: 'ID', 'USUARIO','PUNCHSTATE', 'PUNCHSTIME'
--=======================================================================================

CREATE   PROCEDURE [dbo].[usp_GetMarcacionUsuarioId]
    @USUARIO INT

AS
BEGIN
    SELECT
        M.id 
 , RU.id AS rolUsuarioId
 , M.emp_code AS codigoEmpleado
 , M.emp_id AS empleado
, U.cUsuario as syncUsuario
, RU.usuarioId_fk as rol_usuarioid
 , M.punch_state as estado
 , M.terminal_id as biometricoId
 , M.terminal_alias as asliasbiometrico
 , DB.cNombre as biometrico
 , M.punch_time as tiempoMarcacion
    FROM Marcacion AS M
        INNER JOIN Sync_UsuarioPersona AS U ON  M.emp_id = U.id
        INNER JOIN RolUsuario AS RU ON U.id = RU.usuarioId_fk
        INNER JOIN DetalleBiometrico AS DB ON M.terminal_id = DB.id
            AND M.bEliminado = 0
            AND RU.bEliminado = 0
    WHERE M.emp_id = @USUARIO
    ORDER BY 
        M.punch_time DESC
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetNivelesEducativos]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los niveles educativos disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetNivelesEducativos]
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    idNivel AS id,
    nivel AS nivelEducativo
  FROM
    Sync_CursoSeccionPreUniversitaria
  GROUP BY 
    idNivel, nivel
  ORDER BY 
    idNivel DESC;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetNivelesEducativosEscolar]
FECHA: 01-10-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Lista de niveles educativos

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetNivelesEducativosEscolar]
  @PERIODO_LECTIVO_ID INT
AS
BEGIN
  SELECT
    cNivelEducativo as nombre
  FROM Sync_ConfiguracionEtapa
  WHERE idPeriodoLectivo = @PERIODO_LECTIVO_ID
  GROUP BY cNivelEducativo
  ORDER BY cNivelEducativo
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetOneCursoTurnoRegular]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite agregar un nuevo curso en el turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetOneCursoTurnoRegular]
  @CURSO_TURNOREGULAR_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    csptr.id, -- id CursoTurnoRegular
    cpu.cursoPreUniversitario,
    cpu.centroEstudios
  FROM
    CursoSeccionPreUniversitaria_TurnoRegular as csptr
    INNER JOIN
    Sync_CursoSeccionPreUniversitaria cpu
    ON cpu.id = csptr.syncCursoSeccionPreUniversitariaId
  WHERE 
    csptr.id = @CURSO_TURNOREGULAR_ID
    AND bEliminado = 0;
END
GO

/*=================================================================================
Nombre: [dbo].[usp_GetOneEstadoAsistencia]
Autor: Jesamine Ramon Yora
Fecha: 09-10-2025
Descripcion: Procedimiento para mostrar un registro a partir del ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
--=================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetOneEstadoAsistencia] @ID INT
AS
BEGIN
    SELECT EA.id
        , EA.cNombre AS nombre
        , CASE 
            WHEN CRUA.id IS NOT NULL
                OR CUA.id IS NOT NULL
                OR RCA.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS USO
    FROM EstadoAsistencia EA
    LEFT JOIN ControlRolUsuarioAsistencia CRUA
        ON EA.id = CRUA.estadoAsistenciaId_fk
            AND CRUA.bEliminado = 0
    LEFT JOIN ControlUnidadAsistencia CUA
        ON EA.id = CUA.estadoAsistenciaId_fk
            AND CUA.bEliminado = 0
    LEFT JOIN RolControlAsistencia RCA
        ON EA.id = RCA.estadoAsistenciaId_fk
            AND RCA.bEliminado = 0
    WHERE EA.id = @ID
        AND EA.bEliminado = 0
    GROUP BY EA.id
        , EA.cNombre
        , CRUA.id
        , CUA.id
        , RCA.id;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetOneSituacion]
FECHA: 31-07-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Descripcion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetOneSituacion]
  @ID INT
AS
BEGIN
  SELECT id, cNombre nombre, nOrden orden FROM Situacion
    WHERE id = @ID and bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetPeriodos]
FECHA: 19/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener los periodos lectivos disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetPeriodos]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        idPeriodoLectivo AS id,
        cPeriodoLectivo AS nombre
    FROM
        Sync_Temporada
    GROUP BY 
        idPeriodoLectivo, cPeriodoLectivo
    ORDER BY 
        idPeriodoLectivo DESC;
END
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetPeriodoVacacional]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar periodos vacacionales

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetPeriodoVacacional] 
    @IDCONTROLVACACIONAL INT
AS
BEGIN
    SELECT PV.id
        , PV.fechaInicio AS fechaInicio
        , PV.fechaFin AS fechaFin
        , PV.nDiasConsumidos AS diasConsumidos
    FROM PeriodoVacacional PV
    WHERE bEliminado = 0
        AND PV.controlVacacionalId_fk = @IDCONTROLVACACIONAL
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetPermisoById]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite obtener la lista de permisos por ID.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetPermisoById] @PERMISOID INT
AS
BEGIN
    SELECT rolUsuarioId_fk
        , motivoId_fk
        , P.tfecha
        , P.tHoraSalida
        , P.tHoraRetornoEstimado
        , P.tHoraRetornoReal
        , M.nombre AS nombreMotivo
        , RU.usuarioId_fk
    FROM Permiso AS P
    INNER JOIN Motivo AS M
        ON P.motivoId_fk = M.id
    INNER JOIN RolUsuario AS RU
        ON RU.id = P.rolUsuarioId_fk
    WHERE P.id = @PERMISOID
        AND P.bEliminado = 0
        AND M.bEliminado = 0
        AND RU.bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getPermisosExtendidos]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los registros de permisos extendidos

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getPermisosExtendidos]
  @TURNO_EXTENDIDO_ID INT,
  @FECHA DATE
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    p.id AS permisoId,
    p.tfecha AS fechaPermiso,
    p.tHoraSalida AS horaSalida,
    p.tHoraRetornoEstimado AS horaRetornoEstimado,
    p.tHoraRetornoReal AS horaRetornoReal,
    te.id AS turnoExtendidoId,
    te.horaInicio AS turnoExtendidoHoraInicio,
    p.motivoId_fk AS motivoId,
    m.nombre AS motivoNombre
  FROM
    Permiso p
    INNER JOIN
    PermisoTurnoExtendido pte ON pte.permisoId_pk = p.id
    INNER JOIN
    TurnoExtendido te ON te.id = pte.turnoExtendidoId_pk
    INNER JOIN
    Motivo m ON m.id = p.motivoId_fk
  WHERE
      te.id =  @TURNO_EXTENDIDO_ID AND p.tfecha = @FECHA AND p.bEliminado = 0;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getPermisosRegulares]
FECHA: 22-09-2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los registros de permisos extendidos

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getPermisosRegulares]
  @TURNO_REGULAR_ID INT,
  @FECHA DATE
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    p.id AS permisoId,
    p.tfecha AS fechaPermiso,
    p.tHoraSalida AS horaSalida,
    p.tHoraRetornoEstimado AS horaRetornoEstimado,
    p.tHoraRetornoReal AS horaRetornoReal,
    tr.id AS turnoRegularId,
    tr.horaInicio AS turnoRegularHoraInicio,
    p.motivoId_fk AS motivoId,
    m.nombre AS motivoNombre
  FROM
    Permiso p
    INNER JOIN
    PermisoTurnoRegular ptr ON ptr.permisoId_pk = p.id
    INNER JOIN
    TurnoRegular tr ON tr.id = ptr.turnoRegularId_pk
    INNER JOIN
    Motivo m ON m.id = p.motivoId_fk
  WHERE
      tr.id =  @TURNO_REGULAR_ID AND p.tfecha = @FECHA AND p.bEliminado = 0;
END
GO
/*======================================================================================================
NOMBRE: [dbo].[usp_GetPermisoTurnoExtendidoById]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Lista el permisoTurnoExtendido por ID persmiso y turno.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE    PROCEDURE [dbo].[usp_GetPermisoTurnoExtendidoById] @PERMISOID INT
    , @TURNOID INT
AS
BEGIN
   SELECT
        U.cNombre, U.cApellido,
        M.nombre, TE.horaInicio,
        P.tfecha, P.tHoraSalida
        ,P.id AS permisoId
        ,TE.id AS turnoId

    FROM PermisoTurnoExtendido AS PE
        LEFT JOIN TurnoExtendido AS TE
        ON PE.turnoExtendidoId_pk = TE.id
            AND TE.bEliminado = 0
        INNER JOIN Permiso AS P
        ON PE.permisoId_pk = P.id
            AND P.bEliminado = 0
        INNER JOIN Motivo AS M
        ON P.motivoId_fk = M.id
            AND M.bEliminado = 0
        INNER JOIN RolUsuario as RU
        ON P.rolUsuarioId_fk = RU.id
            AND RU.bEliminado = 0
        INNER JOIN Sync_Usuario as U
        ON RU.usuarioId_fk = U.id
    WHERE PE.permisoId_pk = @PERMISOID
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetPermisoTurnoRegularById]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Lista el permisoTurnoRegular por ID persmiso y turno.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetPermisoTurnoRegularById] @PERMISOID INT
    , @TURNOID INT
AS
BEGIN
SELECT
        U.cNombre, U.cApellido,
        M.nombre, TR.horaInicio,
        P.tfecha, P.tHoraSalida,
        P.id AS permisoId,
        TR.id AS turnoId

    FROM PermisoTurnoRegular AS PR
        LEFT JOIN TurnoRegular AS TR
        ON PR.turnoRegularId_pk = TR.id
            AND TR.bEliminado = 0
        INNER JOIN Permiso AS P
        ON PR.permisoId_pk = P.id
            AND P.bEliminado = 0
        INNER JOIN Motivo AS M
        ON P.motivoId_fk = M.id
            AND M.bEliminado = 0
        INNER JOIN RolUsuario as RU
        ON P.rolUsuarioId_fk = RU.id
            AND RU.bEliminado = 0
        INNER JOIN Sync_Usuario as U
        ON RU.usuarioId_fk = U.id
    WHERE PR.permisoId_pk = @PERMISOID
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetRolControlAsistenciaEstado]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles de rolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetRolControlAsistenciaEstado]
    @ASISTENCIA_ID INT = NULL
AS
BEGIN
    SELECT
        a.id asistenciaId,
        ea.id estadoAsistenciaId,
        ea.cNombre estadoAsitencia,
        c.nTolerancia tolerancia,
        c.nLimiteFalta limiteFalta,
        c.nLimiteMarcacion limiteMarcacion,
        rc.id rolControlId
    FROM RolControlAsistencia rca
        INNER JOIN RolControl rc on rc.id = rca.rolControlId_fk
        INNER JOIN Controles c on c.id = rc.controlId_fk
        INNER JOIN EstadoAsistencia ea on ea.id = rca.estadoAsistenciaId_fk
        INNER JOIN Asistencia a on a.id = rca.asistenciaId_fk
    WHERE 
        rc.bEliminado = 0 AND
        rca.bEliminado = 0 AND
        rc.bEliminado = 0 AND
        c.bEliminado = 0 AND
        ea.bEliminado = 0 AND
        A.bEliminado = 0 AND
        a.id = @ASISTENCIA_ID
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_getRolesUsuarioByDNI]
FECHA: 20/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los roles y horarios de un usuario a partir de su DNI.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getRolesUsuarioByDNI]
  @DNI NVARCHAR(20)
AS
BEGIN
  SET NOCOUNT ON;
  SELECT su.id usuarioId, ru.id rolUsuarioId, r.cTitulo rol, hu.horarioId_fk horarioId
  FROM Sync_Usuario su
    INNER JOIN RolUsuario  ru on ru.usuarioId_fk = su.id and ru.bEliminado = 0
    INNER JOIN Rol r ON r.id = ru.rolId_fk AND r.bEliminado = 0
    INNER JOIN HorarioUsuario hu on hu.rolUsuarioId_fk = ru.id AND hu.bEliminado = 0
    inner JOIN Horario h on h.id = hu.horarioId_fk AND h.bEliminado = 0
  WHERE su.cDni = @DNI
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetRolUsuario]
FECHA: 15-10-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite listar todas los RolUsuario existentes.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetRolUsuario]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RU.id
        , RU.usuarioId_fk AS usuarioId
        , U.cUsuario AS usuario
        , RU.rolId_fk AS rolId
        , R.cTitulo AS rol
        , CASE 
            WHEN
                -- Verifica si el rolUsuario está en uso
                EXISTS (
                    SELECT 1
            FROM Licencia L
            WHERE L.rolUsuarioId_fk = RU.id
                AND L.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Permiso P
            WHERE P.rolUsuarioId_fk = RU.id
                AND P.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Justificacion J
            WHERE J.rolUsuarioId_fk = RU.id
                AND J.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM ControlVacaciones CV
            WHERE CV.rolUsuarioId_fk = RU.id
                AND CV.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM ControlRolUsuario CRU
            WHERE CRU.rolUsuarioId_fk = RU.id
                AND CRU.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Asistencia A
            WHERE A.rolUsuarioid_fk = RU.id
                AND A.bEliminado = 0
                    )
                THEN 1
            ELSE 0
            END AS uso
    FROM RolUsuario AS RU
        INNER JOIN Rol AS R
        ON RU.rolId_fk = R.id
            AND R.bEliminado = 0
        INNER JOIN Sync_Usuario AS U
        ON RU.usuarioId_fk = U.id
    WHERE RU.bEliminado = 0
    ORDER BY RU.id;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetRolUsuarioById]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar rol de usuario por Id

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetRolUsuarioById]
    @ROL_USUARIO_ID INT 
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ru.id AS usuarioRolId,
        r.id AS rolId,
        r.cTitulo AS rol,
        r.bSupervision AS supervision,
        su.id AS usuarioId,
        CASE 
            WHEN ru.id IS NOT NULL THEN 1 
            ELSE 0 
        END AS asignado,
        CASE 
            WHEN ru.id IS NOT NULL AND (
                   EXISTS (SELECT 1 FROM ControlVacaciones cv WHERE cv.rolUsuarioId_fk = ru.id)
                OR EXISTS (SELECT 1 FROM HorarioUsuario hu WHERE hu.rolUsuarioId_fk = ru.id)
                OR EXISTS (SELECT 1 FROM TurnoModificado tm WHERE tm.rolUsuarioId_fk = ru.id)
                OR EXISTS (SELECT 1 FROM Licencia li WHERE li.rolUsuarioId_fk = ru.id)
                OR EXISTS (SELECT 1 FROM Permiso pe WHERE pe.rolUsuarioId_fk = ru.id)
            )
            THEN 1
            ELSE 0
        END AS enUso
    FROM Rol r
        inner JOIN RolUsuario ru
            ON ru.rolId_fk = r.id
           AND ru.bEliminado = 0
        inner JOIN Sync_Usuario su on su.id = ru.usuarioId_fk
            
    WHERE 
        r.bEliminado = 0
        AND ru.bEliminado = 0
        AND ru.id = @ROL_USUARIO_ID
    ORDER BY asignado DESC;
END
GO

--===================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetSupervisor]
-- Fecha: 06-10-2025
-- Descripcion: Procedimiento para mostrar todos los registros de la tabla Supervisor
-- Parámetros a mostrar: 
-- @USUARIO_ID: id de un registro de la tabla Sync_Usuario (int)
-- @UNIDAD_ID: id de un registro de la tabla Unidad (int)
-- @USUARIO: el nombre del usuario
-- @TITULO : El nombre de la unidad 
--===================================================================================
CREATE   PROCEDURE [dbo].[usp_GetSupervisor]

AS
BEGIN 
    SET NOCOUNT ON;

    SELECT su.usuarioId_pk, u.cUsuario, u.cNombre as nombre, u.cApellido as apellido ,su.unidadId_pk, ud.cTitulo AS titulo
    FROM Supervisor AS su 
    INNER JOIN Sync_Usuario AS u ON  su.usuarioId_pk = u.id
    INNER JOIN Unidad AS un ON su.unidadId_pk = un.id
    INNER JOIN Sync_Unidad AS  ud ON un.unidadOrgId_fk = ud.id
END
GO

--===================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetSupervisorId]
-- Fecha: 30-10-2025
-- Descripcion: Procedimiento para mostrar todos los registros de los supervisores por unidad
-- Parámetros: 
-- @UNIDAD_ID: id de un registro de la tabla Unidad (int)
--===================================================================================

CREATE   PROCEDURE [dbo].[usp_GetSupervisorId]
    @UNIDAD_ID  INT 
AS 
BEGIN 
    SET NOCOUNT ON;

    SELECT su.usuarioId_pk as usuarioId, u.cNombre as nombre, u.cApellido as apellido, u.cUsuario as Usuario, su.unidadId_pk as unidadId, ud.cTitulo as titulo
    FROM Supervisor AS su 
    INNER JOIN Sync_Usuario AS u ON  su.usuarioId_pk = u.id
    INNER JOIN Unidad AS un ON su.unidadId_pk = un.id
    INNER JOIN Sync_Unidad AS  ud ON un.unidadOrgId_fk = ud.id
    WHERE su.unidadId_pk = @UNIDAD_ID
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetTemporadas]
FECHA: 19/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite obtener las temporadas disponibles.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetTemporadas]
    @PERIODO_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        idTemporada AS id,
        cTemporada AS nombre
    FROM
        Sync_Temporada
    WHERE 
        idPeriodoLectivo = @PERIODO_ID
    GROUP BY 
        idTemporada, cTemporada
    ORDER BY 
        idTemporada DESC;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoExtendido]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los turnos extendido, no eliminados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetTurnoExtendido]
AS
BEGIN
    SELECT TE.id
        , TE.horarioDiasId_fk
        , D.cTitulo AS Dia
        , H.cTitulo AS Horario
        , horaInicio  as horaInicio
        , TE.horaFin as horaFin
        , CASE 
            WHEN HD.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS USO
    FROM TurnoExtendido AS TE
        LEFT JOIN HorarioDias AS HD
        ON TE.horarioDiasId_fk = HD.id
        LEFT JOIN Dia AS D
        ON HD.diaId_fk = D.id
        LEFT JOIN Horario AS H
        ON HD.horarioId_fk = H.id
    WHERE TE.bEliminado = 0
        AND HD.bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoExtendidoById]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Listar todos los turnos extendido por id, no eliminados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetTurnoExtendidoById] @TURNOEXTENDIDOID INT
AS
BEGIN
    SELECT TE.id
        , TE.horarioDiasId_fk AS horarioDiasId
        , TE.horaInicio AS horaInicio
        , TE.horaFin AS horaFin
        , D.cTitulo AS dia
        , CASE 
            WHEN HD.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS uso
    FROM TurnoExtendido AS TE
    LEFT JOIN HorarioDias AS HD
        ON TE.horarioDiasId_fk = HD.id
    LEFT JOIN Dia D ON HD.diaId_fk = D.id
    WHERE TE.id = @TURNOEXTENDIDOID
        AND TE.bEliminado = 0
        AND HD.bEliminado = 0
END
GO

--=======================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetTurnoExtendidoHorario]
-- Fecha:  01-10-2025
-- Descripcion: Procedimiento para mostrar los resgistros de Turno Extendido por Horario
-- Parámetros: 'IDHORARIO'
-- IDHORARIO: ID de un horario 
--=======================================================================================
CREATE    PROCEDURE [dbo].[usp_GetTurnoExtendidoHorario]
    @IDHORARIO INT,
    @FECHA_INICIO DATE= NULL,
    @FECHA_FIN DATE = NULL,
    @Message VARCHAR(250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        te.id as id,
        h.id as horarioId,
        hd.id as horarioDiasId,
        h.cTitulo as horario,
        d.cTitulo as dia,
        CAST(te.horaInicio AS VARCHAR(5)) AS horaInicio,
        CAST(te.horaFin AS VARCHAR(5)) AS horaFin,
        hd.bLibre as diaLibre,
        CASE 
            WHEN cd.diasId_pk = dc.id  THEN dc.cTitulo
            ELSE 'sin dia'
        END as diaFin,
        cd.diasId_pk as diaFinId,
         CAST(v.tFechaInicio AS VARCHAR(12)) AS fechaInicio,
        CAST(v.tFechaFin AS VARCHAR(12))AS fechaFin
    FROM Horario h
        INNER JOIN HorarioDias hd on hd.horarioId_fk = h.id
        INNER JOIN Dia d on d.id = hd.diaId_fk
        LEFT JOIN TurnoExtendido te on te.horarioDiasId_fk = hd.id
        LEFT JOIN ConectadoDias AS cd ON cd.turnoExtendidoId_pk = te.id
        LEFT JOIN Dia AS dc ON cd.diasId_pk = dc.id
        LEFT JOIN Vigencia v ON hd.id = v.horarioDiasId_fk
    WHERE h.id = @IDHORARIO AND
    h.bEliminado = 0 AND
        hd.bEliminado = 0 AND
        d.bEliminado = 0 AND
        te.bEliminado = 0 AND
        v.bActivo = 1
    AND (@FECHA_INICIO IS NULL OR v.tFechaInicio = @FECHA_INICIO) AND (@FECHA_FIN IS NULL OR v.tFechaFin = @FECHA_FIN)
    

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite listar todos los turnos regulares no eliminados.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetTurnoRegular]
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TR.id
        , TR.horarioDiasId_fk
        , TR.orden
        , TR.horaInicio
        , CASE 
            WHEN TR.bTipo = 0
                THEN 'ENTRADA'
            WHEN TR.bTipo = 1
                THEN 'SALIDA'
            END AS TipoTurno
        , CASE 
            WHEN HD.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS USO
    FROM TurnoRegular AS TR
    LEFT JOIN HorarioDias AS HD
        ON TR.horarioDiasId_fk = HD.id
            AND HD.bEliminado = 0
    -- LEFT JOIN Vigencia AS V
    --     ON V.horarioDiasId_pk = HD.id
    WHERE TR.bEliminado = 0
    -- AND V.bEliminado = 0
    ORDER BY TR.id
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetTurnoRegularById]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO:Permite listar todos los turnos regulares por Id.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetTurnoRegularById] @TURNOREGULARID INT
AS
BEGIN
    SELECT TR.id
        , TR.horarioDiasId_fk AS horarioDiasId
        , TR.orden AS orden
        , d.cTitulo AS dia
        , FORMAT(TR.horaInicio, 'HH:mm:ss') as horaInicio
        , CASE 
            WHEN TR.bTipo = 0
                THEN 'ENTRADA'
            ELSE 'SALIDA'
            END AS tipoTurno
        , CASE 
            WHEN HD.id IS NOT NULL
                THEN 1
            ELSE 0
            END AS uso
    FROM TurnoRegular AS TR
    LEFT JOIN HorarioDias AS HD
        ON TR.horarioDiasId_fk = HD.id
            AND HD.bEliminado = 0
    INNER JOIN Dia as d
        ON HD.diaId_fk = d.id
            AND d.bEliminado = 0
    WHERE TR.id = @TURNOREGULARID
        AND TR.bEliminado = 0;
END
GO

--===================================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_GetTurnoRegularHorario]
-- Fecha:  01-10-2025
-- Descripcion: Procedimiento para mostrar los resgistros de Turno Regular a parti del id de Horario
-- Parámetros: 'IDHORARIO'
-- IDHORARIO: ID de un horario 
--===================================================================================================
CREATE   PROCEDURE [dbo].[usp_GetTurnoRegularHorario]
    @HORARIOID INT,
    @FECHA_INICIO DATE = NULL,
    @FECHA_FIN DATE = NULL,
    @Message VARCHAR (250) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1
        FROM HorarioDias
        WHERE horarioId_fk = @HORARIOID
    )
    BEGIN
        SET @Message = 'No hay turnos configurados para este horario'
        RETURN;
    END

    ;WITH TurnosOrdenados AS
    (
        SELECT 
            t.id,
            hd.id as horarioDiaId,
            t.orden,
            h.cTitulo AS horario,
            d.cTitulo AS dia,
            t.horaInicio,
            h.horaDia as totalHoras,
            t.bTipo,
            hd.bLibre,
            d.orden as ordenDia,
            v.tFechaInicio,
            v.tFechaFin,

            ROW_NUMBER() OVER(
                PARTITION BY hd.id 
                ORDER BY t.horaInicio
            ) AS fila

        FROM TurnoRegular AS t
        INNER JOIN HorarioDias AS hd ON t.horarioDiasId_fk = hd.id
        INNER JOIN Horario AS h ON hd.horarioId_fk = h.id
        INNER JOIN Dia As d ON hd.diaId_fk = d.id
        LEFT JOIN Vigencia V ON hd.id = v.horarioDiasId_fk
        WHERE h.id = @HORARIOID
        AND t.bEliminado = 0 
        AND hd.bLibre = 0 
        AND v.bActivo = 1
        AND (@FECHA_INICIO IS NULL OR v.tFechaInicio = @FECHA_INICIO)
        AND (@FECHA_FIN IS NULL OR v.tFechaFin = @FECHA_FIN)
    )

    SELECT
        id,
        horarioDiaId,
        orden,
        horario,
        dia,
        CAST(horaInicio AS VARCHAR(5)) AS horaInicio,
        totalHoras,
        tipo = CASE 
            WHEN bTipo = 1 THEN 'Salida'
            WHEN bTipo = 0 THEN 'Entrada'
        END,
        turno = 'Turno ' + CAST(CEILING(fila / 2.0) AS VARCHAR),
        libre = CASE 
            WHEN bLibre = 1 THEN 'Si'
            WHEN bLibre = 0 THEN 'No'
        END,
        CAST(tFechaInicio AS VARCHAR(12)) AS fechaInicio,
        CAST(tFechaFin AS VARCHAR(12)) AS fechaFin

    FROM TurnosOrdenados
    ORDER BY ordenDia ASC, horaInicio ASC

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_insertControlRolUsuarioAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de rol de usuario para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getTurnoRegularOExtendido]
  @ROL_USUARIO_ID INT,
  @FECHA DATETIME2(0),
  @HORA DATETIME2(0)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @turnoRegularId INT = NULL, @turnoExtendidoId INT = NULL;

  -- Buscar turno regular por hora de entrada
  WITH
    FechaHora
    AS
    (
      SELECT
        CAST(@FECHA AS DATE) AS fecha,
        CAST(@HORA AS TIME) AS horaEntrada,
        CASE DATEPART(WEEKDAY, CAST(@FECHA AS DATE))
              WHEN 1 THEN 'Domingo'
              WHEN 2 THEN 'Lunes'
              WHEN 3 THEN 'Martes'
              WHEN 4 THEN 'Miércoles'
              WHEN 5 THEN 'Jueves'
              WHEN 6 THEN 'Viernes'
              WHEN 7 THEN 'Sábado'
            END AS diaNombre
    )
  SELECT
    @turnoRegularId = tr.id,
    @turnoExtendidoId = te.id
  FROM FechaHora fh
    INNER JOIN HorarioUsuario hu ON hu.rolUsuarioId_fk = @ROL_USUARIO_ID AND hu.bEliminado = 0
    INNER JOIN HorarioDias hd ON hd.horarioId_fk = hu.horarioId_fk AND hd.bEliminado = 0
      AND hd.diaId_fk = (SELECT d.id
      FROM Dia d
      WHERE d.cTitulo = fh.diaNombre)
    LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id AND tr.horaInicio = fh.horaEntrada
    LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id AND te.horaInicio = fh.horaEntrada;

  -- Si no se encontró turno regular ni extendido, buscar por hora de salida
  IF @turnoRegularId IS NULL AND @turnoExtendidoId IS NULL
        BEGIN
    WITH
      FechaHora
      AS
      (
        SELECT
          CAST(@FECHA AS DATE) AS fecha,
          CAST(@HORA AS TIME) AS horaSalida,
          CASE DATEPART(WEEKDAY, CAST(@FECHA AS DATE))
                WHEN 1 THEN 'Domingo'
                WHEN 2 THEN 'Lunes'
                WHEN 3 THEN 'Martes'
                WHEN 4 THEN 'Miércoles'
                WHEN 5 THEN 'Jueves'
                WHEN 6 THEN 'Viernes'
                WHEN 7 THEN 'Sábado'
              END AS diaNombre
      )
    SELECT
      @turnoRegularId = tr.id,
      @turnoExtendidoId = te.id
    FROM FechaHora fh
      INNER JOIN HorarioUsuario hu ON hu.rolUsuarioId_fk = @ROL_USUARIO_ID AND hu.bEliminado = 0
      INNER JOIN HorarioDias hd ON hd.horarioId_fk = hu.horarioId_fk AND hd.bEliminado = 0
        AND hd.diaId_fk = (SELECT d.id
        FROM Dia d
        WHERE d.cTitulo = fh.diaNombre)
      LEFT JOIN TurnoRegular tr ON tr.horarioDiasId_fk = hd.id AND tr.horaInicio = fh.horaSalida
      LEFT JOIN TurnoExtendido te ON te.horarioDiasId_fk = hd.id AND te.horaFin = fh.horaSalida;
  END

  SELECT @turnoRegularId AS turnoRegularId, @turnoExtendidoId AS turnoExtendidoId;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetUnidades]
FECHA: 21-11-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar unidades organizaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetUnidades]
AS
BEGIN
    SELECT
        U.id AS unidadId,
        SU.id AS abreviacion,
        SU.cTitulo AS titulo
    FROM Sync_Unidad SU
      LEFT JOIN Unidad U
        ON SU.id = U.unidadOrgId_fk AND U.bEliminado = 0
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetUsuarioByHorario]
FECHA: 10-02-2025
AUTOR: Jeandry Angulo Marquez
OBJETIVO: muestra el los usuarios relacionados a un horario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetUsuarioByHorario]
    @HORARIO_ID INT = NULL
AS
BEGIN

    SELECT
        H.id AS id
, U.cNombre AS nombre
, U.cApellido AS apellido
, U.cDni AS dni
, r.cTitulo AS rol
, UO.cTitulo AS unidad
, H.cTitulo AS titulo
, RU.id AS idRolUsuario
    FROM HorarioUsuario HU
        INNER JOIN Horario H ON  HU.horarioId_fk = H.id
        INNER JOIN RolUsuario RU ON HU.rolUsuarioId_fk = RU.id
        INNER JOIN Sync_Usuario U ON RU.usuarioId_fk = U.id
        INNER JOIN Rol R ON RU.rolId_fk = R.id
        LEFT JOIN Unidad UD ON R.unidadId_fk = UD.id
        LEFT JOIN Sync_Unidad UO ON UD.unidadOrgId_fk = UO.id
    WHERE H.id = @HORARIO_ID AND HU.bEliminado = 0
END
GO


CREATE     PROCEDURE [dbo].[usp_GetUsuarioByRol]
@UNIDAD_ID INT = NULL,
@ROL_ID INT = NULL,
@MOSTRAR_HORARIOS BIT = 1
AS
BEGIN
SELECT
    SU.id,
    R.id AS rolId,
    SU.cUsuario as usuario, 
    SU.cNombre as nombre,
    SU.cApellido as apellido,
    SU.cTipo as tipo,
    RU.id AS idRolUsuario,
    R.cTitulo AS rol, 
    SU.cDni AS dni,
    UN.cTitulo AS unidad,
    COUNT(HU.id) as horarios,
    CASE WHEN @MOSTRAR_HORARIOS = 1 THEN 1 ELSE 0 END AS todos 
FROM Sync_Usuario SU
    INNER JOIN RolUsuario RU ON RU.usuarioId_fk = SU.id
    LEFT JOIN HorarioUsuario HU ON HU.rolUsuarioId_fk = RU.id AND HU.bEliminado = 0
    INNER JOIN ROL R ON RU.rolId_fk = R.id
    LEFT JOIN  Unidad U ON R.unidadId_fk = U.id
    LEFT JOIN Sync_Unidad UN ON U.unidadOrgId_fk = UN.id
    WHERE (@UNIDAD_ID IS NULL OR U.id = @UNIDAD_ID) 
    AND (@ROL_ID IS NULL OR R.id = @ROL_ID)  
    AND (
        @MOSTRAR_HORARIOS = 0 OR
        (SELECT COUNT(1) FROM HorarioUsuario UH WHERE UH.rolUsuarioId_fk = RU.id AND UH.bEliminado = 0) > 0
    )
    AND RU.bEliminado = 0
    GROUP BY
    SU.id,
    R.id,
    SU.cUsuario,
    SU.cNombre,
    SU.cApellido,
    SU.cTipo,
    RU.id,
    R.cTitulo,
    SU.cDni,
    UN.cTitulo
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_getUsuariosWithRoles]
FECHA: 11-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Obtener los usuarios con sus roles

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getUsuariosWithRoles]
  @UNIDAD_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    su.cDni dni,
    su.cNombre  + ' ' + su.cApellido as nombre,
    r.cTitulo rol,
    ru.id rolUsuarioId,
    h.cTitulo horario,
    hu.horarioId_fk horarioId,
    hu.tFechaInicio AS fechaInicio,
    hu.tFechaFin AS fechaFin,
    CASE
      WHEN CAST(GETDATE() AS DATE) BETWEEN hu.tFechaInicio AND hu.tFechaFin THEN 0
      ELSE 1
    END AS vencido
  FROM Sync_Usuario su
    INNER JOIN RolUsuario ru on ru.usuarioId_fk = su.id
    INNER JOIN Rol r on r.id = ru.rolId_fk
    INNER JOIN HorarioUsuario hu ON hu.rolUsuarioId_fk = ru.id
    INNER JOIN Horario h ON h.id = hu.horarioId_fk
    INNER JOIN HorarioDias hd ON hd.horarioId_fk = h.id
  WHERE r.unidadId_fk = @UNIDAD_ID AND h.bEliminado = 0
  GROUP BY su.cDni, su.cNombre, su.cApellido, r.cTitulo, ru.id, h.cTitulo, hu.horarioId_fk, hu.tFechaInicio, hu.tFechaFin
  ORDER BY su.cNombre + ' ' + su.cApellido
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_getVacacionesPorRolUsuarioId]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de rol de usuario para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_getVacacionesPorRolUsuarioId]
  @ROL_USUARIO_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT pv.fechaInicio, pv.fechaFin, cv.rolUsuarioId_fk as rolUsuarioId, cv.id controlId
  FROM PeriodoVacacional pv
    INNER JOIN ControlVacaciones cv on cv.id = pv.controlVacacionalId_fk
  WHERE cv.rolUsuarioId_fk = @ROL_USUARIO_ID AND YEAR(pv.fechaInicio) = YEAR(GETDATE()) AND (MONTH(pv.fechaInicio) = month(GETDATE()) OR MONTH(pv.fechaFin) = month(GETDATE())) and pv.bEliminado = 0 and cv.bEliminado = 0;
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_GetVigenciaDeHorarioDia]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar las vigencias asociadas a un horario día

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetVigenciaDeHorarioDia]
    @HORARIO_DIA_ID INT
AS
BEGIN
    SELECT
        v.id AS id,
        hd.id as horarioDiaId
   , h.cTitulo as horario
    , h.id as horarioId
     , CASE 
            WHEN v.bTipo = 1 THEN 'Por Día' 
            ELSE 'Por Horario'
        END AS tipoVigencia
        , d.cTitulo as dia
        , v.bActivo as activo
        , CAST(v.tfechaInicio as VARCHAR(10)) AS fechaInicio
        , CAST(v.tfechaFin as VARCHAR(10)) AS fechaFin
        , V.bEliminado
    FROM Vigencia v
        INNER JOIN HorarioDias hd ON  v.horarioDiasId_fk  = hd.id
        INNER JOIN Horario h ON hd.horarioId_fk = h.id
        INNER JOIN Dia d ON hd.diaId_fk = d.id
    WHERE v.horarioDiasId_fk = @HORARIO_DIA_ID AND v.bEliminado = 0
    ORDER BY v.tFechaFin DESC
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetVigenciaGlobal]
FECHA: 15-01-2026
AUTOR: Jeandry Angulo Marquez
OBJETIVO: Lista las vigencias de un horario por el id del horario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetVigenciaGlobal]
    @HORARIO_ID INT
AS
BEGIN

    SELECT
        ROW_NUMBER() OVER (ORDER BY h.id , v.tfechaInicio)AS idFila,
        h.id AS horarioId,
        h.cTitulo AS titulo,
        CAST(v.tfechaInicio AS VARCHAR(10)) AS fechaInicio,
        CAST( v.tfechaFin AS VARCHAR(10))AS fechaFin,
        COUNT(hd.id) AS total_dias,
        CASE 
            WHEN v.bTipo = 1 THEN 'Por Día' 
            ELSE 'Por Horario'
        END AS TipoVigencia,
        CASE 
            WHEN v.bActivo = 1 THEN 'si' else 'no' end as activo
    FROM Vigencia v
        INNER JOIN HorarioDias hd ON v.horarioDiasId_fk = hd.id
        INNER JOIN Horario h ON hd.horarioId_fk = h.id
    WHERE h.id = @HORARIO_ID
        AND v.bEliminado = 0
        AND h.bEliminado = 0
        AND v.bActivo = 1
    GROUP BY 
    h.id, 
    h.cTitulo,
    v.tFechaInicio, 
    v.tFechaFin,
    v.bTipo,
    v.bActivo
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_GetVigenciasPorHorario]
FECHA: 17-09-2025
AUTOR: Admer Vasquez Uscuvilca
OBJETIVO: Lista las vigencias de un horario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_GetVigenciasPorHorario]
  @HORARIO_ID INT
AS
BEGIN
  SELECT
    h.id as horarioId,
    v.tFechaInicio as fechaInicio,
    v.tFechaFin as fechaFin
  FROM
    Horario h
    INNER JOIN HorarioDias hd on h.id = hd.horarioId_fk
    INNER JOIN Vigencia v on v.horarioDiasId_fk = hd.id
  WHERE h.id = @HORARIO_ID
  GROUP BY h.id, v.tFechaFin, v.tFechaInicio
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_insertAsistenciaExtendida]
FECHA: 20/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Insertar un registro de asistencia extendida.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertAsistenciaExtendida]
  @TURNO_EXTENDIDO_ID INT,
  @ASISTENCIA_ID INT,
  @MARCACION_ID INT,
  @DETALLE_BIOMETRICO_ID INT,
  @Id INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @State INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO AsistenciaExtendida
    (
    turnoExtendidoId_fk,
    asistenciaId_fk,
    marcacionId_fk,
    detalleBiometricoId_fk,
    bEliminado,
    nCreatedBy,
    tCreatedAt)
  VALUES
    (
      @TURNO_EXTENDIDO_ID,
      @ASISTENCIA_ID,
      @MARCACION_ID,
      @DETALLE_BIOMETRICO_ID,
      0,
      1,
      GETDATE()
      );

  SET @Id = SCOPE_IDENTITY();
  SET @Message = 'Asistencia Extendida insertada correctamente';
  SET @State = 1;

END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_insertAsistenciaRegular]
FECHA: 20/01/2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Insertar un registro de asistencia regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertAsistenciaRegular]
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
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite realizar el registro un nuevo biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertBiometrico] @MARCA VARCHAR(100)
    , @TIPOBD VARCHAR(50)
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF (LTRIM(RTRIM(ISNULL(@MARCA, ''))) = '')
        BEGIN
            SET @State = - 2;
            SET @Message = 'La marca no puede estar vacía.';

            RETURN;
        END;

        IF (LTRIM(RTRIM(ISNULL(@TIPOBD, ''))) = '')
        BEGIN
            SET @State = - 3;
            SET @Message = 'El tipoBD no puede estar vacío.';

            RETURN;
        END;

        IF (
                LEFT(@MARCA, 1) IN (' ', '-', '_')
                OR LEFT(@TIPOBD, 1) IN (' ', '-', '_')
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Los campos no deben iniciar con epacio, "-" ni "_".';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(marca) = UPPER(@MARCA)
                    AND UPPER(tipoBD) = UPPER(@TIPOBD)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'El biométrico ya existe.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(marca) = UPPER(@MARCA)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6
            SET @Message = 'Ya existe, un registro de la marca'

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(tipoBD) = UPPER(@TIPOBD)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7
            SET @Message = 'Ya existe, un registro del TipoBD'

            RETURN;
        END

        INSERT INTO Biometrico (
            marca
            , tipoBD
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @MARCA
            , @TIPOBD
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_InsertConectadoDias]
FECHA: 17-09-2025
AUTOR: Jesamine Ramon Yora
OBJETIVO: Insertar un nuevo registro en ConectadoDias que sirve para extender el turno extendido.


MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertConectadoDias] @TURNOEXTENDIDOID INT
    , @DIASID INT
    , @USER INT
    , @Id INT OUTPUT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @TURNOEXTENDIDOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El turno extendido no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Dia
                WHERE id = @DIASID
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El día especificado no existe.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM ConectadoDias
                WHERE turnoExtendidoId_pk = @TURNOEXTENDIDOID
                    AND diasId_pk = @DIASID
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El registro ya existe en ConectadoDias.';

            RETURN;
        END;

        INSERT INTO ConectadoDias (
            turnoExtendidoId_pk
            , diasId_pk
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @TURNOEXTENDIDOID
            , @DIASID
            , @USER
            , GETDATE()
            );

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Id = SCOPE_IDENTITY();
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControl]
FECHA: 18-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE    PROCEDURE [dbo].[usp_InsertControl]
    @TOLERANCIA INT,
    @LIMITE_FALTA INT,
    @LIMITE_MARCACION INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 
        FROM Controles
        WHERE nTolerancia = @TOLERANCIA
            AND nLimiteFalta = @LIMITE_FALTA
            AND nLimiteMarcacion = @LIMITE_MARCACION
            AND bEliminado = 0
    )
    BEGIN
        SET @State = -1;
        SET @Message = 'Ya existe un registro con esos valores';
        SET @Id = 0;
        SET @CodeError = -1; 
        RETURN;
    END

    BEGIN TRY
        INSERT INTO [CONTROLES]
            ( nTolerancia, nLimiteFalta, nLimiteMarcacion, bEliminado, nCreatedBy, tCreatedAt )
        VALUES
            (  @TOLERANCIA, @LIMITE_FALTA, @LIMITE_MARCACION ,0, @USER, getdate());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Control insertado correctamente';
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


/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControlRolUsuario]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar un registro en la tabla ControlRolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertControlRolUsuario]
    @ROL_USUARIO_ID INT,
    @CONTROL_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        IF EXISTS (
            SELECT 1 
            FROM ControlRolUsuario
            WHERE controlId_fk = @CONTROL_ID
            AND rolUsuarioId_fk = @ROL_USUARIO_ID
            AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una relación entre este Control y este RolUsuario.';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO ControlRolUsuario
          (controlId_fk, rolUsuarioId_fk, bEliminado, nCreatedBy, tCreatedAt)
        VALUES(@CONTROL_ID, @ROL_USUARIO_ID, 0, @USER, GETDATE());


        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'ControlRolUsuario registrado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @Id = -1;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_insertControlRolUsuarioAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de rol de usuario para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   26-02-2026  Gabriel    Se agrega parámetro @nMinutosTarde para registrar minutos de tardanza
======================================================================================================*/

CREATE   PROCEDURE [dbo].[usp_InsertControlRolUsuarioAsistencia]
  @controlRolUsuarioId_fk INT,
  @asistenciaId_fk INT,
  @estadoAsistenciaId_fk INT,
  @marcacionEntrada DATETIME2(0),
  @marcacionSalida DATETIME2(0),
  @estadoEntrada VARCHAR(50),
  @estadoSalida VARCHAR(50),
  @nMinutosTarde INT = 0,
  @usuario INT,

  @Id INT OUTPUT,
  @State INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  UPDATE ControlRolUsuarioAsistencia
        SET bEliminado = 1
      WHERE asistenciaId_fk = @asistenciaId_fk;

  INSERT INTO ControlRolUsuarioAsistencia
    (controlRolUsuarioId_fk, asistenciaId_fk, estadoAsistenciaId_fk, marcacionEntrada, marcacionSalida, estadoEntrada, estadoSalida, nMinutosTarde
    , nCreatedBy)
  VALUES
    (
      @controlRolUsuarioId_fk,
      @asistenciaId_fk,
      @estadoAsistenciaId_fk,
      @marcacionEntrada,
      @marcacionSalida,
      @estadoEntrada,
      @estadoSalida,
      @nMinutosTarde,
      @usuario
        );

  SELECT
    SCOPE_IDENTITY() AS Id;

  SET @Id = SCOPE_IDENTITY();
  SET @State = 1;
  SET @Message = 'Registro insertado correctamente';
  SET @CodeError = 0;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControlUnidad]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar control para unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertControlUnidad]
    @UNIDAD_ID INT,
    @CONTROL_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
    --     IF EXISTS ( SELECT 1
    -- FROM ControlUnidad
    -- WHERE controlId_fk = @CONTROL_ID AND unidadId_fk = @UNIDAD_ID AND bEliminado = 0 )
    --     BEGIN
    --     SET @State = -1;
    --     SET @Message = 'Ya existe una relación entre este Control y esta Unidad.';
    --     SET @CodeError = -1;
    --     RETURN;
    -- END

        INSERT INTO ControlUnidad
        (controlId_fk, unidadId_fk, bEliminado, nCreatedBy, tCreatedAt)
    VALUES(@CONTROL_ID, @UNIDAD_ID, 0, @USER, GETDATE());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'ControlUnidad registrado correctamente.';
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


/*======================================================================================================
NOMBRE: [dbo].[usp_insertControlUnidadAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de unidad para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   26-02-2026  Gabriel    Se agrega parámetro @nMinutosTarde para registrar minutos de tardanza
====================================================================================================== */
CREATE   PROCEDURE [dbo].[usp_insertControlUnidadAsistencia]
  @controlUnidadId_fk INT,
  @asistenciaId_fk INT,
  @estadoAsistenciaId_fk INT,
  @marcacionEntrada DATETIME2(0),
  @marcacionSalida DATETIME2(0),
  @estadoEntrada VARCHAR(50),
  @estadoSalida VARCHAR(50),
  @nMinutosTarde INT = 0,
  @usuario INT,

  @Id INT OUTPUT,
  @State INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  UPDATE ControlUnidadAsistencia
        SET bEliminado = 1
      WHERE asistenciaId_fk = @asistenciaId_fk;

  INSERT INTO ControlUnidadAsistencia
    (controlUnidadId_fk, asistenciaId_fk, estadoAsistenciaId_fk, marcacionEntrada, marcacionSalida, estadoEntrada, estadoSalida, nMinutosTarde, nCreatedBy)
  VALUES
    (
      @controlUnidadId_fk,
      @asistenciaId_fk,
      @estadoAsistenciaId_fk,
      @marcacionEntrada,
      @marcacionSalida,
      @estadoEntrada,
      @estadoSalida,
      @nMinutosTarde,
      @usuario
        );


  SET @Id = SCOPE_IDENTITY();
  SET @State = 1;
  SET @Message = 'Registro insertado correctamente';
  SET @CodeError = 0;
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_InsertControlVacaciones]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar control de vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertControlVacaciones]
    @IDROLUSUARIO INT,
    @DIASDISPONIBLES INT,
    @DIASTOMADOS INT = 0,
    @B_APROBADO BIT,
    @USER INT,
    @APROBADO INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF ISNULL(@DIASDISPONIBLES, 0) < 0
        BEGIN
        SET @State = - 1;
        SET @Message = 'El numero de días disponibles no es válido.';

        RETURN;
    END;

        IF ISNULL(@DIASTOMADOS, 0) < 0
        BEGIN
        SET @State = - 1;
        SET @Message = 'El numero de días tomados no es válido.';

        RETURN;
    END;

        SELECT *
    FROM ControlVacaciones

    
        IF NOT EXISTS (
                SELECT 1
    FROM ControlVacaciones
    WHERE rolUsuarioId_fk = @IDROLUSUARIO
        AND bEliminado = 0
                )
        BEGIN
        INSERT INTO ControlVacaciones
            (
            rolUsuarioId_fk,
            nDiasDisponibles,
            nDiasTomados,
            bAprobado,
            nCreatedBy,
            nAprobadoBy
            )
        VALUES
            (
                @IDROLUSUARIO
                , @DIASDISPONIBLES
                , @DIASTOMADOS
                , @B_APROBADO
                , @USER
                , @APROBADO
                )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
            BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
            ELSE
            BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END
        ELSE
        BEGIN

        UPDATE ControlVacaciones SET bActivo = 0 WHERE rolUsuarioId_fk = @IDROLUSUARIO AND bEliminado = 0;

        INSERT INTO ControlVacaciones
            (
            rolUsuarioId_fk,
            nDiasDisponibles,
            nDiasTomados,
            bAprobado,
            nCreatedBy,
            nAprobadoBy
            )
        VALUES
            (
                @IDROLUSUARIO
                , @DIASDISPONIBLES
                , @DIASTOMADOS
                , @B_APROBADO
                , @USER
                , @APROBADO
                )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
            BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
            ELSE
            BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END
    END TRY

    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
    NOMBRE: [dbo].[usp_InsertCursoPreUniversitarioTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Insertar datos en la tabla CursoSeccionPreUniversitaria_TurnoRegular
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertCursoPreUniversitarioTurnoRegular]
    @syncCursoSeccionPreUniversitariaId INT,
    @turnoRegularEntradaId INT,
    @turnoRegularSalidaId INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        IF EXISTS (
            SELECT 1
            FROM  CursoSeccionPreUniversitaria_TurnoRegular
            WHERE turnoRegularEntradaId = @turnoRegularEntradaId
              AND turnoRegularSalidaId = @turnoRegularSalidaId
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una asignación registrada para una sección preuniversitaria con el mismo turno de entrada y salida.';
            SET @CodeError = -2;
            RETURN;
        END


        -- verificar si entrada es bTipo 0 
        IF NOT EXISTS (
            SELECT 1
            FROM  TurnoRegular
            WHERE id = @turnoRegularEntradaId AND bTipo = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de entrada no es válido. Debe tener bTipo = 0.';
            SET @CodeError = -3;
            RETURN;
        END

        -- verificar si salida es bTipo 1
        IF NOT EXISTS (
            SELECT 1
            FROM  TurnoRegular
            WHERE id = @turnoRegularSalidaId AND bTipo = 1
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de salida no es válido. Debe tener bTipo = 1.';
            SET @CodeError = -4;
            RETURN;
        END


        INSERT INTO CursoSeccionPreUniversitaria_TurnoRegular
        ( syncCursoSeccionPreUniversitariaId, turnoRegularEntradaId, turnoRegularSalidaId, bEliminado, nCreatedBy, tCreatedAt )
            VALUES
        ( @syncCursoSeccionPreUniversitariaId, @turnoRegularEntradaId, @turnoRegularSalidaId, 0, @USER, getdate());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Asignación registrada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH   
END
GO


/*======================================================================================================
    NOMBRE: [dbo].[usp_InsertCursoSeccionBasica_TurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Crear la relación entre curso sección básica y turno regular especidifamente
    insertar un nuevo registro en la tabla CursoSeccionBasica_TurnoRegular

    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
     -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertCursoSeccionBasica_TurnoRegular]
    @SYNC_CURSO_SECCION_ID INT,
    @TURNO_REGULAR_ENTRADA_ID INT,
    @TURNO_REGULAR_SALIDA_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF EXISTS (
            SELECT 1 FROM
                CursoSeccionBasica_TurnoRegular
            WHERE turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID
              AND turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una asignación registrada para este turno regular.';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @TURNO_REGULAR_ENTRADA_ID AND bTipo = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de entrada no es válido. Debe tener bTipo = 0.';
            SET @CodeError = -2;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @TURNO_REGULAR_SALIDA_ID AND bTipo = 1
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de salida no es válido. Debe tener bTipo = 1.';
            SET @CodeError = -2;
            RETURN;
        END

        INSERT INTO CursoSeccionBasica_TurnoRegular (
            syncCursoSeccionId,
            turnoRegularEntradaId,
            turnoRegularSalidaId,
            nCreatedBy,
            tCreatedAt
        ) VALUES (
            @SYNC_CURSO_SECCION_ID,
            @TURNO_REGULAR_ENTRADA_ID,
            @TURNO_REGULAR_SALIDA_ID,
            @USER,
            GETDATE()
        );

        SET @State = 1;
        SET @Message = 'Registro insertado correctamente.';
        SET @Id = SCOPE_IDENTITY();
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        RETURN;
    END CATCH
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_InsertDetalleBiometrico]
FECHA: 03-02-2026
AUTOR: Gabriel Vasquez
OBJETIVO: Permite ctualizar un detalle biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertDetalleBiometrico]
  @NOMBRE VARCHAR(50) = NULL,
  @IP CHAR(50) = NULL,
  @SERIE VARCHAR(50) = NULL,
  @UBICACION VARCHAR(100) = NULL,
  @HUELLA BIT,
  @ROSTRO BIT,
  @TARJETA BIT,
  @BIOMETRICO_ID INT,
  @USER INT,
  @ID INT OUTPUT,
  @State INT OUTPUT,
  @Message NVARCHAR(200) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO DetalleBiometrico
    (cNombre
    , ip
    , serie
    , ubicacion
    , bHuella
    , bRostro
    , bTarjeta
    , bEliminado
    , nCreatedBy
    , tCreatedAt
    , biometricoId_fk)
  VALUES
    (@NOMBRE
        , @IP
        , @SERIE
        , @UBICACION
        , @HUELLA
        , @ROSTRO
        , @TARJETA
        , 0
        , @USER
        , GETDATE()
        , @BIOMETRICO_ID);

    SET @ID = SCOPE_IDENTITY();
    SET @State = 1;
    SET @Message = 'Detalle biométrico insertado correctamente.';
    SET @CodeError = 0;

    COMMIT TRANSACTION;
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION;

    SET @State = -1;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
  END CATCH;

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertEstadoAsistencia]
FECHA: 25-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar estado de asitencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertEstadoAsistencia] @NOMBRE CHAR(40)
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF (TRIM(ISNULL(@NOMBRE, '')) = '')
        BEGIN
            SET @State = - 2;
            SET @Message = 'El nombre no puede estar vacio';

            RETURN;
        END;

        IF LEFT(@NOMBRE, 1) = ' '
        BEGIN
            SET @State = - 3;
            SET @Message = 'El nombre no puede iniciar con espacio en blanco';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM EstadoAsistencia
                WHERE UPPER(cNombre) = UPPER(@NOMBRE)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El nombre ya exite en otro EstadoAsistencia'

            RETURN;
        END

        IF PATINDEX('%[^a-zA-ZÁÉÍÓÚáéíóúÑñ ]%', @NOMBRE) > 0
        BEGIN
            SET @State = - 5;
            SET @Message = 'No se permite ingresar numero, ni _, en el nombre'

            RETURN;
        END

        INSERT INTO EstadoAsistencia (
            cNombre
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @NOMBRE
            , @USER
            , GETDATE()
            )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertFeriadosUnidad]
FECHA: 07-02-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar un nuevo feriado para una unidad organizativa.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertFeriadosUnidad]
  @UNIDAD_ID INT,
  @ANIO_ID  INT,
  @FECHA DATE,
  @DENOMINACION_FERIADO_ID INT,
  @USER INT,
  @State INT OUTPUT,
  @Message VARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT,
  @Id INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @FECHA_FERIADO_ID INT;

  BEGIN TRY

    IF EXISTS (SELECT 1
  FROM FechaFeriado
  WHERE denominacionFeriadoId_fk = @DENOMINACION_FERIADO_ID AND anioId_fk = @ANIO_ID
    )
    BEGIN

    SELECT @FECHA_FERIADO_ID = id
    FROM FechaFeriado
    WHERE denominacionFeriadoId_fk = @DENOMINACION_FERIADO_ID
      AND anioId_fk = @ANIO_ID;

    IF EXISTS (SELECT 1
    FROM UnidadFeriado
    WHERE fechaFeriadoId_pk = @FECHA_FERIADO_ID
      AND unidadId_pk = @UNIDAD_ID                 
      )
      BEGIN
      SET @Message = 'El feriado para la unidad organizativa ya existe.';
      SET @State = -1;
      SET @CodeError = -1;
      RETURN;
    END

    INSERT INTO UnidadFeriado
      (unidadId_pk, fechaFeriadoId_pk ,nCreatedBy, tCreatedAt)
    VALUES
      (@UNIDAD_ID, @FECHA_FERIADO_ID, @USER, GETDATE());
    SET @Id = SCOPE_IDENTITY();
    SET @Message = 'Feriado para unidad registrado correctamente.';
    SET @State = 1;
    SET @CodeError = 0;
    RETURN;
  END

    INSERT INTO FechaFeriado
    (denominacionFeriadoId_fk, anioId_fk, fecha, bEliminado, nCreatedBy, tCreatedAt)
  VALUES
    (@DENOMINACION_FERIADO_ID, @ANIO_ID, @FECHA, 0, @USER, GETDATE());

    SET @FECHA_FERIADO_ID = SCOPE_IDENTITY();

    INSERT INTO UnidadFeriado
    (unidadId_pk, fechaFeriadoId_pk, nCreatedBy, tCreatedAt)
  VALUES
    (@UNIDAD_ID, @FECHA_FERIADO_ID, @USER, GETDATE());

    SET @Id = SCOPE_IDENTITY();
    SET @Message = 'Feriado para unidad registrado correctamente.';
    SET @State = 1;
    SET @CodeError = 0;
  END TRY
  BEGIN CATCH
    SET @Id = 0;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
    SET @State = -1;
  END CATCH

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_insertGradoSupervisado]
FECHA: 18-02-2026
AUTOR: Gabriel
OBJETIVO: Registrar un grado supervisado

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   18-02-2026   Gabriel   Creación de procedimiento alineado al repository
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_insertGradoSupervisado]
    @ID_GRADO CHAR(3),
    @ROL_USUARIO_ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @State = -1;
        SET @Message = 'No se pudo crear el registro.';
        SET @Id = NULL;
        SET @CodeError = 0;

        IF NOT EXISTS (
                SELECT 1
    FROM Sync_GradoNivel
    WHERE idGrado = @ID_GRADO
                )
        BEGIN
        SET @State = -1;
        SET @Message = 'El grado especificado no existe o fue eliminado.';

        RETURN;
    END

        IF NOT EXISTS (
                SELECT 1
    FROM RolUsuario
    WHERE id = @ROL_USUARIO_ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = -1;
        SET @Message = 'El rol de usuario especificado no existe o fue eliminado.';

        RETURN;
    END

        IF EXISTS (
                SELECT 1
    FROM GradoSupervisado
    WHERE idGrado_pk = @ID_GRADO
        AND rolUsuarioId_pk = @ROL_USUARIO_ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = -1;
        SET @Message = 'El grado supervisado ya se encuentra registrado.';

        RETURN;
    END

        IF EXISTS (
                SELECT 1
    FROM GradoSupervisado
    WHERE idGrado_pk = @ID_GRADO
        AND rolUsuarioId_pk = @ROL_USUARIO_ID
        AND bEliminado = 1
                )
        BEGIN
        UPDATE GradoSupervisado
            SET bEliminado = 0
                , nCreatedBy = @USER
                , tCreatedAt = GETDATE()
            WHERE idGrado_pk = @ID_GRADO
            AND rolUsuarioId_pk = @ROL_USUARIO_ID;

        IF (@@ROWCOUNT > 0)
            BEGIN
            SET @State = 0;
            SET @Message = 'Registro reactivado correctamente.';
            SET @Id = 0;
            RETURN;
        END

        SET @State = -1;
        SET @Message = 'No se pudo reactivar el registro existente.';
        RETURN;
    END

        INSERT INTO GradoSupervisado
        (
        idGrado_pk
        , rolUsuarioId_pk
        , bEliminado
        , nCreatedBy
        , tCreatedAt
        )
    VALUES
        (
            @ID_GRADO
            , @ROL_USUARIO_ID
            , 0
            , @USER
            , GETDATE()
            )

        SET @Id = ISNULL(CAST(SCOPE_IDENTITY() AS INT), 0);

        IF (@@ROWCOUNT > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Inserción exitosa.';
    END
        ELSE
        BEGIN
        SET @State = -1;
        SET @Message = 'No se insertó ningún registro.';
    END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        SET @Id = NULL;
    END CATCH
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_InsertHorario]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite registrar nuevos horarios

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertHorario] 
    @TITULO VARCHAR(50)
    , @HORADIA DECIMAL(10,2)
    , @GENERAL BIT
    , @EXTENDIDO BIT
    , @ROTATIVO BIT
    , @REGULAR BIT
    , @TEMPORADA_ID INT=NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF (LTRIM(RTRIM(ISNULL(@TITULO, ''))) = '')
        BEGIN
            SET @State = - 2;
            SET @Message = 'El titulo no puede estar vacío.';

            RETURN;
        END;

        IF (
                LEFT(@TITULO, 1) = ' '
                OR LEFT(@TITULO, 1) IN ('-', '_')
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El título no puede iniciar con espacio, "-" o "_".';

            RETURN;
        END;


        IF (
                @HORADIA IS NULL
                OR @HORADIA <= 0
                )
            OR @HORADIA > 24
        BEGIN
            SET @State = - 4;
            SET @Message = 'Debe registrar un valor válido para hora.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Horario
                WHERE UPPER(cTitulo) = UPPER(@TITULO)
                    AND horaDia = @HORADIA
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Ya existe un horario con este título y hora.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Horario
                WHERE UPPER(cTitulo) = UPPER(@TITULO)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'El título ya está en uso en otro horario.';

            RETURN;
        END;

        -- IF EXISTS (
        --         SELECT 1
        --         FROM Horario
        --         WHERE horaDia = @HORADIA
        --             AND bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 7;
        --     SET @Message = 'La hora ya está en uso en otro horario.';

        --     RETURN;
        -- END;

        INSERT INTO Horario (
            cTitulo
            , horaDia
            , bGeneral
            , bExtendido
            , bRotativo
            , nCreatedBy
            , tCreatedAt
            , bRegular
            , idTemporada
            )
        VALUES (
            @TITULO
            , @HORADIA
            , @GENERAL
            , @EXTENDIDO
            , @ROTATIVO
            , @USER
            , GETDATE()
            , @REGULAR
            , @TEMPORADA_ID
            )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertHorarioUsuario]
FECHA: 25-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar estado de asitencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertHorarioUsuario]
    @IDHORARIO INT
    ,@IDROLUSUARIO INT
    ,@FECHAINICIO DATE
    ,@FECHAFIN DATE
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@Id INT OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

    --     IF @FECHAINICIO > @FECHAFIN
    --     BEGIN
    --     SET @State = - 1;
    --     SET @Message = 'La fecha de inicio no puede ser mayor a la fecha fin.';

    --     RETURN;
    -- END;

        IF NOT EXISTS (
                SELECT 1
    FROM Horario
    WHERE id = @IDHORARIO
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 1;
        SET @Message = 'El horario no existe o está inactivo.';

        RETURN;
    END;

        IF NOT EXISTS (
                SELECT 1
    FROM RolUsuario
    WHERE id = @IDROLUSUARIO
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 1;
        SET @Message = 'El rol de usuario no existe o está inactivo.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM HorarioUsuario
    WHERE rolUsuarioId_fk = @IDROLUSUARIO
        AND bEliminado = 0
        AND (
                        (@FECHAINICIO BETWEEN tFechaInicio AND tFechaFin)
        OR (@FECHAFIN BETWEEN tFechaInicio AND tFechaFin)
        OR (tFechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN)
        OR (tFechaFin BETWEEN @FECHAINICIO AND @FECHAFIN)
                        )
                )
        BEGIN
        SET @State = - 1;
        SET @Message = 'Ya existe un horario asignado en ese rango de fechas para el usuario.';

        RETURN;
    END;
    --     IF EXISTS(
    --         SELECT 1
    -- FROM Vigencia
    -- WHERE bActivo = 1
    -- AND horarioDiasId_fk IN (SELECT horarioDiasId_fk
    --     FROM HorarioDias
    --     WHERE horarioId_fk = @IDHORARIO AND bEliminado = 0)
    --     AND bEliminado = 0
    --     AND ((
    --                 @FECHAINICIO < @FECHAFIN AND
    --                 (
    --                     @FECHAINICIO <= tFechaInicio
    --                     AND @FECHAFIN >= tfechaFin
    --                 )
    --             )
    --     ))
    --     BEGIN
    --     SET @State = -1;
    --     SET @Message = 'Debe de ingresar una fecha que este dentro de la vigencia del horario.';
    --     RETURN;
    -- END;

        INSERT INTO HorarioUsuario
        (
        horarioId_fk
        , rolUsuarioId_fk
        , tfechaInicio
        , tFechaFin
        , nCreatedBy
        )
    VALUES
        (
            @IDHORARIO
            , @IDROLUSUARIO
            , @FECHAINICIO
            , @FECHAFIN
            , @USER
            )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Inserción exitosa.';
    END
        ELSE
        BEGIN
        SET @State = - 1;
        SET @Message = 'Fallo en la inserción.';
    END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO


/*======================================================================================================
NOMBRE: [dbo].[usp_InsertLicencia]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite registrar una licencia para un usuario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertLicencia] @ROLUSUARIOID INT
    , @MOTIVOID INT
    , @TITULO VARCHAR(250)
    , @DETALLE VARCHAR(250)
    , @FECHAINICIO DATE
    , @FECHAFIN DATE
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF (
                @TITULO IS NULL
                OR LTRIM(RTRIM(@TITULO)) = ''
                OR @DETALLE IS NULL
                OR LTRIM(RTRIM(@DETALLE)) = ''
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'Los campos no puede ser nulos ni vacíos.';

            RETURN;
        END;

        IF (
                @FECHAINICIO IS NULL
                OR @FECHAFIN IS NULL
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'Las fechas no pueden ser nulas.';

            RETURN;
        END;

        IF (
                LEFT(@TITULO, 1) IN (' ', '-', '_')
                OR LEFT(@DETALLE, 1) IN (' ', '-', '_')
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El título y el detalle no puede iniciar con espacio, "-" o "_".';

            RETURN;
        END;

        IF (@FECHAFIN < @FECHAINICIO)
        BEGIN
            SET @State = - 5;
            SET @Message = 'La fechaFin no puede ser menor a la fechaInicio.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROLUSUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'El rolUsuario no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Motivo
                WHERE id = @MOTIVOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'El motivo no existe o fue eliminado.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(titulo) = UPPER(@TITULO)
                    AND UPPER(detalle) = UPPER(@DETALLE)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'Ya existe una licencia, con el mismo título y detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(titulo) = UPPER(@TITULO)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'Ya existe una licencia con el mismo titulo.';

            RETURN;
        END; 

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE UPPER(detalle) = UPPER(@DETALLE)
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Ya existe una licencia con el mismo detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Licencia
                WHERE rolUsuarioId_fk = @ROLUSUARIOID
                    AND bEliminado = 0
                    AND (
                        (@FECHAINICIO BETWEEN tFechaInicio AND tFechaFin)
                        OR (@FECHAFIN BETWEEN tFechaInicio AND tFechaFin)
                        OR (tFechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN)
                        OR (tFechaFin BETWEEN @FECHAINICIO AND @FECHAFIN)
                        )
                )
        BEGIN
            SET @State = - 11;
            SET @Message = 'Ya existe un registro para el rolUsuario en el rango de fechas.';

            RETURN;
        END;

        INSERT INTO Licencia (
            rolUsuarioId_fk
            , motivoId_fk
            , titulo
            , detalle
            , tFechaInicio
            , tFechaFin
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @ROLUSUARIOID
            , @MOTIVOID
            , @TITULO
            , @DETALLE
            , @FECHAINICIO
            , @FECHAFIN
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_insertMarcacionAsistenciaExtendida]
FECHA: 13-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar una marcación y su correspondiente asistencia extendida.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_insertMarcacionAsistenciaExtendida]
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
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_insertMarcacionAsistenciaRegular]
FECHA: 13-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar una marcación y su correspondiente asistencia regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_insertMarcacionAsistenciaRegular]
  @ASISTENCIA_ID INT,
  @TURNO_REGULAR_ID INT,
  @FECHA_ASISTENCIA VARCHAR(10),
  @HORA_ENTRADA VARCHAR(8)
AS
BEGIN
  -- Primero crear la marcación con status SIN-REGISTRAR y la hora correcta
  DECLARE @MarcacionId INT;
  DECLARE @PunchTime DATETIME;

  -- Combinar fecha de asistencia con hora de entrada
  SET @PunchTime = CAST(@FECHA_ASISTENCIA + ' ' + @HORA_ENTRADA AS DATETIME);

  INSERT INTO Marcacion
    (emp_code, punch_time, punch_state, terminal_sn, terminal_alias, emp_id, terminal_id, nCreatedBy)
  VALUES
    (0, @PunchTime, 0, 'SIN-REGISTRAR', 'SIN-REGISTRAR', 1, 1, 0);

  SET @MarcacionId = SCOPE_IDENTITY();

  -- Luego crear la asistencia regular con la marcación creada
  INSERT INTO AsistenciaRegular
    (turnoRegularId_fk, asistenciaId_fk, marcacionId_fk, detalleBiometricoId_fk, nCreatedBy)
  VALUES
    (@TURNO_REGULAR_ID, @ASISTENCIA_ID, @MarcacionId, 1, 0);

  SELECT @MarcacionId AS Id;
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertOneSituacion]
FECHA: 31-07-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crea una situacion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertOneSituacion]
  @NOMBRE VARCHAR(50),
  @ORDEN INT,
  @User INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @Id INT OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;
  BEGIN TRY
    IF EXISTS (
      SELECT 1 
      FROM Situacion
      WHERE cNombre COLLATE Latin1_General_CI_AI = @Nombre COLLATE Latin1_General_CI_AI
    )
    BEGIN
      SET @Id = 0;
      SET @Message = 'Ya existe una situación con ese nombre';
      SET @CodeError = -1;
      set @State = -1;
      RETURN;
    END

    IF EXISTS (
      SELECT 1 
      FROM Situacion
      WHERE nOrden = @ORDEN
    )
    BEGIN
      SET @Id = 0;
      SET @Message = 'Ya existe una situación con ese orden';
      SET @CodeError = -1;
      set @State = -1;
      RETURN;
    END


    INSERT INTO Situacion (cNombre, nOrden, nCreatedBy, tCreatedAt)
    VALUES (@Nombre, @ORDEN ,@User, GETDATE());

    SET @Id = SCOPE_IDENTITY();
    SET @Message = 'Situación creada correctamente';
    SET @CodeError = 0;
    set @State = 1;
  END TRY
  BEGIN CATCH
    SET @Id = 0;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
    SET @State = -1;
  END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertPeriodoVacacional]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Registrar periodo vacacional

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertPeriodoVacacional]
    @IDCONTROLVACACIONAL INT
    , @FECHAINICIO DATE
    , @FECHAFIN DATE
    , @DIASCONSUMIDOS INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        -- Validar que no vengan vacíos o nulos
        IF (@FECHAINICIO IS NULL OR @FECHAINICIO = '')
        BEGIN
            SET @State = - 1;
            SET @Message = 'La fecha de inicio no es correcta.';

            RETURN;
        END;

        IF (@FECHAFIN IS NULL OR @FECHAFIN = '')
        BEGIN
             SET @State = - 1;
            SET @Message = 'La fecha de fin no es correcta.';

            RETURN;
        END;

        -- Validar que dias consumidos sea positivo
        IF (@DIASCONSUMIDOS IS NULL AND @DIASCONSUMIDOS <= 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'Los días consumidos deben ser mayores a cero.';
            RETURN;
        END;

        -- Validar orden de fechas
        IF (@FECHAINICIO >= @FECHAFIN)
        BEGIN
            SET @State = - 1;
            SET @Message = 'La fecha de inicio debe ser menor a la fecha fin.';

            RETURN;
        END;

        -- Validar sobreposicion con otros periodos
        IF EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE controlVacacionalId_fk = @IDCONTROLVACACIONAL
                    AND bEliminado = 0
                    AND (
                        (@FECHAINICIO BETWEEN fechaInicio AND fechaFin)
                        OR (@FECHAFIN BETWEEN fechaInicio AND fechaFin)
                        OR (fechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN)
                        OR (fechaFin BETWEEN @FECHAINICIO AND @FECHAFIN)
                        )
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El periodo vacacional se sobrepone con otro existente.';

            RETURN;
        END;

        -- Validar duplicado exacto
        IF EXISTS (
                SELECT 1
                FROM PeriodoVacacional
                WHERE controlVacacionalId_fk = @IDCONTROLVACACIONAL
                    AND fechaInicio = @FECHAINICIO
                    AND fechaFin = @FECHAFIN
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El periodo vacacional ya existe.';

            RETURN;
        END;

        -- Validar que no se excedan los días disponibles
        DECLARE @DiasDisponibles INT
            , @DiasYaConsumidos INT;

        SELECT @DiasDisponibles = nDiasDisponibles
        FROM ControlVacaciones
        WHERE id = @IDCONTROLVACACIONAL;

        SELECT @DiasYaConsumidos = ISNULL(SUM(nDiasConsumidos), 0)
        FROM PeriodoVacacional
        WHERE controlVacacionalId_fk = @IDCONTROLVACACIONAL
            AND bEliminado = 0;

        IF (@DiasYaConsumidos + @DIASCONSUMIDOS) > @DiasDisponibles
        BEGIN
            SET @State = - 1;
            SET @Message = 'Los días consumidos exceden los días disponibles.';

            RETURN;
        END;

        UPDATE ControlVacaciones
            SET nDiasTomados = nDiasTomados + @DIASCONSUMIDOS
        WHERE id = @IDCONTROLVACACIONAL;

        INSERT INTO PeriodoVacacional (
            controlVacacionalId_fk
            , fechaInicio
           , fechaFin
            , nDiasConsumidos
            , nCreatedBy
            )
        VALUES (
            @IDCONTROLVACACIONAL
            , @FECHAINICIO
            , @FECHAFIN
            , @DIASCONSUMIDOS
            , @USER
            )

        SET @Id = SCOPE_IDENTITY()
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertPermiso]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite realizar el Registro de un nuevo  permiso

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertPermiso] 
     @ROLUSUARIOID INT
    , @MOTIVOID INT
    , @FECHA DATE
    , @HORASALIDA TIME
    , @HORARETORNOESTIMADO TIME
    , @HORARETORNOREAL TIME
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @Id INT OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROLUSUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El rolUsuario no existe o fue eliminado';

            RETURN;
        END

        IF NOT EXISTS (
                SELECT 1
                FROM Motivo
                WHERE id = @MOTIVOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El motivo no existe o fue eliminado';

            RETURN;
        END

        IF (
                @FECHA IS NULL
                OR @HORASALIDA IS NULL
                OR @HORARETORNOESTIMADO IS NULL
                OR @HORARETORNOREAL IS NULL
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'La fecha y horas no pueden ser nulas.';

            RETURN;
        END;

        IF (
                @HORASALIDA = '00:00'
                OR @HORARETORNOESTIMADO = '00:00'
                OR @HORARETORNOREAL = '00:00'
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Las horas no pueden ser 00:00.';

            RETURN;
        END;

        INSERT INTO Permiso (
            rolUsuarioId_fk
            , motivoId_fk
            , tfecha
            , tHoraSalida
            , tHoraRetornoEstimado
            , tHoraRetornoReal
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @ROLUSUARIOID
            , @MOTIVOID
            , @FECHA
            , @HORASALIDA
            , @HORARETORNOESTIMADO
            , @HORARETORNOREAL
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la inserción';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertPermisoTurnoExtendido]
FECHA: 22-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Inserta un turno extendido asociado a un permiso.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertPermisoTurnoExtendido] 
      @PERMISOID INT
    , @TURNOID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @PERMISOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM TurnoExtendido
                WHERE id = @TURNOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El turno extendido no existe o fue eliminado.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM PermisoTurnoExtendido
                WHERE permisoId_pk = @PERMISOID
                    AND turnoExtendidoId_pk = @TURNOID
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Ya existe un registro con el permiso y turnoExtendido.';

            RETURN;
        END;

        INSERT INTO PermisoTurnoExtendido (
            permisoId_pk
            , turnoExtendidoId_pk
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @PERMISOID
            , @TURNOID
            , @USER
            , GETDATE()
            );

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se insertó el registro.';
        END;
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertPermisoTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Inserta un turno regular asociado a un permiso.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertPermisoTurnoRegular] @PERMISOID INT
    , @TURNOID INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @PERMISOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM TurnoRegular
                WHERE id = @TURNOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El turnorRegular no existe o fue eliminado.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM PermisoTurnoRegular
                WHERE permisoId_pk = @PERMISOID
                    AND turnoRegularId_pk = @TURNOID
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Ya existe un registro con este permiso y turno regular.';

            RETURN;
        END;

        INSERT INTO PermisoTurnoRegular (
            permisoId_pk
            , turnoRegularId_pk
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @PERMISOID
            , @TURNOID
            , @USER
            , GETDATE()
            );

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Inserción exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se insertó el registro.';
        END;
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertRol]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear rol que se va supervisaar en el sistema

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertRol]
    @UNIDAD_ID INT,
    @TITULO VARCHAR(100),
    @DESCRIPCION VARCHAR(MAX),
    @SUPERVISION BIT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @TITULO = LTRIM(RTRIM(@TITULO));
        SET @DESCRIPCION = LTRIM(RTRIM(@DESCRIPCION));

        IF @TITULO = '' and @DESCRIPCION = ''
        BEGIN
            SET @State = -1;
            SET @Message = 'El título y descripción no puede estar vacío.';
            SET @CodeError = -1;
            RETURN;
        END

        IF NOT EXISTS ( SELECT 1 FROM Unidad WHERE id = @UNIDAD_ID AND bEliminado = 0 )
        BEGIN
            SET @State = -1;
            SET @Message = 'Unidad no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS ( SELECT 1 FROM Rol WHERE cTitulo COLLATE Latin1_General_CI_AS = @TITULO COLLATE Latin1_General_CI_AS AND (@Id IS NULL OR Id <> @Id) and bEliminado = 0)
        BEGIN
            SET @Id = SCOPE_IDENTITY();
            SET @State = -1;
            SET @Message = 'El nombre ya existe. No se puede duplicar.';
            SET @CodeError = -1;
            RETURN;
        END

        INSERT INTO Rol
            ( unidadId_fk, cTitulo, cDescripcion, bSupervision, bEliminado, nCreatedBy, tCreatedAt )
        VALUES
            ( @UNIDAD_ID, @TITULO, @DESCRIPCION, @SUPERVISION, 0, @USER, getdate());

            SET @Id = SCOPE_IDENTITY();
            SET @State = 1;
            SET @Message = 'Rol registrado correctamente.';
            SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertRolAUsuario]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear rol que se va supervisaar en el sistema

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertRolAUsuario]
    @USUARIO_ID INT,
    @ROL_ID INT,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Sync_Usuario
                WHERE id = @USUARIO_ID
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El usuario no existe o está eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Rol
                WHERE id = @ROL_ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El rol no existe o está eliminado.';

            RETURN;
        END;

        -- Validar si ya existe la asignación activa
        IF EXISTS (
                SELECT 1
                FROM RolUsuario AS RU
                WHERE RU.usuarioId_fk = @USUARIO_ID
                    AND RU.rolId_fk = @ROL_ID
                    AND RU.bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El usuario ya tiene asignado este rol.';

            RETURN;
        END

        -- Insertar nueva relación
        INSERT INTO RolUsuario (
            usuarioId_fk
            , rolId_fk
            , nCreatedBy
            , tCreatedAt
            )
        VALUES (
            @USUARIO_ID
            , @ROL_ID
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Rol asignado correctamente';
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
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertRolControl]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar un registro en la tabla RolControl

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertRolControl]
    @ROL_ID INT,
    @CONTROL_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF EXISTS (
            SELECT 1 
            FROM RolControl 
            WHERE rolId_fk = @ROL_ID 
              AND controlId_fk = @CONTROL_ID
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe un registro con este Rol y Control.';
            SET @CodeError = -1; 
            RETURN;
        END


        INSERT INTO RolControl
            (rolId_fk, controlId_fk, bEliminado, nCreatedby, tCreatedAt)
        VALUES
            (@ROL_ID, @CONTROL_ID, 0, @USER, GETDATE());

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'RolControl registrado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @Id = 0;
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_insertRolControlAsistencia]
FECHA: 08-01-2026
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Insertar o actualizar el control de rol de usuario para la asistencia.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   26-02-2026  Gabriel    Se agrega parámetro @nMinutosTarde para registrar minutos de tardanza
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_insertRolControlAsistencia]
  @asistenciaId_fk INT,
  @rolControlId_fk INT,
  @estadoAsistenciaId_fk INT,
  @marcacionEntrada DATETIME2(0),
  @marcacionSalida DATETIME2(0),
  @estadoEntrada VARCHAR(50),
  @estadoSalida VARCHAR(50),
  @nMinutosTarde INT = 0,
  @usuario INT,

  @Id INT OUTPUT,
  @State INT OUTPUT,
  @Message NVARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  UPDATE RolControlAsistencia
    SET bEliminado = 1
  WHERE asistenciaId_fk = @asistenciaId_fk;

  INSERT INTO RolControlAsistencia
    (rolControlId_fk, asistenciaId_fk, estadoAsistenciaId_fk, marcacionEntrada, marcacionSalida, estadoEntrada, estadoSalida, nMinutosTarde, nCreatedBy)
  VALUES
    (
      @rolControlId_fk,
      @asistenciaId_fk,
      @estadoAsistenciaId_fk,
      @marcacionEntrada,
      @marcacionSalida,
      @estadoEntrada,
      @estadoSalida,
      @nMinutosTarde,
      @usuario
    );

  SELECT SCOPE_IDENTITY() AS Id;

  SET @Id = SCOPE_IDENTITY();
  SET @State = 1;
  SET @Message = 'Registro insertado correctamente';
  SET @CodeError = 0;
END
GO
 
--===================================================================================
-- Autor: Jeandry Angulo Marquez
-- Nombre: [dbo].[usp_InsertSupervisor]
-- Fecha: 06-10-2025
-- Descripcion: Procedimiento para crear un nuevo registro en la tabla Supervisor
-- Parámetros: 
-- @USUARIO_ID: id de un registro de la tabla Sync_Usuario (int)
-- @UNIDAD_ID: id de un registro de la tabla Unidad (int)
-- @USUARIO: Id del usuario que realiza el registro (int)
--===================================================================================
CREATE   PROCEDURE [dbo].[usp_InsertSupervisor]
    @USUARIO_ID INT,
    @UNIDAD_ID INT,
    @USUARIO INT,
    @Message VARCHAR(250) OUTPUT,
    @State INT OUTPUT,
    @CodeError INT OUTPUT

AS
BEGIN
    SET NOCOUNT,
    XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS (SELECT 1
    FROM Sync_Usuario
    WHERE id = @USUARIO_ID)
    BEGIN
        SET @State = -1;
        SET @Message = 'El id de Usuario no es Valido'
        SET @CodeError = -1;
        RETURN;
    END
    IF NOT EXISTS (SELECT 1
    FROM Unidad
    WHERE id = @UNIDAD_ID AND bEliminado = 0)
    BEGIN
        SET @State = -1;
        SET @Message = 'el id de la unidad no es valido o el registro fue eliminado'
        RETURN;
    END

    INSERT INTO Supervisor
        (usuarioId_pk, unidadId_pk, nCreatedBy, tCreatedAt)
    VALUES(@USUARIO_ID, @UNIDAD_ID, @USUARIO, GETDATE());
        SET  @Message = 'El registro de Supervisor fue creado correctamente'
        SET  @codeError = 0;
        SET  @State = 1;
    END TRY
    BEGIN CATCH
        SET @Message = ERROR_MESSAGE();
        SET @codeError = ERROR_NUMBER();
        SET @State = -1;
    END CATCH
END
GO
 
CREATE   PROCEDURE usp_InsertSyncUsuarioPersona
    @IDUSUARIO INT,
    @USUARIO VARCHAR(255),
    @NOMBRE VARCHAR(255),
    @APELLIDO VARCHAR(255),
    @DNI VARCHAR(20),
    @TIPO CHAR(2),
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY
    IF EXISTS(SELECT 1
    FROM Sync_UsuarioPersona
    WHERE id = @IDUSUARIO OR cNombre = @USUARIO)
    BEGIN
        SET @State = -1;
        SET @Message = 'Ya existe el usuario';
        SET @CodeError = -1;
        RETURN;
    END

    INSERT INTO Sync_UsuarioPersona
        (id, cUsuario, cNombre, cApellido,cDni,cTipo)
    VALUES
        (@IDUSUARIO, @USUARIO, @NOMBRE, @APELLIDO, @DNI, @TIPO)

    SET @Id = @IDUSUARIO;
    SET @Message = 'Usuario creado correctamente';
    SET @CodeError = 0;
    SET @State = 1;

    END TRY
    BEGIN CATCH    
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertTurnoExtendido]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite el registro de nuevos turnos extendidos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE     PROCEDURE [dbo].[usp_InsertTurnoExtendido]
    @HORARIODIASID INT
    ,@HORAINICIO TIME
    ,@HORAFIN TIME
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@Id INT OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT

    BEGIN TRY
        IF @HORAINICIO IS NULL
        BEGIN
        SET @State = - 2;
        SET @Message = 'Debe especificar una hora de inicio válida.';

        RETURN;
    END;

        IF @HORAFIN IS NULL
        BEGIN
        SET @State = - 3;
        SET @Message = 'Debe especificar una hora de fin válida.';

        RETURN;
    END;

        IF NOT EXISTS (
                SELECT 1
    FROM HorarioDias
    WHERE id = @HORARIODIASID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 4;
        SET @Message = 'El horarioDía no existe o está eliminado';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM HorarioDias
    WHERE id = @HORARIODIASID
        AND bLibre = 1
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 5;
        SET @Message = 'No se puede registrar, este día está marcado como libre.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM TurnoExtendido
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND horaInicio = @HORAINICIO
        AND horaFin = @HORAFIN
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 6;
        SET @Message = 'Ya existe un turno para este mismo horario';

        RETURN;
    END;

        -- IF EXISTS (
        --         SELECT 1
        --         FROM TurnoExtendido
        --         WHERE horaInicio = @HORAINICIO
        --             AND horaFin = @HORAFIN
        --             AND bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 7;
        --     SET @Message = 'Existe este turno en otro diferente horarioDía';

        --     RETURN;
        -- END;

          IF EXISTS (
            SELECT 1
    FROM TurnoRegular TR_Entrada
    CROSS JOIN TurnoRegular TR_Salida
    WHERE TR_Entrada.horarioDiasId_fk = @HORARIODIASID AND TR_Entrada.bEliminado = 0
        AND TR_Entrada.bTipo = 0
        AND TR_Salida.bTipo = 1
        AND TR_Entrada.horarioDiasId_fk =  TR_Salida.horarioDiasId_fk
        AND ((
              @HORAINICIO < TR_Salida.horaInicio
        AND @HORAFIN > TR_Entrada.horaInicio
            ))
        )
        BEGIN
        SELECT @State = -7, @Message = 'El rango de horas coincide con un turno regular ya existente.';
        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM TurnoExtendido
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND bEliminado = 0
        AND (
                        -- turno normal
                        (
                            horaInicio < horaFin
        AND (
                                @HORAINICIO < horaFin
        AND @HORAFIN > horaInicio
                                )
                            )
        OR
        -- Turno para medianoche
        (
                            (
                                horaInicio > horaFin
        AND (
                                    (
                                        @HORAINICIO >= horaInicio
        OR @HORAINICIO < horaFin
                                        )
        OR (
                 @HORAFIN > horaInicio
        OR @HORAFIN <= horaFin
                                        )
                                    )
                                )
                            )
                        )
                )
        BEGIN
        SET @State = - 8;
        SET @Message = 'El rango de horas coincide con otro turno existente';

        RETURN;
    END;

        INSERT INTO TurnoExtendido
        (
        horarioDiasId_fk
        , horaInicio
        , horaFin
        , nCreatedBy
        , tCreatedAt
        )
    VALUES
        (
            @HORARIODIASID
            , @HORAINICIO
            , @HORAFIN
            , @USER
            , GETDATE()
            );

        SET @Id = SCOPE_IDENTITY();
        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Turno Extendido creado correctamente.';
    END
        ELSE
        BEGIN
        SET @State = - 1;
        SET @Message = 'Fallo en la inserción.';
    END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite registrar nuevos turnos regulares.


MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertTurnoRegular]
    @HORARIODIASID INT
    ,@HORAINICIO TIME
    ,@TIPO BIT
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@Id INT OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @NuevoOrden INT = 0;
    SET @Id = 0;
    SET @CodeError = 0;

    BEGIN TRY
        IF @HORAINICIO IS NULL OR @HORAINICIO = '00:00:00'
        BEGIN
        SELECT @State = -3, @Message = 'Debe especificar una horaInicio válida.';
        RETURN;
    END;

        DECLARE @bLibre BIT;
        DECLARE @Existe BIT = 0;

        SELECT @Existe = 1, @bLibre = bLibre
    FROM HorarioDias
    WHERE id = @HORARIODIASID AND bEliminado = 0;

        IF @Existe IS NULL OR @Existe = 0
        BEGIN
        SELECT @State = -4, @Message = 'Horario Dias no existe o está eliminado';
        RETURN;
    END

        IF @bLibre = 1
        BEGIN
        SELECT @State = -5, @Message = 'No puedes registrar turnos, este día es libre.';
        RETURN;
    END
    IF EXISTS (
    SELECT 1
    FROM TurnoExtendido
    WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0
        AND (@HORAINICIO <= horaFin AND @HORAINICIO >= horaInicio)
        ) 
        BEGIN
        SELECT @State = -8, @Message = 'El rango de horas coincide con un turno extendido ya existente.';
        RETURN;
         END;
        
    -- IF EXISTS (
    -- SELECT 1
    -- FROM TurnoRegular
    -- WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0
    --     AND (@HORAINICIO <= horaInicio)
    --     )
    --     BEGIN
    --     SELECT @State = -8, @Message = 'La hora ingresada se superpone con otro turno.';
    --     RETURN;
    -- END;

        BEGIN TRANSACTION;
            
            SELECT @NuevoOrden = ISNULL(MAX(orden), 0) + 1
    FROM TurnoRegular WITH (UPDLOCK, HOLDLOCK)
    WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0;

            IF EXISTS (
                SELECT 1
    FROM TurnoRegular
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND horaInicio = @HORAINICIO
        AND bEliminado = 0
            )
            BEGIN
        ROLLBACK TRANSACTION;
        SELECT @State = -7, @Message = 'Ya existe un turno con la misma hora en este día.';
        RETURN;
    END

            INSERT INTO TurnoRegular
        (
        horarioDiasId_fk
        , orden
        , horaInicio
        , bTipo
        , nCreatedBy
        , tCreatedAt
        )
    VALUES
        (
            @HORARIODIASID
                , @NuevoOrden
                , @HORAINICIO
                , @TIPO
                , @USER
                , GETDATE()
            );

            SET @Id = SCOPE_IDENTITY();
            SELECT @State = 0, @Message = 'Turno Regular creado Correctamente. Orden asignado: ' + CAST(@NuevoOrden AS VARCHAR(10));

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertUnidad]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear unidad que se va supervisaar en el sistema

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
01   22/11/2025  FLUNA      Modificar @SYNC_UNIDAD_ID de INT a CHAR(3)
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertUnidad]
    @SYNC_UNIDAD_ID CHAR(3),
    @HORA_ESTANDAR INT,
    @HORA_TOTAL INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- VALIDAR SI EXISTE LA SYNC_UNIDAD_ID EN UNIDAD POR QUE ES UNA RELACION UNO A UNO
        IF EXISTS (SELECT 1 FROM  Unidad WHERE unidadOrgId_fk = @SYNC_UNIDAD_ID AND bEliminado = 0)
        BEGIN
            SET @Id = 0;
            SET @State = 0;
            SET @Message = 'La unidad con SyncUnidadId ' + CAST(@SYNC_UNIDAD_ID AS VARCHAR(10)) + ' ya existe.';
            SET @CodeError = 1;
            RETURN;
        END

        INSERT INTO Unidad
            (unidadOrgId_fk, horaEstandar, horaTotal, bEliminado, nCreatedBy, tCreatedAt)
        VALUES
            (@SYNC_UNIDAD_ID, @HORA_ESTANDAR, @HORA_TOTAL, 0, @USER, GETDATE());
        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Unidad creada correctamente.';
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
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertVigenciaGlobal]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear vigencias para todos los días de un horario específico

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE    PROCEDURE [dbo].[usp_InsertVigenciaGlobal]
    @HORARIO_ID INT,
    @USER INT,
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1
    FROM Horario
    WHERE id = @HORARIO_ID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET 
            @Message = 'El horario no existe o está eliminado.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;
     IF @FECHA_INICIO IS NULL OR @FECHA_FIN IS NULL
        BEGIN
        SET @State = -1;
        SET @Message = 'Las fechas de inicio y fin son obligatorias.';
        SET @CodeError = -1;
        RETURN;
    END;

        IF @FECHA_INICIO > @FECHA_FIN
        BEGIN
        SET @State = -1;
        SET @Message = 'La fecha de inicio no puede ser mayor que la fecha fin.';
        SET @CodeError = -1;
        RETURN;
    END;

        -- desactivar vigencias
        UPDATE v
        SET v.bActivo = 0, --desactivado
            v.nUpdatedBy = @USER, 
            v.tUpdatedAt = GETDATE()
        FROM Vigencia v
        INNER JOIN HorarioDias hd ON v.horarioDiasId_fk = hd.id
        WHERE hd.horarioId_fk = @HORARIO_ID
        AND v.bActivo = 1; 

        --nueva vigencia
        INSERT INTO Vigencia
        (horarioDiasId_fk, bEliminado, nCreatedBy, tCreatedAt, bTipo, tFechaInicio, tFechaFin, bActivo)
    SELECT
        hd.id,
        0,
        @USER,
        GETDATE(),
        0, -- Global
        @FECHA_INICIO,
        @FECHA_FIN,
        1 -- 1 es Activo
    FROM HorarioDias hd
    WHERE hd.horarioId_fk = @HORARIO_ID
        AND hd.bEliminado = 0;

        COMMIT TRANSACTION;

        SET @Id = SCOPE_IDENTITY();
        SET @State = 1;
        SET @Message = 'Vigencia creada correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Id = 0; SET @State = 0; SET @CodeError = ERROR_NUMBER();
        SET @Message = ERROR_MESSAGE();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_InsertVigenciaIndividual]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crear la vigencia por horario Dia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_InsertVigenciaIndividual]
    @HORARIO_DIA_ID INT,
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @Id INT OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; 

    BEGIN TRY
        BEGIN TRANSACTION;

        -- VALIDACIONES DE EXISTENCIA
        IF NOT EXISTS (SELECT 1 FROM HorarioDias WHERE id = @HORARIO_DIA_ID AND bEliminado = 0)
        BEGIN
            SET @State = -1; SET @Message = 'El horario día no existe.';
            ROLLBACK TRANSACTION; RETURN;
        END;

        IF EXISTS(
            SELECT 1 
            FROM Vigencia 
            WHERE horarioDiasId_fk = @HORARIO_DIA_ID
            AND tFechaInicio = @FECHA_INICIO
            AND tFechaFin = @FECHA_FIN
            AND bEliminado = 0
        )
        BEGIN 
            SET @State = -1;
            SET @Message = 'Ya existe una vigencia con este rago de fechas'
            SET @CodeError = -1;
            RETURN;
        END;

        UPDATE Vigencia
        SET bActivo = 0,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
            FROM Vigencia V
        INNER JOIN HorarioDias hd ON v.horarioDiasId_fk = hd.id
        WHERE horarioDiasId_fk = @HORARIO_DIA_ID 
          AND bActivo = 1;

        -- INSERTAR NUEVA VIGENCIA INDIVIDUAL
        INSERT INTO Vigencia (
            horarioDiasId_fk, 
            bEliminado, 
            nCreatedBy, 
            tCreatedAt, 
            bTipo, -- 1 para Individual
            tFechaInicio, 
            tFechaFin,
            bActivo -- 1 para Activo
        )
        VALUES (
            @HORARIO_DIA_ID,
            0,
            @USER,
            GETDATE(),
            1, -- Tipo Individual
            @FECHA_INICIO,
            @FECHA_FIN,
            1  -- Estado Activo
        );

        SET @Id = SCOPE_IDENTITY();
        
        COMMIT TRANSACTION;

        SET @State = 1;
        SET @Message = 'Vigencia individual creada correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        SET @Id = 0;
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_listarNiveles]
FECHA: 18-02-2026
AUTOR: Gabriel
OBJETIVO: Listar niveles de grado sin duplicados

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 1   18-02-2026   Gabriel   Creación de procedimiento alineado al repository
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_listarNiveles]
AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    IdNivel AS idNivel,
    cNivel AS nombreNivel
  FROM Sync_GradoNivel
  GROUP BY
        IdNivel,
        cNivel;
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListarUsuariosPorRol]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar roles de un usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListarUsuariosPorRol] @UNIDAD_ID INT
    , @ROL_ID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ru.id rolUsuarioId
        , su.id usuarioId
        , su.cNombre nombre
        , su.cApellido apellidos
        , su.cTipo tipo
        , su.cUsuario usuario
        , r.cTitulo
    FROM Sync_Usuario su
    INNER JOIN RolUsuario ru
        ON ru.usuarioId_fk = su.id
    INNER JOIN Rol r
        ON r.id = ru.rolId_fk
    WHERE ru.bEliminado = 0
        AND r.bEliminado = 0
        AND (
            @UNIDAD_ID IS NULL
            OR r.unidadId_fk = @UNIDAD_ID
            )
        AND (
            @ROL_ID IS NULL
            OR ru.rolId_fk = @ROL_ID
            );
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_ListarUsuariosWithRol]
FECHA: 23-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Listar todos los usuarios indicando si tienen asignado el rol enviado

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListarUsuariosWithRol]
  @ROL_ID INT
AS
BEGIN
  SET NOCOUNT ON;

  SELECT U.id AS id
      , U.cUsuario AS usuario
      , U.cDni AS dni
      , U.cNombre  + ' ' + U.cApellido AS nombre
      , U.cApellido AS apellido
      , U.cTipo AS tipo
      , CASE WHEN RU.id IS NOT NULL THEN 1 ELSE 0 END AS tieneRol
  FROM Sync_Usuario AS U
    LEFT JOIN RolUsuario AS RU
    ON RU.usuarioId_fk = U.id
      AND RU.rolId_fk = @ROL_ID
      AND RU.bEliminado = 0
  ORDER BY U.cNombre
      , U.cApellido;
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListAsistenciasUsuarioRol]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Seleccionar Horarios de Usuario Rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListAsistenciasUsuarioRol]
    @ROL_USUARIO_ID INT
AS
BEGIN
    SELECT 
        a.id,
        a.tFecha as fecha,
        a.horaEntrada as horaEntrada,
        a.horaSalida as horaSalida,
        a.rolUsuarioid_fk as rolUsuarioId
        FROM Asistencia a
        WHERE rolUsuarioid_fk = @ROL_USUARIO_ID
        AND CAST(tFecha AS DATE) =  CAST(DATEADD(DAY,0, GETDATE()) AS DATE)
        AND bEliminado = 0
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListControles]
FECHA: 18-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar controles

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
01   15-12-2025  FLUNA      Añadir bEliminado = 0 a subconsultas en Case
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListControles]
AS
BEGIN
    SELECT
        id as id,
        nTolerancia as tolerancia,
        nLimiteFalta as  limiteFalta,
        nLimiteMarcacion as limiteMarcacion,
        CASE 
        WHEN EXISTS (SELECT 1 FROM ControlUnidad cu WHERE cu.controlId_fk = co.id AND cu.bEliminado = 0)
          OR EXISTS (SELECT 1 FROM ControlRolUsuario cru WHERE cru.controlId_fk = co.id AND cru.bEliminado = 0)
          OR EXISTS (SELECT 1 FROM RolControl rc WHERE rc.controlId_fk = co.id AND rc.bEliminado = 0)
        THEN 1 
        ELSE 0 
    END AS enUso
    FROM CONTROLES co 
    WHERE 
        co.bEliminado = 0 
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListRoles]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar roles con filtros opcionales

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListRoles]
    @UNIDAD_ID INT = NULL
AS
BEGIN
    SELECT
        r.id as id,
        r.cTitulo as titulo,
        r.cDescripcion as descripcion,
        r.bSupervision as supervicion,
        CASE 
            WHEN EXISTS (SELECT 1
            FROM RolControl rc
            WHERE rc.rolId_fk = r.id and rc.bEliminado = 0) 
            OR EXISTS (SELECT 1
            FROM RolUsuario ru
            WHERE ru.rolId_fk = r.id and ru.bEliminado = 0)
            THEN 1
        ELSE 0
    END AS enUso
    FROM Rol r
    WHERE 
        r.bEliminado = 0 AND
        r.unidadId_fk = COALESCE(@UNIDAD_ID, unidadId_fk)
    ORDER BY r.tCreatedAt DESC
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListRolesUnidad]
FECHA: 16-12-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar roles por unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListRolesUnidad]
@CONTROLID INT
AS
BEGIN
    SELECT
        r.id as id,
        r.cTitulo as titulo,
        r.cDescripcion as descripcion,
        r.bSupervision as supervicion,
        r.unidadId_fk as idunidad,
        SU.cTitulo as unidad,
        CASE 
            WHEN EXISTS (SELECT 1 FROM RolControl rc WHERE rc.rolId_fk = r.id)
            OR EXISTS (SELECT 1 FROM RolUsuario ru WHERE ru.rolId_fk = r.id)
            THEN 1
        ELSE 0
    END AS enUso
    FROM Rol r
    INNER JOIN Unidad U ON r.unidadId_fk = U.id
    INNER JOIN Sync_Unidad SU ON U.unidadOrgId_fk = SU.id
    WHERE 
        -- r.bEliminado = 0
          NOT EXISTS (
        SELECT 1
    FROM RolControl RC
    WHERE 
        -- CU.unidadId_fk = u.id
        RC.rolId_fk = r.id
        AND RC.controlId_fk = @CONTROLID
        AND RC.bEliminado = 0
    );
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_ListRolesUsuario]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar roles de un usuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListRolesUsuario]
    @ROL_ID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT RU.id AS usuarioRolId
        , RU.usuarioId_fk AS usuarioId
        , RU.rolId_fk AS rolId
        , R.cTitulo AS rol
        , R.bSupervision AS supervision
        , CASE WHEN RU.id IS NOT NULL THEN 1 ELSE 0 END AS asignado 
        , CASE 
            WHEN
                -- Verifica si el rolUsuario está en uso
                EXISTS (
                    SELECT 1
            FROM Licencia L
            WHERE L.rolUsuarioId_fk = RU.id
                AND L.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Permiso P
            WHERE P.rolUsuarioId_fk = RU.id
                AND P.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Justificacion J
            WHERE J.rolUsuarioId_fk = RU.id
                AND J.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM ControlVacaciones CV
            WHERE CV.rolUsuarioId_fk = RU.id
                AND CV.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM ControlRolUsuario CRU
            WHERE CRU.rolUsuarioId_fk = RU.id
                AND CRU.bEliminado = 0
                    )
            OR EXISTS (
                    SELECT 1
            FROM Asistencia A
            WHERE A.rolUsuarioid_fk = RU.id
                AND A.bEliminado = 0
                    )
                THEN 1
            ELSE 0
            END AS uso
        , CONCAT(U.cNombre,' ',U.cApellido) AS usuario
    FROM RolUsuario AS RU
        INNER JOIN Rol AS R
        ON RU.rolId_fk = R.id
            AND R.bEliminado = 0
        INNER JOIN Sync_Usuario AS U
        ON RU.usuarioId_fk = U.id
    WHERE RU.bEliminado = 0
        AND RU.rolId_fk = @ROL_ID
    ORDER BY RU.id;
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListRolUsuario]
FECHA: 17-12-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar Rol usuario po control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListRolUsuario]
    @CONTROLID INT
AS
BEGIN
    SELECT RU.id AS id
      , RU.usuarioId_fk AS usuarioId
      , SU.cUsuario AS usuario
      , RU.rolId_fk AS rolId
      , R.cTitulo  AS rol
      , SU.cNombre +' '+ SU.cApellido  AS nombre
      , SUN.cTitulo AS unidad
      , CASE 
            WHEN EXISTS (SELECT 1 FROM ControlVacaciones cv WHERE cv.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM GradoSupervisado gs WHERE gs.rolUsuarioId_pk = RU.id)
            OR EXISTS (SELECT 1 FROM HorarioUsuario hu WHERE hu.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM Justificacion j WHERE j.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM Licencia l WHERE l.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM Permiso p WHERE p.rolUsuarioId_fk = RU.id)
            OR EXISTS (SELECT 1 FROM Retirado r WHERE r.rolUsuarioid_fk = RU.id)
            OR EXISTS (SELECT 1 FROM TurnoModificado tm WHERE tm.rolUsuarioId_fk = RU.id)
            THEN 1
        ELSE 0 
        END AS uso
    FROM RolUsuario RU
        INNER JOIN Rol R ON RU.rolId_fk = R.id
        INNER JOIN Unidad U ON R.unidadId_fk = U.id
        INNER JOIN Sync_Unidad SUN ON U.unidadOrgId_fk = SUN.id
        INNER JOIN Sync_Usuario SU ON RU.usuarioId_fk = SU.id
    WHERE
     NOT EXISTS (
        SELECT 1
    FROM ControlRolUsuario CRU
    WHERE 
        CRU.rolUsuarioId_fk = RU.id
        AND CRU.controlId_fk = @CONTROLID
        AND CRU.bEliminado = 0
    )
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListSyncUsuarioPersona]
FECHA: 14-11-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar usuarios sin rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListSyncUsuarioPersona]
    @ROL_ID INT = NULL
AS
BEGIN

    IF @ROL_ID IS NULL
    BEGIN
        SELECT
            SU.id id,
            SU.cUsuario usuario,
            SU.cNombre nombre,
            SU.cApellido apellido,
            SU.cTipo tipo,
            SU.cDni dni
        FROM Sync_Usuario SU
    END
    ELSE
        -- Si se proporciona un ROL_ID, filtrar los usuarios que no tienen ese rol asignado
    BEGIN
        SELECT
            SU.id id,
            SU.cUsuario usuario,
            SU.cNombre nombre,
            SU.cApellido apellido,
            SU.cTipo tipo,
            SU.cDni dni
        FROM Sync_Usuario SU
        WHERE SU.id NOT IN (
            SELECT RU.usuarioId_fk
            FROM RolUsuario RU
            WHERE RU.rolId_fk = @ROL_ID
        )
    END
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListUnidad]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Listar unidades

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 01  24/11/2025  FLUNA      Se ñadio bEliminado=0 en CASE
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListUnidad]
-- @USER INT
AS
BEGIN
    SELECT
        u.id,
        u.horaTotal,
        u.horaEstandar,
        su.cTitulo as unidad,
        CASE 
            WHEN EXISTS (SELECT 1 FROM ControlUnidad cu WHERE cu.unidadId_fk = u.id AND cu.bEliminado = 0)
            OR EXISTS (SELECT 1 FROM Supervisor s WHERE s.unidadId_pk = u.id AND s.bEliminado = 0)
            OR EXISTS (SELECT 1 FROM Rol r WHERE r.unidadId_fk = u.id AND r.bEliminado = 0)
            OR EXISTS (SELECT 1 FROM UnidadFeriado uf WHERE uf.unidadId_pk = u.id )
        THEN 1 
        ELSE 0 
    END AS enUso
    FROM Unidad u
        INNER JOIN Sync_Unidad su on su.id = u.unidadOrgId_fk 
        LEFT JOIN Supervisor sp on sp.unidadId_pk = u.id
    -- WHERE sp.usuarioId_pk = @USER AND u.bEliminado = 0
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListUnidadesByControl]
FECHA: 12-12-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar las unidades segun el control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListUnidadesByControl]
    @CONTROLID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        CU.id AS id,
        CU.controlId_fk AS controlId,
        U.unidadOrgId_fk AS unidadId,
        SU.cTitulo AS unidad,
        CASE 
    WHEN
    EXISTS(SELECT 1
        FROM ControlUnidadAsistencia CUA
        WHERE CUA.controlUnidadId_fk = CU.id AND CUA.bEliminado=0)
    THEN 1
    ELSE 0
    END AS enUso

    FROM ControlUnidad CU
        INNER JOIN Unidad U on U.id = CU.unidadId_fk
        INNER JOIN Sync_Unidad SU on SU.id = U.unidadOrgId_fk
    WHERE 
        CU.controlId_fk = @CONTROLID
        AND CU.bEliminado = 0
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_ListUnidadesOrganizativas]
FECHA: 17-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Listar unidades organizativas que no esta relacionada un control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_ListUnidadesOrganizativas]
    @CONTROLID INT
AS
BEGIN
    SELECT
        u.id,
        u.horaTotal,
        u.horaEstandar,
        su.cTitulo as unidad,
        CASE 
            WHEN 
             EXISTS (SELECT 1
            FROM Supervisor s
            WHERE s.unidadId_pk = u.id AND s.bEliminado = 0)
            OR EXISTS (SELECT 1
            FROM Rol r
            WHERE r.unidadId_fk = u.id AND r.bEliminado = 0)
            OR EXISTS (SELECT 1
            FROM UnidadFeriado uf
            WHERE uf.unidadId_pk = u.id)
        THEN 1 
        ELSE 0 
    END AS enUso
    FROM Unidad u
        INNER JOIN Sync_Unidad su on su.id = u.unidadOrgId_fk
    WHERE 
     NOT EXISTS (
        SELECT 1
    FROM ControlUnidad CU
    WHERE 
        CU.unidadId_fk = u.id
        AND CU.controlId_fk = @CONTROLID
        AND CU.bEliminado = 0
    );
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_marcarCita]
FECHA: 13-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite marcar una cita como realizada.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
1     16-02-2026   Gabriel       Validación para citas ya marcadas.
2     16-02-2026   Gabriel       Validación para marcar solo en la fecha actual.
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_marcarCita]
  @ID INT,
  @HORA_MARCACION TIME,
  @USER INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN

  BEGIN TRY
    IF NOT EXISTS (
      SELECT 1
  FROM Cita
  WHERE id = @ID AND bEliminado = 0
    )
    BEGIN
    SET @State = -1;
    SET @Message = 'La cita no existe.';
    RETURN;
  END

    IF EXISTS (
      SELECT 1
  FROM Cita
  WHERE id = @ID AND horaMarcacion IS NOT NULL AND bEliminado = 0
    )
    BEGIN
    SET @State = -1;
    SET @Message = 'La cita ya tiene una marcación registrada.';
    RETURN;
  END

    IF EXISTS (
      SELECT 1
  FROM Cita
  WHERE id = @ID AND bEliminado = 0
    AND fecha <> CONVERT(DATE, GETDATE())
    )
    BEGIN
    SET @State = -1;
    SET @Message = 'Solo se puede marcar la asistencia en la fecha de hoy.';
    RETURN;
  END

    UPDATE Cita
    SET horaMarcacion = @HORA_MARCACION,
        nUpdatedBy = @USER,
        tUpdatedAt = GETDATE()
    WHERE id = @ID;

    IF @@ROWCOUNT > 0
    BEGIN
    SET @State = 0;
    SET @Message = 'La cita fue marcada como realizada correctamente.';
  END
    ELSE
    BEGIN
    SET @State = -1;
    SET @Message = 'No se pudo marcar la cita como realizada.';
  END
  END TRY
  BEGIN CATCH
    SET @State = -2;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_RemoveCursoBasicoTurnoRegular]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite eliminar un curso en el turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_RemoveCursoBasicoTurnoRegular]
  @CURSO_DETALLEREGULAR_ID INT,
  @USUARIO INT,
  @State INT OUTPUT,
  @Message VARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE CursoSeccionBasica_TurnoRegular
  SET bEliminado = 1,
      nUpdatedBy = @USUARIO,
      tUpdatedAt = GETDATE()
  WHERE id = @CURSO_DETALLEREGULAR_ID
  ;

  SET @State = 1;
  SET @Message = 'Curso eliminado correctamente';
  SET @CodeError = 0;
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_RemoveCursoTurnoRegular]
FECHA: 22/12/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite eliminar un curso en el turno regular.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_RemoveCursoTurnoRegular]
  @CURSO_ID INT,
  @USUARIO INT,
  @State INT OUTPUT,
  @Message VARCHAR(250) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  UPDATE CursoSeccionPreUniversitaria_TurnoRegular
  SET bEliminado = 1,
      nUpdatedBy = @USUARIO,
      tUpdatedAt = GETDATE()
  WHERE id = @CURSO_ID
  ;

  SET @State = 1;
  SET @Message = 'Curso eliminado correctamente';
  SET @CodeError = 0;
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite actualizar un biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateBiometrico] @ID INT
    , @MARCA VARCHAR(100) = NULL
    , @TIPOBD VARCHAR(50) = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF (
                @MARCA IS NOT NULL
                AND LTRIM(RTRIM(@MARCA)) <> ''
                )
        BEGIN
            IF (LEFT(@MARCA, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 2;
                SET @Message = 'La marca no deben iniciar con espacio, "-" ni "_".';

                RETURN;
            END;
        END;

        IF (
                @TIPOBD IS NOT NULL
                AND LTRIM(RTRIM(@TIPOBD)) <> ''
                )
        BEGIN
            IF (LEFT(@TIPOBD, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 3;
                SET @Message = 'El tipoBD, no puede iniciar con espacio, "-" ni "_"  '

                RETURN;
            END;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El biométrico no existe o está eliminado.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(marca) = UPPER(@MARCA)
                    AND UPPER(tipoBD) = UPPER(@TIPOBD)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Ya existe, un biometrico con estos datos.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(marca) = UPPER(@MARCA)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'Ya existe, esta marca registrada'

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM Biometrico
                WHERE UPPER(tipoBD) = UPPER(@TIPOBD)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya existe, el tipoBD registrado'

            RETURN;
        END

        UPDATE Biometrico
        SET marca = COALESCE(NULLIF(@MARCA, ''), marca)
            , tipoBD = COALESCE(NULLIF(@TIPOBD, ''), tipoBD)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se actualizó ningún registro.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateCancelarCita]
FECHA: 07-10-2025
AUTOR: Jesamine M. Ramón Yora
OBJETIVO: Permite cancelar una cita (marcarla como cancelada sin eliminarla del registro).

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
01    06/01/2026   fluna         añadir activacion de cita
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateCancelarCita]
    @ID INT
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Cita
                WHERE id = @ID
                AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El registro no existe o ya fue eliminado.';
            RETURN;
        END;
        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE id = @ID
                AND bCancelado = 1
                )
        BEGIN
            UPDATE Cita
            SET bCancelado = 0
                , nUpdatedBy = @USER
                , tUpdatedAt = GETDATE()
               WHERE id = @ID
                 AND bEliminado = 0;
            IF @@ROWCOUNT > 0
            BEGIN
                SET @State = 0;
                SET @Message = 'La cita fue activada correctamente.';
            END
            ELSE
            BEGIN
                SET @State = - 1;
                SET @Message = 'No se pudo activar la cita.';
            END
        END
        ELSE BEGIN
            UPDATE Cita
            SET bCancelado = 1
                , nUpdatedBy = @USER
                , tUpdatedAt = GETDATE()
                WHERE id = @ID
                AND bEliminado = 0;
        IF @@ROWCOUNT > 0
            BEGIN
                SET @State = 0;
                SET @Message = 'La cita fue cancelada correctamente.';
            END
            ELSE
            BEGIN
                SET @State = - 1;
                SET @Message = 'No se pudo cancelar la cita.';
            END;
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
Nombre: [dbo].[usp_UpdateCitas]
Autor: Jeandry Angulo Marquez
Fecha: 26-09-2025
OBJETIVO: Procedimiento para actualizar 

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
 -    -             -             -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateCitas] @ID INT
    , @HORARIOUSUARIOID INT = NULL
    , @NOMBRE VARCHAR(250) = NULL
    , @DESCRIPCION VARCHAR(250) = NULL
    , @FECHA DATE = NULL
    , @HORA TIME = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @fechagn DATE;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Cita
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El registro no existe o ya fue eliminado.';

            RETURN;
        END;

        -- Normalizar fechas vacías o por defecto a NULL
        IF (@FECHA = '1900-01-01')
            SET @FECHA = NULL;

        IF (
                @HORA IS NULL
                OR FORMAT(@HORA, 'HH:mm') = '00:00'
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Debe ingresar una hora válida distinta de 00:00.';

            RETURN;
        END;

        IF (
                @NOMBRE IS NOT NULL
                AND LTRIM(RTRIM(@NOMBRE)) <> ''
                )
        BEGIN
            IF (LEFT(@NOMBRE, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 3;
                SET @Message = 'El tipoBD, no puede iniciar con espacio, "-" ni "_"  '

                RETURN;
            END;
        END;

        IF (
                @DESCRIPCION IS NOT NULL
                AND LTRIM(RTRIM(@DESCRIPCION)) <> ''
                )
        BEGIN
            IF (LEFT(@DESCRIPCION, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 4;
                SET @Message = 'La marca no deben iniciar con espacio, "-" ni "_".';

                RETURN;
            END;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(nombre) = UPPER(@NOMBRE)
                    AND UPPER(cDescripcion) = UPPER(@DESCRIPCION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Ya existe una cita con el mismo nombre y descripción.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(nombre) = UPPER(@NOMBRE)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'Ya existe una cita con el mismo nombre.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE UPPER(cDescripcion) = UPPER(@DESCRIPCION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya existe una cita con el mismo descripcion.';

            RETURN;
        END;

        SELECT @fechagn = fecha
        FROM Cita
        WHERE id = @ID

        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE fecha = COALESCE(@FECHA, @fechagn)
                    AND hora = @HORA
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'la hora ya fue registrada'

            RETURN;
        END

        -- IF EXISTS (
        --         SELECT 1
        --         FROM Cita
        --         WHERE fecha = COALESCE(@FECHA, @fechaActual)
        --             AND hora = @HORA
        --             AND id <> @ID
        --             AND bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 9;
        --     SET @Message = 'Ya existe una cita registrada en la misma fecha y hora.';
        --     RETURN;
        -- END;
        IF EXISTS (
                SELECT 1
                FROM Cita
                WHERE fecha = @FECHA
                    AND hora = @HORA
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'Ya existe una cita registrada en la misma fecha y hora.';

            RETURN;
        END;

        UPDATE Cita
        SET horarioUsuarioId_fk = COALESCE(@HORARIOUSUARIOID, horarioUsuarioId_fk)
            , nombre = COALESCE(NULLIF(@NOMBRE, ''), nombre)
            , cDescripcion = COALESCE(NULLIF(@DESCRIPCION, ''), cDescripcion)
            , fecha = COALESCE(@FECHA, fecha)
            , hora = COALESCE(@HORA, hora)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización realizada correctamente.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se realizaron cambios en el registro.';
        END;
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControl]
FECHA: 18-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar un control

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateControl]
    @CONTROL_ID INT
    , @TOLERANCIA INT
    , @LIMITE_FALTA INT
    , @LIMITE_MARCACION INT
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT

    BEGIN TRY
        IF EXISTS (
                SELECT 1
                FROM CONTROLES
                WHERE nTolerancia = @TOLERANCIA
                    AND nLimiteFalta = @LIMITE_FALTA
                    AND nLimiteMarcacion = @LIMITE_MARCACION
                    AND Id <> @CONTROL_ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'Ya existe otro registro con esos valores';
            SET @CodeError = - 1;

            RETURN;
        END;

        UPDATE CONTROLES
        SET nTolerancia = COALESCE(@TOLERANCIA, nTolerancia)
            , nLimiteFalta = COALESCE(@LIMITE_FALTA, nLimiteFalta)
            , nLimiteMarcacion = COALESCE(@LIMITE_MARCACION, nLimiteMarcacion)
        WHERE id = @CONTROL_ID

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Control actualizada correctamente.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControlRolUsuario]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar control para rolUsuario en la tabla intermedia ControlRolUsuario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateControlRolUsuario]
    @ID INT,
    @CONTROL_ID INT = NULL,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM dbo.ControlRolUsuario WHERE id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro de ControlRolUsuario no existe o está eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        -- Actualizar registro
        UPDATE dbo.ControlRolUsuario
        SET controlId_fk    = COALESCE(@CONTROL_ID, controlId_fk),
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()     
        WHERE id = @ID;

        SET @State = 1;
        SET @Message = 'Registro actualizado correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH

        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControlUnidad]
FECHA: 25-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar control para ControlUnidad en la tabla UpdateControlUnidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateControlUnidad]
    @Id INT,
    @CONTROL_ID INT = NULL,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        -- Validar que el registro exista y no esté eliminado
        IF NOT EXISTS (SELECT 1 
                       FROM ControlUnidad 
                       WHERE id = @Id AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró el registro de ControlUnidad.';
            SET @CodeError = -1;
            RETURN;
        END;

        -- Actualizar
        UPDATE ControlUnidad
        SET controlId_fk = COALESCE(@CONTROL_ID, controlId_fk),
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @Id;

        SET @State = 1;
        SET @Message = 'ControlUnidad actualizado correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateControlVacaciones]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Actualizar datos de control vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateControlVacaciones]
    @ID INT
    , @DIASDISPONIBLES INT = NULL
    , @DIASTOMADOS INT = NULL
    , @B_APROBADO BIT
    , @USER INT
    , @APROBADO BIT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF (@DIASDISPONIBLES IS NOT NULL AND @DIASDISPONIBLES < 0)
        BEGIN
            SET @State = - 1;
            SET @Message = 'El numero de días disponibles no es válido.';

            RETURN;
        END;

        IF  (@DIASTOMADOS IS NOT NULL AND @DIASTOMADOS < 0)
        BEGIN
            SET @State = - 1;
            SET @Message = 'El numero de días tomados no es válido.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM ControlVacaciones
                WHERE bEliminado = 0
                    AND Id = @ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'El control no existe o fue eliminado';

            RETURN
        END

        UPDATE ControlVacaciones
        SET nDiasDisponibles = COALESCE(NULLIF(@DIASDISPONIBLES, 0), nDiasDisponibles)
            , nDiasTomados = COALESCE(NULLIF(@DIASTOMADOS, 0), nDiasTomados)
            , nUpdatedBy = @USER
            , bAprobado = COALESCE(@B_APROBADO, bAprobado)
            , nAprobadoBy = @APROBADO
            , tUpdateAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER()
    END CATCH
END
GO
 
/*======================================================================================================
    NOMBRE: [dbo].[usp_UpdateCursoSeccionBasicaTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Actualizar la relación entre curso sección básica y turno regular
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
     -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateCursoSeccionBasicaTurnoRegular]
    @ID INT,
    @SYNC_CURSO_SECCION_ID INT,
    @TURNO_REGULAR_ENTRADA_ID INT,
    @TURNO_REGULAR_SALIDA_ID INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY

        IF NOT EXISTS (
            SELECT 1
            FROM CursoSeccionBasica_TurnoRegular
            WHERE id = @ID AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'No se encontró la asignación especificada para actualizar.';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS (
            SELECT 1 FROM
                CursoSeccionBasica_TurnoRegular
            WHERE turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID
              AND turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID
              AND id <> @ID
              AND bEliminado = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'Ya existe una asignación registrada para este turno regular.';
            SET @CodeError = -2;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @TURNO_REGULAR_ENTRADA_ID AND bTipo = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de entrada no es válido. Debe tener bTipo = 0.';
            SET @CodeError = -3;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @TURNO_REGULAR_SALIDA_ID AND bTipo = 1
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de salida no es válido. Debe tener bTipo = 1.';
            SET @CodeError = -4;
            RETURN;
        END

        UPDATE CursoSeccionBasica_TurnoRegular
        SET 
            syncCursoSeccionId = @SYNC_CURSO_SECCION_ID,
            turnoRegularEntradaId = @TURNO_REGULAR_ENTRADA_ID,
            turnoRegularSalidaId = @TURNO_REGULAR_SALIDA_ID,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID;

        SET @State = 1;
        SET @Message = 'Asignación actualizada exitosamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
        RETURN;
    END CATCH
END
GO
 
/*======================================================================================================
    NOMBRE: [dbo].[usp_UpdateCursoSeccionPreUniversitarioTurnoRegular]
    FECHA: 02-10-2025
    AUTOR: Gabriel Vásquez Uscuvilca
    OBJETIVO: Actualizar tabla CursoSeccionPreUniversitaria_TurnoRegular
    MODIFICACIONES:
    NRO  FECHA       USUARIO    MODIFICACION
    -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateCursoSeccionPreUniversitarioTurnoRegular]
    @Id INT,
    @syncCursoSeccionPreUniversitariaId INT,
    @turnoRegularEntradaId INT,
    @turnoRegularSalidaId INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON; 

    BEGIN TRY

        IF NOT EXISTS (SELECT 1 FROM CursoSeccionPreUniversitaria_TurnoRegular WHERE id = @Id AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'No existe una asignación registrada con el Id proporcionado.';
            SET @CodeError = -1;
            RETURN;
        END

        -- IF EXISTS (
        --     SELECT 1
        --     FROM CursoSeccionPreUniversitaria_TurnoRegular
        --     WHERE turnoRegularEntradaId = @turnoRegularEntradaId
        --       AND turnoRegularSalidaId = @turnoRegularSalidaId
        --       AND id <> @Id
        --       AND bEliminado = 0
        -- )
        -- BEGIN
        --     SET @State = -1;
        --     SET @Message = 'Ya existe una asignación registrada para una sección preuniversitaria con el mismo turno de entrada y salida.';
        --     SET @CodeError = -2;
        --     RETURN;
        -- END

        -- verificar si entrada es bTipo 0
        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @turnoRegularEntradaId AND bTipo = 0
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de entrada debe ser de tipo 0.';
            SET @CodeError = -3;
            RETURN;
        END

        -- verificar si salida es bTipo 1
        IF NOT EXISTS (
            SELECT 1
            FROM TurnoRegular
            WHERE id = @turnoRegularSalidaId AND bTipo = 1
        )
        BEGIN
            SET @State = -1;
            SET @Message = 'El turno de salida debe ser de tipo 1.';
            SET @CodeError = -4;
            RETURN;
        END

        -- Realizar la actualización
        UPDATE CursoSeccionPreUniversitaria_TurnoRegular
        SET
            syncCursoSeccionPreUniversitariaId = @syncCursoSeccionPreUniversitariaId,
            turnoRegularEntradaId = @turnoRegularEntradaId,
            turnoRegularSalidaId = @turnoRegularSalidaId,
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @Id;

        SET @State = 1;
        SET @Message = 'Asignación actualizada correctamente.';
        SET @CodeError = 0;

    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateDetalleBiometrico]
FECHA: 18-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite ctualizar un detalle biométrico.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateDetalleBiometrico] @ID INT
    , @NOMBRE VARCHAR(50) = NULL
    , @IP CHAR(50) = NULL
    , @SERIE VARCHAR(50) = NULL
    , @UBICACION VARCHAR(100) = NULL
    , @HUELLA BIT
    , @ROSTRO BIT
    , @TARJETA BIT
    , @USER INT
    , @State INT OUTPUT
    , @Message NVARCHAR(200) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT;

    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El detalleBiométrico no existe o está eliminado';

            RETURN;
        END;

        IF (
                (
                    @NOMBRE IS NOT NULL
                    AND LTRIM(RTRIM(@NOMBRE)) <> ''
                    AND LEFT(@NOMBRE, 1) IN (' ', '-', '_')
                    )
                OR (
                    @IP IS NOT NULL
                    AND LTRIM(RTRIM(@IP)) <> ''
                    AND LEFT(@IP, 1) IN (' ', '-', '_')
                    )
                OR (
                    @SERIE IS NOT NULL
                    AND LTRIM(RTRIM(@SERIE)) <> ''
                    AND LEFT(@SERIE, 1) IN (' ', '-', '_')
                    )
                OR (
                    @UBICACION IS NOT NULL
                    AND LTRIM(RTRIM(@UBICACION)) <> ''
                    AND LEFT(@UBICACION, 1) IN (' ', '-', '_')
                    )
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'Los campos no deben iniciar con espacio, "-" ni "_".';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(cNombre) = UPPER(@NOMBRE)
                    AND UPPER(ip) = UPPER(@IP)
                    AND UPPER(serie) = UPPER(@SERIE)
                    AND UPPER(ubicacion) = UPPER(@UBICACION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'Ya existe un detalle con el misma nombre, IP, Serie y ubicación';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(ip) = UPPER(@IP)
                    AND UPPER(serie) = UPPER(@SERIE)
                    AND UPPER(ubicacion) = UPPER(@UBICACION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Ya existe un detalle con el mismo IP, Serie y ubicación';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(serie) = UPPER(@SERIE)
                    AND UPPER(ubicacion) = UPPER(@UBICACION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'Ya existe un detalle con el mismo Serie y ubicación';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(cNombre) = UPPER(@NOMBRE)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya existe un detalle con el mismo nombre';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(ip) = UPPER(@IP)
                    AND id <> @id
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 8;
            SET @Message = 'La IP ya está registrada en otro detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(serie) = UPPER(@SERIE)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 9;
            SET @Message = 'La Serie ya está registrada en otro detalle.';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM DetalleBiometrico
                WHERE UPPER(ubicacion) = UPPER(@UBICACION)
                    AND id <> @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 10;
            SET @Message = 'Ya existe un detalle en la misma ubicación.';

            RETURN;
        END;

        UPDATE DetalleBiometrico
        SET cNombre = COALESCE(NULLIF(@NOMBRE, ''), cNombre)
            , ip = COALESCE(NULLIF(@IP, ''), ip)
            , serie = COALESCE(NULLIF(@SERIE, ''), serie)
            , ubicacion = COALESCE(NULLIF(@UBICACION, ''), ubicacion)
            , bHuella = @HUELLA
            , bRostro = @ROSTRO
            , bTarjeta = @TARJETA
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF @@ROWCOUNT > 0
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se actualizó ningún registro.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*=================================================================================
NOMBRE: [dbo].[usp_UpdateEstadoAsistencia]
AUTOR: Jeandry Angulo Marquez
FECHA: 18-09-2025
OBJETIVO: Permite Actualizar datos de estado asistencia

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
--=================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateEstadoAsistencia] @ID INT
    , @NOMBRE VARCHAR(40)
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(250) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT
        , XACT_ABORT ON;

    DECLARE @AffectedRows INT;

    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM EstadoAsistencia
                WHERE id = @ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'No se encontro el Estado Asistenia'
            SET @CodeError = - 2;

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM EstadoAsistencia
                WHERE cNombre = @NOMBRE
                    AND id <> @ID
                )
        BEGIN
            SET @State = - 1;
            SET @Message = 'Ya existe un estado asistencia con los mismos datos.'
            SET @CodeError = - 3;

            RETURN;
        END

        IF (
                @NOMBRE IS NOT NULL
                AND LTRIM(RTRIM(@NOMBRE)) <> ''
                )
        BEGIN
            IF (LEFT(@NOMBRE, 1) IN (' '))
            BEGIN
                SET @State = - 4;
                SET @Message = 'El nombre no puede iniciar con espacio.';

                RETURN;
            END;
        END;

        IF PATINDEX('%[^a-zA-ZÁÉÍÓÚáéíóúÑñ ]%', @NOMBRE) > 0
        BEGIN
            SET @State = - 5;
            SET @Message = 'No se permite ingresar numero, ni _, en el nombre'

            RETURN;
        END

        UPDATE EstadoAsistencia
        SET cNombre = COALESCE(NULLIF(@NOMBRE, ''), cNombre)
            , nUpdatedBy = @USER
            , tUpdateAt = GETDATE()
        WHERE id = @ID

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = - 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateHorario]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Actualizar un horario

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateHorario] 
    @ID INT
    , @TITULO VARCHAR(50) = NULL
    , @HORADIA VARCHAR(5) = NULL
    , @GENERAL BIT
    , @EXTENDIDO BIT
    , @ROTATIVO BIT
    , @REGULAR BIT
    , @TEMPORADA_ID INT = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF NOT EXISTS (
                SELECT 1
                FROM Horario
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2
            SET @Message = 'El horario no existe o ha sido eliminado';

            RETURN
        END

        IF (
                @TITULO IS NOT NULL
                AND LTRIM(RTRIM(@TITULO)) <> ''
                )
        BEGIN
            IF (LEFT(@TITULO, 1) IN (' ', '-', '_'))
            BEGIN
                SET @State = - 3;
                SET @Message = 'El título no puede iniciar con espacio, "-" ni "_".';

                RETURN;
            END;
        END;

        IF (
                @HORADIA IS NOT NULL
                AND @HORADIA <> ''
                AND @HORADIA LIKE '[ -_]%'
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'La hora no puede iniciar con espacio, "-" ni "_".';

            RETURN;
        END;

        IF (
                @HORADIA IS NOT NULL
                AND LTRIM(RTRIM(@HORADIA)) IN ('0', '00', '00:00')
                )
        BEGIN
            SET @State = - 5;
            SET @Message = 'Debe registrar una hora válida (no "0", "00" ni "00:00").';

            RETURN;
        END;

        IF EXISTS (
                SELECT 1
                FROM Horario
                WHERE UPPER(cTitulo) = UPPER(@TITULO)
                    AND horaDia = @HORADIA
                    AND id <> @Id
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 6;
            SET @Message = 'Ya esta en uso el título y horaDia en otro horario.';

            RETURN;
        END

        IF EXISTS (
                SELECT 1
                FROM Horario
                WHERE UPPER(cTitulo) = UPPER(@TITULO)
                    AND id <> @Id
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Ya esta en uso el titulo en otro horario.';

            RETURN;
        END

        -- IF EXISTS (
        --         SELECT 1
        --         FROM Horario
        --         WHERE horaDia = @HORADIA
        --             AND id <> @Id
        --             AND bEliminado = 0
        --         )
        -- BEGIN
        --     SET @State = - 8;
        --     SET @Message = 'Ya esta en uso el hora en otro horario.';
        --     RETURN;
        -- END
        UPDATE Horario
        SET cTitulo = COALESCE(NULLIF(@TITULO, ''), cTitulo)
            , horaDia = COALESCE(NULLIF(@HORADIA, ''), horaDia)
            , bGeneral = COALESCE(@GENERAL, bGeneral)
            , bExtendido = COALESCE(@EXTENDIDO, bExtendido)
            , bRotativo = COALESCE(@ROTATIVO, bRotativo)
            , bRegular = COALESCE(@REGULAR, bRegular)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
            , idTemporada = COALESCE(@TEMPORADA_ID, idTemporada)
        WHERE id = @Id
            AND bEliminado = 0;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 

/*======================================================================================================
NOMBRE: [dbo].[usp_updateHorarioCita]
FECHA: 13-02-2026
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite actualizar un horario para una cita.

MODIFICACIONES:
NRO   FECHA        USUARIO       DESCRIPCIÓN
-      -             -           -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_updateHorarioCita]
  @HORARIO_ID INT,
  @TITULO VARCHAR(255),
  @USER INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  BEGIN TRY

    IF NOT EXISTS (
      SELECT 1
        FROM Horario
      WHERE id = @HORARIO_ID AND bEliminado = 0
    )
    BEGIN
        SET @State = -1;
        SET @Message = 'El horario de cita no existe.';
        RETURN;
    END

    UPDATE Horario
    SET cTitulo = @TITULO,
        nUpdatedBy = @USER,
        tUpdatedAt = GETDATE()
    WHERE id = @HORARIO_ID;
        IF @@ROWCOUNT > 0
        BEGIN
    
    SET @State = 0;
    SET @Message = 'El horario de cita fue actualizado correctamente.';
  END
        ELSE
        BEGIN
    SET @State = -1;
    SET @Message = 'No se pudo actualizar el horario de cita.';
  END
    END TRY
    BEGIN CATCH
        SET @State = -2;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateHorarioUsuario]
FECHA: 03-10-2024
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Actualizar un registro en la tabla HorarioUsuario.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE dbo.usp_UpdateHorarioUsuario
    @ID INT,
    @FECHAINICIO DATE = NULL,
    @FECHAFIN DATE = NULL,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET @CodeError = 0;
    BEGIN TRY
        DECLARE @AffectedRows INT;

        IF @FECHAINICIO > @FECHAFIN
        BEGIN
        SET @State = -1;
        SET @Message = 'La fecha de inicio no puede ser mayor a la fecha fin.';
        RETURN;
    END;
    --     IF NOT EXISTS(
    --         SELECT 1
    -- FROM Vigencia
    -- WHERE horarioDiasId_fk IN(SELECT horarioDiasId_fk
    --     FROM HorarioDias
    --     WHERE horarioId_fk = @ID AND bEliminado = 0)
    --     AND bActivo = 1
    --     AND bEliminado = 0
    --     AND (
    --          @FECHAINICIO >= tFechaInicio
    --     AND @FECHAFIN <= tfechaFin
    --     )
        
    --     )
    --     BEGIN
    --     SET @State = -1;
    --     SET @Message = 'El rango de fechas ingresado debe de estar dentro de la vigencia del horario.';
    --     RETURN;
    -- END;

        IF NOT EXISTS (
            SELECT 1
    FROM dbo.HorarioUsuario
    WHERE id = @ID
        AND bEliminado = 0
        )
        BEGIN
        SET @State = -1;
        SET @Message = 'El registro de HorarioUsuario no existe o está inactivo.';
        RETURN;
    END;

        UPDATE dbo.HorarioUsuario
        SET 
            tfechaInicio = COALESCE(@FECHAINICIO, tfechaInicio),
            tFechaFin = COALESCE(@FECHAFIN, tFechaFin),
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE id = @ID
        AND bEliminado = 0;

        SET @AffectedRows = @@ROWCOUNT;

        IF (@AffectedRows > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Actualización exitosa.';
    END
        ELSE
        BEGIN
        SET @State = -1;
        SET @Message = 'No se realizó ninguna actualización.';
    END
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateLicencia]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Actualizar una licencia existente.
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateLicencia]
    @ID INT,
    @ROLUSUARIOID INT,
    @MOTIVOID INT,
    @TITULO VARCHAR(250) = NULL,
    @DETALLE VARCHAR(250) = NULL,
    @FECHAINICIO DATE = NULL,
    @FECHAFIN DATE = NULL,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
    FROM Licencia
    WHERE id = @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 2;
        SET @Message = 'La licencia no existe o fue eliminada.';

        RETURN;
    END;

        IF NOT EXISTS (
                SELECT 1
    FROM RolUsuario
    WHERE id = @ROLUSUARIOID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 3;
        SET @Message = 'El rolUsuario no existe o fue eliminado.';

        RETURN;
    END;

        IF NOT EXISTS (
                SELECT 1
    FROM Motivo
    WHERE id = @MOTIVOID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 4;
        SET @Message = 'El motivo no existe o fue eliminado.';

        RETURN;
    END;

        IF (
                (
                    @TITULO IS NOT NULL
        AND LTRIM(RTRIM(@TITULO)) <> ''
        AND LEFT(@TITULO, 1) IN (' ', '-', '_')
                    )
        OR (
                    @DETALLE IS NOT NULL
        AND LTRIM(RTRIM(@DETALLE)) <> ''
        AND LEFT(@DETALLE, 1) IN (' ', '-', '_')
                    )
                )
        BEGIN
        SET @State = - 5;
        SET @Message = 'El título o detalle no deben iniciar con espacio, "-" ni "_".';

        RETURN;
    END;

        -- Normalizar fechas vacías o por defecto a NULL
        IF (@FECHAINICIO = '1900-01-01')
            SET @FECHAINICIO = NULL;

        IF (@FECHAFIN = '1900-01-01')
            SET @FECHAFIN = NULL;

        IF (@FECHAFIN < @FECHAINICIO)
        BEGIN
        SET @State = - 6;
        SET @Message = 'La fecha fin no puede ser menor a la fecha inicio.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM Licencia
    WHERE UPPER(titulo) = UPPER(@TITULO)
        AND UPPER(detalle) = UPPER(@DETALLE)
        AND id <> @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 7;
        SET @Message = 'Ya existe una licencia, con el mismo título y detalle.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM Licencia
    WHERE UPPER(titulo) = UPPER(@TITULO)
        AND id <> @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 8;
        SET @Message = 'Ya existe una licencia con el mismo titulo.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM Licencia
    WHERE UPPER(detalle) = UPPER(@DETALLE)
        AND id <> @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 9;
        SET @Message = 'Ya existe una licencia con el mismo detalle.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM Licencia
    WHERE rolUsuarioId_fk = @ROLUSUARIOID
        AND id <> @ID
        AND bEliminado = 0
        AND (
                        (@FECHAINICIO BETWEEN tFechaInicio AND tFechaFin)
        OR (@FECHAFIN BETWEEN tFechaInicio AND tFechaFin)
        OR (tFechaInicio BETWEEN @FECHAINICIO AND @FECHAFIN)
        OR (tFechaFin BETWEEN @FECHAINICIO AND @FECHAFIN)
                        )
                )
      BEGIN
        SET @State = - 10;
        SET @Message = 'Ya existe una licencia para el RolUsuario con el rango de fechas.';

        RETURN;
    END;

        UPDATE Licencia
        SET rolUsuarioId_fk = @ROLUSUARIOID
            , motivoId_fk = @MOTIVOID
            , titulo = COALESCE(NULLIF(@TITULO, ''), Titulo)
            , detalle = COALESCE(NULLIF(@DETALLE, ''), Detalle)
            , tFechaInicio = COALESCE(@FECHAINICIO, tFechaInicio)
            , tFechaFin = COALESCE(@FECHAFIN, tFechaFin)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @Id
        AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Actualización exitosa.';
    END
        ELSE
        BEGIN
        SET @State = - 1;
        SET @Message = 'Fallo en la actualización.';
    END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_InsertOneSituacion]
FECHA: 31-07-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Crea una situacion

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateOneSituacion]
  @Id INT,
  @Nombre VARCHAR(50) = NULL,
  @ORDEN INT = NULL,
  @User INT,
  @State INT OUTPUT,
  @Message VARCHAR(255) OUTPUT,
  @CodeError INT OUTPUT
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    -- Verificar existencia
    IF NOT EXISTS (SELECT 1 FROM Situacion WHERE Id = @Id)
    BEGIN
      SET @State = -1;
      SET @Message = 'Situación no encontrada';
      SET @CodeError = -1;
      RETURN;
    END

    -- Validación: el nombre no debe existir en otro registro
    IF EXISTS (
      SELECT 1
      FROM Situacion
      WHERE cNombre COLLATE Latin1_General_CI_AI = @Nombre COLLATE Latin1_General_CI_AI
        AND Id <> @Id
    )
    BEGIN
      SET @State = -1;
      SET @Message = 'Ya existe otra situación con ese nombre';
      SET @CodeError = -1;
      RETURN;
    END

    IF EXISTS (
      SELECT 1
      FROM Situacion
      WHERE nOrden = @ORDEN
        AND Id <> @Id
    )
    BEGIN
      SET @State = -1;
      SET @Message = 'Ya existe otra situación con ese orden';
      SET @CodeError = -1;
      RETURN;
    END

    UPDATE Situacion
    SET 
        cNombre = ISNULL(@Nombre, cNombre),
        nOrden = ISNULL(@ORDEN, nOrden),
        nUpdatedBy = @User,
        tUpdatedAt = GETDATE()
    WHERE Id = @Id;

    IF @@ROWCOUNT = 0
    BEGIN
      SET @State = -1;
      SET @Message = 'No se encontró la situación';
      SET @CodeError = -1;
      RETURN;
    END

    SET @State = 1;
    SET @Message = 'Situación actualizada correctamente';
    SET @CodeError = 0;
  END TRY
  BEGIN CATCH
    SET @State = 1;
    SET @Message = ERROR_MESSAGE();
    SET @CodeError = ERROR_NUMBER();
  END CATCH
END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdatePeriodoVacacional]
FECHA: 24-09-2025
AUTOR: Freddy Luna Almendras
OBJETIVO: Actualizar datos de control vacaciones

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            -
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdatePeriodoVacacional]
    @ID INT --PERIODO_ID
    ,
    @FECHAINICIO DATE = NULL
    ,
    @FECHAFIN DATE = NULL
    ,
    @DIASCONSUMIDOS INT = NULL
    ,
    @USER INT
    ,
    @State INT OUTPUT
    ,
    @Message VARCHAR(255) OUTPUT
    ,
    @CodeError INT OUTPUT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @CONTROL_ID INT
    DECLARE @diasConsumidosOld INT
    DECLARE @diasConsumidosActual INT
    DECLARE @diasConsumidosAntesActualizar INT
    DECLARE @DiasDisponibles INT
    DECLARE @AffectedRows INT
    DECLARE @fechaInicioActual DATE
    DECLARE @fechaFinActual DATE
    DECLARE @fechaInicioValidar DATE
    DECLARE @fechaFinValidar DATE

    BEGIN TRY
        -- VALIDACIONES DE ENTRADA
        IF @ID IS NULL
        BEGIN
        SET @State = -1
        SET @Message = 'El ID del período vacacional es requerido'
        RETURN
    END

        IF @USER IS NULL
        BEGIN
        SET @State = -1
        SET @Message = 'El usuario es requerido'
        RETURN
    END

        -- Obtener datos del período vacacional
        SELECT @CONTROL_ID = controlVacacionalId_fk,
        @diasConsumidosOld = nDiasConsumidos,
        @fechaInicioActual = fechaInicio,
        @fechaFinActual = fechaFin
    FROM PeriodoVacacional
    WHERE id = @ID AND bEliminado = 0

        -- Validar que el período existe
        IF @CONTROL_ID IS NULL
        BEGIN
        SET @State = -1
        SET @Message = 'El período vacacional no existe o fue eliminado'
        RETURN
    END

        -- Obtener datos actuales
        SELECT @diasConsumidosActual = nDiasTomados,
        @DiasDisponibles = nDiasDisponibles
    FROM ControlVacaciones
    WHERE id = @CONTROL_ID

        -- Validar fechas si se proporcionan
        IF @FECHAINICIO IS NOT NULL AND @FECHAFIN IS NOT NULL
        BEGIN
        IF @FECHAINICIO >= @FECHAFIN
            BEGIN
            SET @State = -1
            SET @Message = 'La fecha de inicio debe ser menor a la fecha fin'
            RETURN
        END
    END

        -- Establecer fechas a validar (usar actuales si no se proporcionan nuevas)
        SET @fechaInicioValidar = COALESCE(@FECHAINICIO, @fechaInicioActual)
        SET @fechaFinValidar = COALESCE(@FECHAFIN, @fechaFinActual)

        -- Validar que no se sobrepongan con otros períodos del mismo control
        IF EXISTS (
            SELECT 1
    FROM PeriodoVacacional
    WHERE controlVacacionalId_fk = @CONTROL_ID
        AND id <> @ID
        AND bEliminado = 0
        AND @fechaInicioValidar <= fechaFin
        AND @fechaFinValidar >= fechaInicio
        )
        BEGIN
        SET @State = -1
        SET @Message = 'El período vacacional se sobrepone con otro período del mismo control'
        RETURN
    END

        -- Validar días consumidos
        IF @DIASCONSUMIDOS IS NOT NULL
        BEGIN
        IF @DIASCONSUMIDOS <= 0
            BEGIN
            SET @State = -1
            SET @Message = 'Los días consumidos deben ser mayores a cero'
            RETURN
        END

        -- Calcular días consumidos después de la actualización
        SET @diasConsumidosAntesActualizar = @diasConsumidosActual - @diasConsumidosOld + @DIASCONSUMIDOS

        -- Validar que no se excedan los días disponibles
        IF @diasConsumidosAntesActualizar > @DiasDisponibles
            BEGIN
            SET @State = -1
            SET @Message = 'Los días consumidos exceden los días disponibles'
            RETURN
        END
    END
        ELSE
        BEGIN
        SET @diasConsumidosAntesActualizar = @diasConsumidosActual - @diasConsumidosOld + @diasConsumidosOld
    END

        -- INICIAR TRANSACCIÓN
        BEGIN TRANSACTION

            -- Actualizar PeriodoVacacional
            UPDATE PeriodoVacacional 
            SET fechaInicio = COALESCE(@FECHAINICIO, fechaInicio),
                fechaFin = COALESCE(@FECHAFIN, fechaFin),
                nDiasConsumidos = COALESCE(@DIASCONSUMIDOS, nDiasConsumidos),
                nUpdatedBy = @USER,
                tUpdateAt = GETDATE()
            WHERE id = @ID AND bEliminado = 0

            SET @AffectedRows = @@ROWCOUNT

            IF @AffectedRows = 0
            BEGIN
        ROLLBACK TRANSACTION
        SET @State = -1
        SET @Message = 'Fallo en la actualización del período vacacional'
        RETURN
    END

            -- Actualizar ControlVacaciones
            UPDATE ControlVacaciones 
            SET nDiasTomados = @diasConsumidosAntesActualizar
            WHERE id = @CONTROL_ID

            IF @@ROWCOUNT = 0
            BEGIN
        ROLLBACK TRANSACTION
        SET @State = -1
        SET @Message = 'Fallo en la actualización del control vacacional'
        RETURN
    END

        COMMIT TRANSACTION

        SET @State = 0
        SET @Message = 'Actualización exitosa'
        SET @CodeError = 0

    END TRY
    BEGIN CATCH
        -- Deshacer transacción si está activa
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION

        SET @State = 1
        SET @Message = ERROR_MESSAGE()
        SET @CodeError = ERROR_NUMBER()
    END CATCH

END
GO
 
/*======================================================================================================
NOMBRE: [dbo].[usp_UpdatePermiso]
FECHA: 17-09-2025
AUTOR: Jesamine M. Ramon Yora
OBJETIVO: Permite realizar la actualización del permiso.


MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdatePermiso] 
    @ID INT
    , @ROLUSUARIOID INT
    , @MOTIVOID INT
    , @FECHA DATE
    , @HORASALIDA TIME = NULL
    , @HORARETORNOESTIMADO TIME = NULL
    , @HORARETORNOREAL TIME = NULL
    , @USER INT
    , @State INT OUTPUT
    , @Message VARCHAR(255) OUTPUT
    , @CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
                FROM Permiso
                WHERE id = @ID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 2;
            SET @Message = 'El permiso no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM RolUsuario
                WHERE id = @ROLUSUARIOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 3;
            SET @Message = 'El rol de usuario no existe o fue eliminado.';

            RETURN;
        END;

        IF NOT EXISTS (
                SELECT 1
                FROM Motivo
                WHERE id = @MOTIVOID
                    AND bEliminado = 0
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'El motivo no existe o fue eliminado.';

            RETURN;
        END;

        IF (
                @FECHA IS NULL
                OR @HORASALIDA IS NULL
                OR @HORARETORNOESTIMADO IS NULL
                OR @HORARETORNOREAL IS NULL
                )
        BEGIN
            SET @State = - 4;
            SET @Message = 'La fecha y horas no pueden ser nulas.';

            RETURN;
        END;

        IF (
                @HORASALIDA = '00:00'
                OR @HORARETORNOESTIMADO = '00:00'
                OR @HORARETORNOREAL = '00:00'
                )
        BEGIN
            SET @State = - 7;
            SET @Message = 'Las horas no pueden ser 00:00.';

            RETURN;
        END;

        UPDATE Permiso
        SET rolUsuarioId_fk = @ROLUSUARIOID
            , motivoId_fk = @MOTIVOID
            , tFecha = COALESCE(@FECHA, tFecha)
            , tHoraSalida = COALESCE(@HORASALIDA, tHoraSalida)
            , tHoraRetornoEstimado = COALESCE(@HORARETORNOESTIMADO, tHoraRetornoEstimado)
            , tHoraRetornoReal = COALESCE(@HORARETORNOREAL, tHoraRetornoReal)
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
            AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
            SET @State = 0;
            SET @Message = 'Actualización exitosa.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización.';
        END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateRol]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar un rol

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateRol]
    @ROL_ID INT,
    @TITULO VARCHAR(100),
    @DESCRIPCION VARCHAR(MAX),
    @SUPERVISION BIT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT

    BEGIN TRY  
        IF NOT EXISTS ( SELECT 1 FROM Rol WHERE id = @ROL_ID AND bEliminado = 0 )
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

        SET @TITULO = LTRIM(RTRIM(@TITULO));

        IF @TITULO = ''
        BEGIN
            SET @State = -1;
            SET @Message = 'El título no puede estar vacío.';
            SET @CodeError = -1;
            RETURN;
        END

        IF EXISTS ( SELECT 1 FROM Rol WHERE cTitulo COLLATE Latin1_General_CI_AS = @TITULO COLLATE Latin1_General_CI_AS AND (@ROL_ID IS NULL OR id <> @ROL_ID) and bEliminado = 0)
        BEGIN
            SET @State = 1;
            SET @Message = 'El titulo de Rol ya existe. No se puede duplicar.';
            SET @CodeError = 0;
            RETURN;
        END

        UPDATE Rol SET
            cTitulo = COALESCE(@TITULO, cTitulo),
            cDescripcion = COALESCE(@DESCRIPCION, cDescripcion),
            bSupervision = COALESCE(@SUPERVISION , bSupervision)
        WHERE id = @ROL_ID

        SET @AffectedRows = @@ROWCOUNT;
            
        IF (@AffectedRows > 0)
         BEGIN
            SET @State = 0;
            SET @Message = 'Rol actualizada correctamente.';
        END
        ELSE
        BEGIN
            SET @State = - 1;
            SET @Message = 'Fallo en la actualización';
        END
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateRolControl]
FECHA: 24-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar control de Rol en la tabla [RolControl]

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateRolControl]
    @ID INT,
    @CONTROL_ID INT = NULL,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Validar existencia
        IF NOT EXISTS (SELECT 1 FROM  RolControl WHERE Id = @ID AND bEliminado = 0)
        BEGIN
            SET @State = -1;
            SET @Message = 'El registro de RolControl no existe o está eliminado.';
            SET @CodeError = -1;
            ROLLBACK TRAN;
            RETURN;
        END
        
        UPDATE  RolControl
        SET 
            controlId_fk = COALESCE(@CONTROL_ID, controlId_fk),
            nUpdatedBy  = @USER,        
            tUpdatedAt  = GETDATE()     
        WHERE Id = @ID;

        SET @State = -1;
        SET @Message = 'RolControl actualizado correctamente.';
        SET @CodeError = -1;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

CREATE   PROCEDURE usp_UpdateSyncUsuarioPersona
    @IDUSUARIO INT,
    @USUARIO VARCHAR(255),
    @NOMBRE VARCHAR(255),
    @APELLIDO VARCHAR(255),
    @DNI VARCHAR(20),
    @TIPO CHAR(2),
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT,XACT_ABORT ON;

    BEGIN TRY
    IF NOT EXISTS(SELECT 1
    FROM Sync_UsuarioPersona
    WHERE id = @IDUSUARIO)
    BEGIN
        SET @State = -1;
        SET @Message = 'El usuario no existe';
        SET @CodeError = -1;
        RETURN;
    END

    UPDATE Sync_UsuarioPersona
    SET cUsuario=@USUARIO, cNombre = @NOMBRE, cApellido = @APELLIDO, cTipo = @TIPO, cDni = @DNI
    WHERE id = @IDUSUARIO

    SET @State = 1;
    SET @Message = 'Usuario actualizado correctamente';
    SET @CodeError = 0;
    END TRY
    BEGIN CATCH    
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateTurnoExtendido]
FECHA: 17/10/2025
AUTOR: Gabriel Vasquez Uscuvilca
OBJETIVO: Permite la actualización de turnos extendidos.

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateTurnoExtendido]
    @ID INT,
    @HORA_INICIO TIME = NULL,
    @HORA_FIN TIME = NULL,
    @HORARIO_DIA_ID INT = null,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE TurnoExtendido
        SET 
            horaInicio = COALESCE(@HORA_INICIO, horaInicio),
            horaFin = COALESCE(@HORA_FIN, horaFin),
            horarioDiasId_fk = COALESCE(@HORARIO_DIA_ID, horarioDiasId_fk),
            nUpdatedBy = @USER,
            tUpdatedAt = GETDATE()
        WHERE 
            ID = @ID;

        IF @@ROWCOUNT = 0
        BEGIN
        SET @State = -1;
        SET @Message = 'No se encontró el turno extendido con el ID proporcionado.';
        SET @CodeError = 404;
        ROLLBACK TRANSACTION;
        RETURN;
    END;
          IF EXISTS (
            SELECT 1
    FROM TurnoRegular TR_Entrada
    CROSS JOIN TurnoRegular TR_Salida
    WHERE TR_Entrada.horarioDiasId_fk = @HORARIO_DIA_ID AND TR_Entrada.bEliminado = 0
        AND TR_Entrada.bTipo = 0
        AND TR_Salida.bTipo = 1
        AND TR_Entrada.horarioDiasId_fk =  TR_Salida.horarioDiasId_fk
        AND ((
              @HORA_INICIO < TR_Salida.horaInicio
        AND @HORA_FIN > TR_Entrada.horaInicio
            ))
        )
        BEGIN
        SELECT @State = -7, @Message = 'El rango de horas coincide con un turno regular ya existente.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;
        IF EXISTS (
                SELECT 1
    FROM TurnoExtendido
    WHERE horarioDiasId_fk = @HORARIO_DIA_ID
        AND horaInicio = @HORA_INICIO
        AND horaFin = @HORA_FIN
        AND bEliminado = 0
        AND ID <> @ID 
                )
        BEGIN
        SET @State = -6;
        SET @Message = 'Ya existe un turno con la misma horaInicio y horaFin para este mismo horario.';
        ROLLBACK TRANSACTION;
        RETURN;
    END;

        
        SET @State = 1;
        SET @Message = 'Turno extendido actualizado correctamente.';
        SET @CodeError = 0;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateTurnoRegular]
FECHA: 17-09-2025
AUTOR: Jesamine R. Yora
OBJETIVO: Permite actualizar un turno regular existente

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateTurnoRegular] 
    @ID INT
    ,@HORARIODIASID INT = NULL
    ,@ORDEN INT = NULL
    ,@HORAINICIO TIME = NULL
    ,@TIPO BIT
    ,@USER INT
    ,@State INT OUTPUT
    ,@Message VARCHAR(255) OUTPUT
    ,@CodeError INT OUTPUT
AS
BEGIN
    BEGIN TRY
        IF NOT EXISTS (
                SELECT 1
    FROM TurnoRegular
    WHERE id = @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 2;
        SET @Message = 'El turno no existe o está eliminado.';

        RETURN;
    END;

        IF @HORAINICIO IS NULL
        OR @HORAINICIO = '00:00:00'
        BEGIN
        SET @State = - 4;
        SET @Message = 'Especifique una horaInicio valida.';

        RETURN;
    END;

        IF NOT EXISTS (
                SELECT 1
    FROM HorarioDias
    WHERE id = @HORARIODIASID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 5;
        SET @Message = 'El horarioDias no existe o esta eliminado.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM HorarioDias
    WHERE id = @HORARIODIASID
        AND bLibre = 1
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 6;
        SET @Message = 'No se pueden registrar turnos, el dia es libre.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM TurnoRegular
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND orden = @ORDEN
        AND id <> @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 7;
        SET @Message = 'Ya existe un turno con este orden en el horario.';

        RETURN;
    END;

        IF EXISTS (
                SELECT 1
    FROM TurnoRegular
    WHERE horarioDiasId_fk = @HORARIODIASID
        AND horaInicio = @HORAINICIO
        AND id <> @ID
        AND bEliminado = 0
                )
        BEGIN
        SET @State = - 8;
        SET @Message = 'Ya existe un turno con la misma hora en este horario.';

        RETURN;
    END;
           IF EXISTS (
            SELECT 1
    FROM TurnoExtendido
        WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0
            AND (@HORAINICIO <= horaFin AND @HORAINICIO >= horaInicio)
            ) 
            BEGIN
            SELECT @State = -8, @Message = 'El rango de horas coincide con un turno Extendido ya existente.';
            RETURN;
        END;
            
    --     IF EXISTS (
    --         SELECT 1 
    --         FROM TurnoRegular 
    --         WHERE horarioDiasId_fk = @HORARIODIASID AND bEliminado = 0 
    --             AND (@HORAINICIO <= horaInicio)
                  
    --     )
    --     BEGIN
    --     SELECT @State = -8, @Message = 'La hora ingresada se superpone con otro turno.';
    --     RETURN;
    -- END;

        UPDATE TurnoRegular
        SET horarioDiasId_fk = COALESCE(@HORARIODIASID, horarioDiasId_fk)
            , horaInicio = COALESCE(@HORAINICIO, horaInicio)
            , bTipo = @TIPO
            , nUpdatedBy = @USER
            , tUpdatedAt = GETDATE()
        WHERE id = @ID
        AND bEliminado = 0;

        IF (@@ROWCOUNT > 0)
        BEGIN
        SET @State = 0;
        SET @Message = 'Actualización exitosa.';
    END
        ELSE
        BEGIN
        SET @State = - 1;
        SET @Message = 'No se encontró el registro o ya está eliminado.';
    END
    END TRY

    BEGIN CATCH
        SET @State = 1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateUnidad]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Actualizar una unidad

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateUnidad]
    @UNIDAD_ID INT,
    @HORA_ESTANDAR INT,
    @HORA_TOTAL INT,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR(255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    DECLARE @AffectedRows INT

    BEGIN TRY
        
        IF NOT EXISTS ( SELECT 1 FROM Unidad WHERE id = @UNIDAD_ID AND bEliminado = 0 )
                BEGIN
            SET @State = -1;
            SET @Message = 'El registro no existe o ya ha sido eliminado.';
            SET @CodeError = -1;
            RETURN;
        END

         
        IF @HORA_ESTANDAR <= 0
        BEGIN
            SET @State = -1;
            SET @Message = 'Debe registrar un valor válido para hora estándar.';
            SET @CodeError = -1;
            RETURN;
        END
        
        IF  @HORA_TOTAL <= 0
        BEGIN
            SET @State = -1;
            SET @Message = 'Debe registrar un valor válido para hora total.';
            SET @CodeError = -1;
            RETURN;
        END


        UPDATE Unidad SET
            horaEstandar = COALESCE(@HORA_ESTANDAR, horaEstandar),
            horaTotal = COALESCE(@HORA_TOTAL, horaTotal)
        WHERE id = @UNIDAD_ID

        SET @AffectedRows = @@ROWCOUNT;
            
        IF (@AffectedRows > 0)
            BEGIN
                SET @State = 0;
                SET @Message = 'Unidad actualizada correctamente.';
            END
        ELSE
            BEGIN
                SET @State = - 1;
                SET @Message = 'Fallo en la actualización';
            END
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH

END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateVigenciaIndividual]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Update vigencias para un día de un horario específico

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateVigenciaIndividual]
    @HORARIO_DIA_ID_OLD INT,
    @FECHA_FIN_NEW DATE,
    @FECHA_INICIO_NEW DATE,
    @USER INT,

    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        -- Validar que exista el registro original
    IF NOT EXISTS (
            SELECT 1
    FROM Vigencia
    WHERE horarioDiasId_fk = @HORARIO_DIA_ID_OLD
        AND bEliminado = 0
        )
        BEGIN
        SET @State = -1;
        SET @Message = 'La vigencia original no existe o ya fue eliminada.';
        SET @CodeError = -1;
        RETURN;
    END;

    
        -- Actualizar
        UPDATE Vigencia
        SET 
            tFechaInicio = @FECHA_INICIO_NEW,
            tFechaFin = @FECHA_FIN_NEW
        WHERE horarioDiasId_fk = @HORARIO_DIA_ID_OLD
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = -1;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

/*======================================================================================================
NOMBRE: [dbo].[usp_UpdateVigenciasGlobal]
FECHA: 17-09-2025
AUTOR: Gabriel Vásquez Uscuvilca
OBJETIVO: Update vigencias para un día de un horario específico

MODIFICACIONES:
NRO  FECHA       USUARIO    MODIFICACION
 -     -            -            - 
======================================================================================================*/
CREATE   PROCEDURE [dbo].[usp_UpdateVigenciasGlobal]
    @ID INT,
    @HORARIO_ID INT,
    @FECHA_INICIO DATE,
    @FECHA_FIN DATE,
    @USER INT,
    @State INT OUTPUT,
    @Message VARCHAR (255) OUTPUT,
    @CodeError INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (SELECT 1
    FROM Horario
    WHERE id = @HORARIO_ID AND bEliminado = 0)
        BEGIN
        SET @State = -1;
        SET @Message = 'El horario no existe o está eliminado.';
        SET @CodeError = -1;
        RETURN;
    END;
        IF @FECHA_INICIO IS NULL OR @FECHA_FIN IS NULL
        BEGIN
        SET @State = -1;
        SET @Message = 'Las fechas de inicio y fin son obligatorias.';
        SET @CodeError = -1;
        RETURN;
    END;

        IF @FECHA_INICIO > @FECHA_FIN
        BEGIN
        SET @State = -1;
        SET @Message = 'La fecha de inicio no puede ser mayor que la fecha fin.';
        SET @CodeError = -1;
        RETURN;
    END;
        IF EXISTS(SELECT 1
    FROM dbo.Vigencia
    WHERE tFechaInicio = @FECHA_INICIO
        AND tFechaFin = @FECHA_FIN
        AND horarioDiasId_fk = @HORARIO_ID
        AND bEliminado = 0
        AND id <> @Id )
            BEGIN
        SET @State = -1;
        SET @Message = 'El rango de fechas ya registrado.';
        SET @CodeError = -1;
        RETURN;
    END;

        UPDATE Vigencia
        SET  tFechaInicio = @FECHA_INICIO,
             tFechaFin = @FECHA_FIN,
             nUpdatedBy = @USER,
             tUpdatedAt = GETDATE(),
             horarioDiasId_fk = COALESCE(@HORARIO_ID, horarioDiasId_fk)
        WHERE id = @ID
        AND bEliminado = 0;

        SET @State = 1;
        SET @Message = 'Vigencias actualizada correctamente.';
        SET @CodeError = 0;
    END TRY
    BEGIN CATCH
        SET @State = 0;
        SET @Message = ERROR_MESSAGE();
        SET @CodeError = ERROR_NUMBER();
    END CATCH
END
GO

CREATE   PROCEDURE [dbo].[usp_UsuarioByRolId]
  @ROL_ID INT

AS
BEGIN
    SELECT 
        U.id AS usuarioId,
        U.cUsuario AS usuario,
        U.cDni,
        U.cNombre,
        U.cApellido,
        RU.id AS rolUsuarioId,
        RU.rolId_fk AS rolId,
        R.cTitulo AS rol
    FROM Sync_UsuarioPersona AS U
        INNER JOIN RolUsuario AS RU ON U.id = RU.usuarioId_fk
        INNER JOIN Rol AS R ON RU.rolId_fk = R.id
    WHERE RU.rolId_fk = @ROL_ID
        AND RU.bEliminado = 0
    ORDER BY U.cUsuario ASC
END
GO