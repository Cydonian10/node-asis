import sql from 'mssql';
import { connectToDb } from '@src/config/db-sqlserver.js';
import {
  executeCreate,
  requireCreatedId,
  runTransaction,
  SPOutput,
} from '@src/util/sqlServerUtil.js';
import {
  ErrorUtil,
  handleOperationResult,
  handleOperationResultCreate,
} from '@src/util/handleOperationResult.js';
import {
  OperationResult,
  OperationResultCreate,
} from '@src/common/types/operation-result.js';
import { Horario } from './dto/horario.dto.js';
import { HorarioDetalle } from './dto/horario-detalle.dto.js';
import { UsuarioHorario } from './dto/usuario-horario.dto.js';
import { CrearHorarioDto } from './dto/crear-horario.dto.js';
import { ActualizarHorarioDto } from './dto/actualizar-horario.dto.js';
import { CrearDiaDto } from './dto/crear-dia.dto.js';
import { ActualizarDiaDto } from './dto/actualizar-dia.dto.js';
import { CrearTurnoDto } from './dto/crear-turno.dto.js';
import { ActualizarTurnoDto } from './dto/actualizar-turno.dto.js';
import { CrearDiaConectadoDto } from './dto/crear-dia-conectado.dto.js';
import { TurnoDiaConectado } from './dto/turno-dia-conectado.dto.js';
import { HorarioMovimientos } from './dto/horario-movimientos.dto.js';
import { mapHorarioDetalle } from './mapper/horario.mapper.js';
import logger from '@src/common/logger.js';
import { LuxonAdapter } from '@src/common/plugins/luxon.js';

export function normalizeSqlTime(
  value: string | null | undefined,
): Date | null {
  if (value === null || value === undefined) return null;

  const match = /^(\d{2}):(\d{2})(?::(\d{2}))?$/.exec(value);
  if (!match) {
    throw new Error('La hora debe tener formato HH:mm o HH:mm:ss');
  }

  const hours = Number(match[1]);
  const minutes = Number(match[2]);
  const seconds = Number(match[3] ?? '00');
  if (hours > 23 || minutes > 59 || seconds > 59) {
    throw new Error('La hora no es válida');
  }

  return new Date(Date.UTC(1970, 0, 1, hours, minutes, seconds, 0));
}

const getAll = async (
  areaId?: number,
  busqueda?: string,
): Promise<Horario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('areaId', sql.Int, areaId ?? null);
    request.input('busqueda', sql.VarChar(255), busqueda ?? null);

    const result = await request.execute<Horario>('usp_GetHorarios');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const getById = async (id: number): Promise<HorarioDetalle | null> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    return await ejecutarDetalle(request, id);
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const ejecutarDetalle = async (
  request: sql.Request,
  id: number,
): Promise<HorarioDetalle | null> => {
  request.input('HorarioId', sql.Int, id);
  const result = await request.execute('usp_GetHorarioDetalle');
  const recordsets = result.recordsets as unknown as Array<Array<unknown>>;
  return mapHorarioDetalle(recordsets);
};

const getMovimientos = async (horarioId: number): Promise<HorarioMovimientos> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();
    return await ejecutarMovimientos(request, horarioId);
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const ejecutarMovimientos = async (
  request: sql.Request,
  horarioId: number,
): Promise<HorarioMovimientos> => {
  request.input('HorarioId', sql.Int, horarioId);
  const result = await request.execute('usp_GetHorarioMovimientos');
  const recordsets = result.recordsets as unknown as Array<Array<unknown>>;
  const turnosBloqueados = (recordsets[0] ?? []).map((row) =>
    +((row as { turnoId: number }).turnoId),
  );
  const estado =
    (recordsets[1] ?? [])[0] as Record<string, number> | undefined ?? {};
  const estructuraBloqueada = [
    estado.tieneAsistencias,
    estado.tieneTurnosModificados,
    estado.tieneLicencias,
    estado.tienePermisos,
    estado.tieneVacaciones,
    estado.tieneJustificaciones,
  ].some((value) => !!value);
  return {
    turnosBloqueados,
    estructuraBloqueada,
    tieneAsistencias: !!estado.tieneAsistencias,
    tieneTurnosModificados: !!estado.tieneTurnosModificados,
    tieneLicencias: !!estado.tieneLicencias,
    tienePermisos: !!estado.tienePermisos,
    tieneVacaciones: !!estado.tieneVacaciones,
    tieneJustificaciones: !!estado.tieneJustificaciones,
  };
};

const normalizarHora = (value: string | null | undefined): string => {
  if (!value) return '';
  const match = /^(\d{2}):(\d{2})/.exec(value);
  return match ? `${match[1]}:${match[2]}` : value;
};

const getUsuarios = async (horarioId: number): Promise<UsuarioHorario[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioId', sql.Int, horarioId);

    const result = await request.execute<UsuarioHorario>(
      'usp_GetHorarioUsuarios',
    );
    return (result.recordset ?? []).map((row) => ({
      ...row,
      fechaInicio: LuxonAdapter.fromSqlServerDate(row.fechaInicio),
      fechaFin: LuxonAdapter.fromSqlServerDate(row.fechaFin),
    }));
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const crearDiasHorario = async (
  tx: sql.Transaction,
  horarioId: number,
  vigenciaGrupoId: number | null,
  dias: CrearHorarioDto['dias'],
  userId: number,
): Promise<void> => {
  for (const dia of dias ?? []) {
    const diaOutput = await executeCreate(tx, 'usp_CreateHorarioDia', (req) => {
      req.input('HorarioId', sql.Int, horarioId);
      req.input('DiaId', sql.Int, dia.diaId);
      req.input('VigenciaGrupoId', sql.Int, vigenciaGrupoId);
      req.input('Orden', sql.Int, dia.orden ?? 0);
      req.input('USER', sql.Int, userId);
      req.output('Id', sql.Int);
    });
    const horarioDiaId = requireCreatedId(diaOutput, 'usp_CreateHorarioDia');

    for (const turno of dia.turnos) {
      const turnoOutput = await executeCreate(tx, 'usp_CreateTurno', (req) => {
        req.input('HorarioDiaId', sql.Int, horarioDiaId);
        req.input(
          'HoraInicio',
          sql.Time,
          normalizeSqlTime(turno.horaInicio),
        );
        req.input('HoraFin', sql.Time, normalizeSqlTime(turno.horaFin));
        req.input('Extendido', sql.Bit, turno.extendido ?? false);
        req.input('USER', sql.Int, userId);
        req.output('Id', sql.Int);
      });
      const turnoId = requireCreatedId(turnoOutput, 'usp_CreateTurno');

      if (turno.diaSalidaId) {
        await executeCreate(tx, 'usp_CreateTurnoDiaConectado', (req) => {
          req.input('TurnoId', sql.Int, turnoId);
          req.input('DiaId', sql.Int, turno.diaSalidaId);
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        });
      }
    }
  }
};

const crearEstructura = async (
  tx: sql.Transaction,
  horarioId: number,
  data: {
    rotativo?: boolean;
    dias?: CrearHorarioDto['dias'];
    grupos?: CrearHorarioDto['grupos'];
  },
  userId: number,
): Promise<void> => {
  if (data.rotativo) {
    for (const [gi, grupo] of (data.grupos ?? []).entries()) {
      const grupoOutput = await executeCreate(
        tx,
        'usp_CreateVigenciaGrupo',
        (req) => {
          req.input('HorarioId', sql.Int, horarioId);
          req.input(
            'FechaInicio',
            sql.Date,
            LuxonAdapter.toSqlServerDate(grupo.fechaInicio),
          );
          req.input(
            'FechaFin',
            sql.Date,
            LuxonAdapter.toSqlServerDate(grupo.fechaFin),
          );
          req.input('Orden', sql.Int, gi + 1);
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        },
      );
      const vigenciaGrupoId = requireCreatedId(
        grupoOutput,
        'usp_CreateVigenciaGrupo',
      );
      await crearDiasHorario(tx, horarioId, vigenciaGrupoId, grupo.dias, userId);
    }
  } else {
    await crearDiasHorario(tx, horarioId, null, data.dias ?? [], userId);
  }
};

const sincronizarDiasYTurnos = async (
  tx: sql.Transaction,
  horarioId: number,
  vigenciaGrupoId: number | null,
  diasActuales: HorarioDetalle['dias'],
  diasPropuestos: NonNullable<ActualizarHorarioDto['dias']>,
  userId: number,
): Promise<void> => {
  const diasActualesMap = new Map(
    diasActuales.map((d) => [d.horarioDiaId, d]),
  );
  const propuestosIds = new Set(
    diasPropuestos
      .filter((d) => d.horarioDiaId)
      .map((d) => d.horarioDiaId as number),
  );

  for (const d of diasActuales) {
    if (!propuestosIds.has(d.horarioDiaId)) {
      await executeCreate(tx, 'usp_DeleteHorarioDia', (req) => {
        req.input('ID', sql.Int, d.horarioDiaId);
        req.input('USER', sql.Int, userId);
      });
    }
  }

  for (const diaPropuesto of diasPropuestos) {
    let horarioDiaId = diaPropuesto.horarioDiaId;
    if (horarioDiaId) {
      await executeCreate(tx, 'usp_UpdateHorarioDia', (req) => {
        req.input('ID', sql.Int, horarioDiaId);
        req.input('Orden', sql.Int, diaPropuesto.orden ?? 0);
        req.input('USER', sql.Int, userId);
      });
    } else {
      const diaOutput = await executeCreate(tx, 'usp_CreateHorarioDia', (req) => {
        req.input('HorarioId', sql.Int, horarioId);
        req.input('DiaId', sql.Int, diaPropuesto.diaId);
        req.input('VigenciaGrupoId', sql.Int, vigenciaGrupoId);
        req.input('Orden', sql.Int, diaPropuesto.orden ?? 0);
        req.input('USER', sql.Int, userId);
        req.output('Id', sql.Int);
      });
      horarioDiaId = requireCreatedId(diaOutput, 'usp_CreateHorarioDia');
    }

    const diaActual = diasActualesMap.get(horarioDiaId);
    await sincronizarTurnos(
      tx,
      horarioDiaId,
      diaActual?.turnos ?? [],
      diaPropuesto.turnos,
      userId,
    );
  }
};

const sincronizarTurnos = async (
  tx: sql.Transaction,
  horarioDiaId: number,
  turnosActuales: HorarioDetalle['dias'][number]['turnos'],
  turnosPropuestos: {
    turnoId?: number;
    horaInicio: string;
    horaFin: string;
    extendido?: boolean;
    diaSalidaId?: number | null;
  }[],
  userId: number,
): Promise<void> => {
  const turnosActualesMap = new Map(turnosActuales.map((t) => [t.turnoId, t]));
  const propuestosIds = new Set(
    turnosPropuestos
      .filter((t) => t.turnoId)
      .map((t) => t.turnoId as number),
  );

  for (const t of turnosActuales) {
    if (!propuestosIds.has(t.turnoId)) {
      await executeCreate(tx, 'usp_DeleteTurno', (req) => {
        req.input('ID', sql.Int, t.turnoId);
        req.input('USER', sql.Int, userId);
      });
    }
  }

  for (const turnoPropuesto of turnosPropuestos) {
    const turnoId = turnoPropuesto.turnoId;
    if (turnoId) {
      const turnoActual = turnosActualesMap.get(turnoId);
      const cambiaHora =
        !turnoActual ||
        normalizarHora(turnoActual.horaInicio) !==
          normalizarHora(turnoPropuesto.horaInicio) ||
        normalizarHora(turnoActual.horaFin) !==
          normalizarHora(turnoPropuesto.horaFin) ||
        turnoActual.extendido !== !!turnoPropuesto.extendido;
      if (cambiaHora) {
        await executeCreate(tx, 'usp_UpdateTurno', (req) => {
          req.input('ID', sql.Int, turnoId);
          req.input(
            'HoraInicio',
            sql.Time,
            normalizeSqlTime(turnoPropuesto.horaInicio),
          );
          req.input(
            'HoraFin',
            sql.Time,
            normalizeSqlTime(turnoPropuesto.horaFin),
          );
          req.input('Extendido', sql.Bit, turnoPropuesto.extendido ?? false);
          req.input('USER', sql.Int, userId);
        });
      }
      await sincronizarDiaSalida(
        tx,
        turnoId,
        turnoActual?.diaSalida?.diaId ?? null,
        turnoPropuesto.diaSalidaId ?? null,
        userId,
      );
    } else {
      const turnoOutput = await executeCreate(tx, 'usp_CreateTurno', (req) => {
        req.input('HorarioDiaId', sql.Int, horarioDiaId);
        req.input(
          'HoraInicio',
          sql.Time,
          normalizeSqlTime(turnoPropuesto.horaInicio),
        );
        req.input(
          'HoraFin',
          sql.Time,
          normalizeSqlTime(turnoPropuesto.horaFin),
        );
        req.input('Extendido', sql.Bit, turnoPropuesto.extendido ?? false);
        req.input('USER', sql.Int, userId);
        req.output('Id', sql.Int);
      });
      const nuevoTurnoId = requireCreatedId(turnoOutput, 'usp_CreateTurno');
      if (turnoPropuesto.diaSalidaId) {
        await executeCreate(tx, 'usp_CreateTurnoDiaConectado', (req) => {
          req.input('TurnoId', sql.Int, nuevoTurnoId);
          req.input('DiaId', sql.Int, turnoPropuesto.diaSalidaId);
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        });
      }
    }
  }
};

const sincronizarDiaSalida = async (
  tx: sql.Transaction,
  turnoId: number,
  salidaActual: number | null,
  salidaNueva: number | null,
  userId: number,
): Promise<void> => {
  if (salidaActual === salidaNueva) return;

  if (salidaActual !== null) {
    const result = await new sql.Request(tx)
      .input('TurnoId', sql.Int, turnoId)
      .query(
        'SELECT TOP 1 SalidaTurnoDiaId AS id FROM SalidaTurnoDia WHERE TurnoId = @TurnoId AND Eliminado = 0',
      );
    const row = result.recordset[0] as { id: number } | undefined;
    if (row) {
      await executeCreate(tx, 'usp_DeleteTurnoDiaConectado', (req) => {
        req.input('ID', sql.Int, row.id);
        req.input('USER', sql.Int, userId);
      });
    }
  }

  if (salidaNueva !== null) {
    await executeCreate(tx, 'usp_CreateTurnoDiaConectado', (req) => {
      req.input('TurnoId', sql.Int, turnoId);
      req.input('DiaId', sql.Int, salidaNueva);
      req.input('USER', sql.Int, userId);
      req.output('Id', sql.Int);
    });
  }
};

const hayCambioEstructural = (
  detalle: HorarioDetalle,
  data: ActualizarHorarioDto,
): boolean => {
  const rotativoPropuesto = data.rotativo ?? detalle.rotativo;
  if (rotativoPropuesto !== detalle.rotativo) {
    return true;
  }

  // Estructura actual
  const turnosActuales = new Map<
    number,
    {
      horaInicio: string;
      horaFin: string;
      extendido: boolean;
      diaSalidaId: number | null;
    }
  >();
  const diasActuales = new Map<number, number[]>();
  const gruposActuales = new Map<
    number,
    { fechaInicio: string | null; fechaFin: string | null }
  >();

  const cargarDiasActuales = (dias: HorarioDetalle['dias']) => {
    for (const d of dias) {
      diasActuales.set(d.horarioDiaId, d.turnos.map((t) => t.turnoId));
      for (const t of d.turnos) {
        turnosActuales.set(t.turnoId, {
          horaInicio: normalizarHora(t.horaInicio),
          horaFin: normalizarHora(t.horaFin),
          extendido: t.extendido,
          diaSalidaId: t.diaSalida?.diaId ?? null,
        });
      }
    }
  };

  if (detalle.rotativo) {
    for (const g of detalle.grupos) {
      gruposActuales.set(g.vigenciaGrupoId, {
        fechaInicio: g.fechaInicio,
        fechaFin: g.fechaFin,
      });
      cargarDiasActuales(g.dias);
    }
  } else {
    cargarDiasActuales(detalle.dias);
  }

  // Estructura propuesta
  const turnosPropuestos = new Map<
    number,
    {
      horaInicio: string;
      horaFin: string;
      extendido: boolean;
      diaSalidaId: number | null;
    }
  >();
  const diasPropuestos = new Set<number>();
  const gruposPropuestos = new Map<
    number,
    { fechaInicio: string; fechaFin: string | null }
  >();

  const registrarTurnosPropuestos = (
    dias: NonNullable<ActualizarHorarioDto['dias']>,
  ): boolean => {
    for (const d of dias) {
      if (!d.horarioDiaId) {
        return true;
      }
      diasPropuestos.add(d.horarioDiaId);
      for (const t of d.turnos) {
        if (!t.turnoId) {
          return true;
        }
        turnosPropuestos.set(t.turnoId, {
          horaInicio: normalizarHora(t.horaInicio),
          horaFin: normalizarHora(t.horaFin),
          extendido: !!t.extendido,
          diaSalidaId: t.diaSalidaId ?? null,
        });
      }
    }
    return false;
  };

  if (rotativoPropuesto) {
    for (const g of data.grupos ?? []) {
      if (!g.vigenciaGrupoId) {
        return true;
      }
      gruposPropuestos.set(g.vigenciaGrupoId, {
        fechaInicio: g.fechaInicio,
        fechaFin: g.fechaFin ?? null,
      });
      if (registrarTurnosPropuestos(g.dias)) {
        return true;
      }
    }
  } else if (registrarTurnosPropuestos(data.dias ?? [])) {
    return true;
  }

  // Comparar grupos
  if (gruposActuales.size !== gruposPropuestos.size) {
    return true;
  }
  for (const [id, pg] of gruposPropuestos) {
    const ag = gruposActuales.get(id);
    if (
      !ag ||
      (ag.fechaInicio ?? null) !== pg.fechaInicio ||
      (ag.fechaFin ?? null) !== pg.fechaFin
    ) {
      return true;
    }
  }

  // Comparar días
  if (diasActuales.size !== diasPropuestos.size) {
    return true;
  }
  for (const id of diasPropuestos) {
    if (!diasActuales.has(id)) {
      return true;
    }
  }

  // Comparar turnos
  if (turnosActuales.size !== turnosPropuestos.size) {
    return true;
  }
  for (const [id, pt] of turnosPropuestos) {
    const at = turnosActuales.get(id);
    if (
      !at ||
      at.horaInicio !== pt.horaInicio ||
      at.horaFin !== pt.horaFin ||
      at.extendido !== pt.extendido ||
      at.diaSalidaId !== pt.diaSalidaId
    ) {
      return true;
    }
  }

  return false;
};

const validarCambiosHorario = (
  detalle: HorarioDetalle,
  data: ActualizarHorarioDto,
  turnosBloqueados: Set<number>,
): string | null => {
  if (turnosBloqueados.size === 0) {
    return null;
  }
  if (hayCambioEstructural(detalle, data)) {
    return 'No se puede modificar la estructura del horario porque tiene turnos con movimientos (asistencias o turnos modificados). Solo puedes editar los datos generales (nombre, horas laborales y área).';
  }
  return null;
};

const sincronizarGrupos = async (
  tx: sql.Transaction,
  horarioId: number,
  gruposActuales: HorarioDetalle['grupos'],
  gruposPropuestos: NonNullable<ActualizarHorarioDto['grupos']>,
  userId: number,
): Promise<void> => {
  const gruposActualesMap = new Map(
    gruposActuales.map((g) => [g.vigenciaGrupoId, g]),
  );
  const propuestosIds = new Set(
    gruposPropuestos
      .filter((g) => g.vigenciaGrupoId)
      .map((g) => g.vigenciaGrupoId as number),
  );

  for (const g of gruposActuales) {
    if (!propuestosIds.has(g.vigenciaGrupoId)) {
      await executeCreate(tx, 'usp_DeleteVigenciaGrupo', (req) => {
        req.input('ID', sql.Int, g.vigenciaGrupoId);
        req.input('USER', sql.Int, userId);
      });
    }
  }

  for (const [gi, grupoPropuesto] of gruposPropuestos.entries()) {
    let vigenciaGrupoId = grupoPropuesto.vigenciaGrupoId;
    if (vigenciaGrupoId) {
      const grupoActual = gruposActualesMap.get(vigenciaGrupoId);
      await executeCreate(tx, 'usp_UpdateVigenciaGrupo', (req) => {
        req.input('ID', sql.Int, vigenciaGrupoId);
        req.input(
          'FechaInicio',
          sql.Date,
          LuxonAdapter.toSqlServerDate(grupoPropuesto.fechaInicio),
        );
        req.input(
          'FechaFin',
          sql.Date,
          LuxonAdapter.toSqlServerDate(grupoPropuesto.fechaFin),
        );
        req.input('Orden', sql.Int, gi + 1);
        req.input('USER', sql.Int, userId);
      });
      await sincronizarDiasYTurnos(
        tx,
        horarioId,
        vigenciaGrupoId,
        grupoActual?.dias ?? [],
        grupoPropuesto.dias,
        userId,
      );
    } else {
      const grupoOutput = await executeCreate(
        tx,
        'usp_CreateVigenciaGrupo',
        (req) => {
          req.input('HorarioId', sql.Int, horarioId);
          req.input(
            'FechaInicio',
            sql.Date,
            LuxonAdapter.toSqlServerDate(grupoPropuesto.fechaInicio),
          );
          req.input(
            'FechaFin',
            sql.Date,
            LuxonAdapter.toSqlServerDate(grupoPropuesto.fechaFin),
          );
          req.input('Orden', sql.Int, gi + 1);
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        },
      );
      vigenciaGrupoId = requireCreatedId(
        grupoOutput,
        'usp_CreateVigenciaGrupo',
      );
      await sincronizarDiasYTurnos(
        tx,
        horarioId,
        vigenciaGrupoId,
        [],
        grupoPropuesto.dias,
        userId,
      );
    }
  }
};

const create = async (
  data: CrearHorarioDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    return await runTransaction(async (tx) => {
      const horarioOutput = await executeCreate(
        tx,
        'usp_CreateHorario',
        (req) => {
          req.input('Nombre', sql.VarChar(200), data.nombre);
          req.input('AreaId', sql.Int, data.areaId);
          req.input('Extendido', sql.Bit, data.extendido);
          req.input('Rotativo', sql.Bit, data.rotativo);
          req.input('Regular', sql.Bit, data.regular);
          req.input('HorasLaborales', sql.Int, data.horasLaborales);
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        },
      );

      const horarioId = requireCreatedId(horarioOutput, 'usp_CreateHorario');

      await crearEstructura(tx, horarioId, data, userId);

      if (data.usuarioIds && data.usuarioIds.length > 0) {
        const req = new sql.Request(tx);
        req.input('HorarioId', sql.Int, horarioId);
        const tvp = new sql.Table('IntListTableType');
        tvp.columns.add('Value', sql.Int);
        for (const id of data.usuarioIds) {
          tvp.rows.add(id);
        }
        req.input('UsuarioIds', sql.TVP, tvp);
        req.input(
          'FechaInicio',
          sql.Date,
          LuxonAdapter.toSqlServerDate(data.fechaInicio),
        );
        req.input(
          'FechaFin',
          sql.Date,
          LuxonAdapter.toSqlServerDate(data.fechaFin),
        );
        req.input('USER', sql.Int, userId);
        req.output('State', sql.Int);
        req.output('Message', sql.VarChar(255));
        req.output('CodeError', sql.Int);
        const res = await req.execute('usp_AsignarUsuariosHorario');
        const resOutput = res.output as unknown as SPOutput;
        if (resOutput.State !== 1) {
          logger.err(
            `SP usp_AsignarUsuariosHorario falló: ${resOutput.Message}`,
          );
          throw new Error(`${resOutput.Message}`);
        }
      }

      return {
        Id: horarioId,
        State: 1,
        Message: 'Horario creado correctamente',
        CodeError: 0,
      };
    });
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const update = async (
  id: number,
  data: ActualizarHorarioDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    return await runTransaction(async (tx) => {
      const detalle = await ejecutarDetalle(new sql.Request(tx), id);
      if (!detalle) {
        return { State: -1, Message: 'El horario no existe', CodeError: -1 };
      }

      const movimientos = await ejecutarMovimientos(new sql.Request(tx), id);
      const turnosBloqueados = new Set(movimientos.turnosBloqueados);
      const rotativoPropuesto = data.rotativo ?? detalle.rotativo;
      const tipoCambia =
        data.rotativo !== undefined && data.rotativo !== detalle.rotativo;

      if (data.dias || data.grupos) {
        const error = validarCambiosHorario(detalle, data, turnosBloqueados);
        if (error) {
          return { State: -1, Message: error, CodeError: -1 };
        }
      }

      const flatResult = await new sql.Request(tx)
        .input('ID', sql.Int, id)
        .input('Nombre', sql.VarChar(200), data.nombre ?? null)
        .input('AreaId', sql.Int, data.areaId ?? null)
        .input('Extendido', sql.Bit, data.extendido ?? null)
        .input('Rotativo', sql.Bit, data.rotativo ?? null)
        .input('Regular', sql.Bit, data.regular ?? null)
        .input('HorasLaborales', sql.Int, data.horasLaborales ?? null)
        .input('USER', sql.Int, userId)
        .output('State', sql.Int)
        .output('Message', sql.VarChar(255))
        .output('CodeError', sql.Int)
        .execute('usp_UpdateHorario');

      const flatOutput = flatResult.output as unknown as SPOutput;
      if (flatOutput.State !== 1) {
        return {
          State: -1,
          Message: flatOutput.Message,
          CodeError: flatOutput.CodeError ?? -1,
        };
      }

      if (data.dias || data.grupos) {
        if (tipoCambia) {
          if (detalle.rotativo) {
            for (const g of detalle.grupos) {
              await executeCreate(tx, 'usp_DeleteVigenciaGrupo', (req) => {
                req.input('ID', sql.Int, g.vigenciaGrupoId);
                req.input('USER', sql.Int, userId);
              });
            }
          } else {
            for (const d of detalle.dias) {
              await executeCreate(tx, 'usp_DeleteHorarioDia', (req) => {
                req.input('ID', sql.Int, d.horarioDiaId);
                req.input('USER', sql.Int, userId);
              });
            }
          }
          await crearEstructura(
            tx,
            id,
            {
              rotativo: rotativoPropuesto,
              dias: data.dias,
              grupos: data.grupos,
            },
            userId,
          );
        } else if (rotativoPropuesto) {
          await sincronizarGrupos(
            tx,
            id,
            detalle.grupos,
            data.grupos ?? [],
            userId,
          );
        } else {
          await sincronizarDiasYTurnos(
            tx,
            id,
            null,
            detalle.dias,
            data.dias ?? [],
            userId,
          );
        }
      }

      return {
        State: 1,
        Message: 'Horario actualizado correctamente',
        CodeError: 0,
      };
    });
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const remove = async (id: number, userId: number): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteHorario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const createDia = async (
  horarioId: number,
  data: CrearDiaDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    return await runTransaction(async (tx) => {
      const diaOutput = await executeCreate(
        tx,
        'usp_CreateHorarioDia',
        (req) => {
          req.input('HorarioId', sql.Int, horarioId);
          req.input('DiaId', sql.Int, data.diaId);
          req.input('VigenciaGrupoId', sql.Int, data.vigenciaGrupoId ?? null);
          req.input('Orden', sql.Int, data.orden ?? 0);
          req.input('USER', sql.Int, userId);
          req.output('Id', sql.Int);
        },
      );
      const horarioDiaId = requireCreatedId(diaOutput, 'usp_CreateHorarioDia');

      return {
        Id: horarioDiaId,
        State: 1,
        Message: 'Dia agregado al horario correctamente',
        CodeError: 0,
      };
    });
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const updateDia = async (
  id: number,
  data: ActualizarDiaDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('Orden', sql.Int, data.orden);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateHorarioDia');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const removeDia = async (
  id: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteHorarioDia');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const createTurno = async (
  horarioDiaId: number,
  data: CrearTurnoDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioDiaId', sql.Int, horarioDiaId);
    request.input('HoraInicio', sql.Time, normalizeSqlTime(data.horaInicio));
    request.input('HoraFin', sql.Time, normalizeSqlTime(data.horaFin));
    request.input('Extendido', sql.Bit, data.extendido);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_CreateTurno');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const updateTurno = async (
  id: number,
  data: ActualizarTurnoDto,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('HoraInicio', sql.Time, normalizeSqlTime(data.horaInicio));
    request.input('HoraFin', sql.Time, normalizeSqlTime(data.horaFin));
    request.input('Extendido', sql.Bit, data.extendido ?? null);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_UpdateTurno');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.update(error as string);
  }
};

const removeTurno = async (
  id: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteTurno');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const getTurnoDiaConectado = async (
  turnoId: number,
): Promise<TurnoDiaConectado[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('TurnoId', sql.Int, turnoId);

    const result = await request.execute<TurnoDiaConectado>(
      'usp_GetTurnoDiaConectado',
    );
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

const createTurnoDiaConectado = async (
  turnoId: number,
  data: CrearDiaConectadoDto,
  userId: number,
): Promise<OperationResultCreate> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('TurnoId', sql.Int, turnoId);
    request.input('DiaId', sql.Int, data.diaId);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('Id', sql.Int);
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_CreateTurnoDiaConectado');
    return handleOperationResultCreate(result.output as OperationResultCreate);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const removeTurnoDiaConectado = async (
  id: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('ID', sql.Int, id);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DeleteTurnoDiaConectado');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

const asignarUsuarios = async (
  horarioId: number,
  usuarioIds: number[],
  fechaInicio: string,
  fechaFin: string | null | undefined,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioId', sql.Int, horarioId);

    const tvp = new sql.Table('IntListTableType');
    tvp.columns.add('Value', sql.Int);
    for (const id of usuarioIds) {
      tvp.rows.add(id);
    }
    request.input('UsuarioIds', sql.TVP, tvp);
    request.input(
      'FechaInicio',
      sql.Date,
      LuxonAdapter.toSqlServerDate(fechaInicio),
    );
    request.input(
      'FechaFin',
      sql.Date,
      LuxonAdapter.toSqlServerDate(fechaFin),
    );

    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_AsignarUsuariosHorario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.add(error as string);
  }
};

const desasignarUsuario = async (
  horarioId: number,
  usuarioId: number,
  userId: number,
): Promise<OperationResult> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    request.input('HorarioId', sql.Int, horarioId);
    request.input('UsuarioId', sql.Int, usuarioId);
    request.input('USER', sql.Int, userId);

    request.output('State', sql.Int);
    request.output('Message', sql.VarChar(255));
    request.output('CodeError', sql.Int);

    const result = await request.execute('usp_DesasignarUsuarioHorario');
    return handleOperationResult(result.output as OperationResult);
  } catch (error) {
    return ErrorUtil.delete(error as string);
  }
};

export default {
  getAll,
  getById,
  getUsuarios,
  getMovimientos,
  create,
  update,
  remove,
  createDia,
  updateDia,
  removeDia,
  createTurno,
  updateTurno,
  removeTurno,
  getTurnoDiaConectado,
  createTurnoDiaConectado,
  removeTurnoDiaConectado,
  asignarUsuarios,
  desasignarUsuario,
};
