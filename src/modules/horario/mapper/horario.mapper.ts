import { HorarioDetalle } from '../dto/horario-detalle.dto.js';
import { LuxonAdapter } from '@src/common/plugins/luxon.js';

type DetalleRow = {
  horarioDiaId: number;
  diaId: number;
  diaNombre: string;
  orden: number;
  vigenciaGrupoId: number | null;
  turnoId: number | null;
  horaInicio: Date | string | null;
  horaFin: Date | string | null;
  extendido: boolean | null;
  salidaDiaId: number | null;
  salidaDiaNombre: string | null;
};

type GrupoRow = {
  vigenciaGrupoId: number;
  horarioId: number;
  fechaInicio: Date | string | null;
  fechaFin: Date | string | null;
  orden: number;
};

type HorarioRow = {
  horarioId: number;
  nombre: string;
  areaId: number;
  areaNombre: string | null;
  unidadId: number;
  extendido: boolean;
  rotativo: boolean;
  regular: boolean;
  horasLaborales: number;
};

/**
 * Convierte los resultsets planos del SP en el objeto anidado que consume la API.
 * El SP devuelve: horario (set 1), dias (set 2, referencia), dias con turnos (set 3) y
 * grupos de vigencia (set 4).
 */
export function mapHorarioDetalle(
  recordsets: Array<Array<unknown>>,
): HorarioDetalle | null {
  const horarios = recordsets[0] as HorarioRow[] | undefined;
  const filas = (recordsets[2] ?? []) as DetalleRow[];
  const gruposRows = (recordsets[3] ?? []) as GrupoRow[];
  const horario = horarios?.[0];

  if (!horario) return null;

  const diasMap = new Map<number, HorarioDetalle['dias'][number]>();

  for (const fila of filas) {
    let dia = diasMap.get(fila.horarioDiaId);
    if (!dia) {
      dia = {
        horarioDiaId: fila.horarioDiaId,
        diaId: fila.diaId,
        diaNombre: fila.diaNombre,
        orden: fila.orden,
        vigenciaGrupoId: fila.vigenciaGrupoId,
        turnos: [],
      };
      diasMap.set(fila.horarioDiaId, dia);
    }

    if (fila.turnoId !== null && fila.turnoId !== undefined) {
      dia.turnos.push({
        turnoId: fila.turnoId,
        horaInicio: LuxonAdapter.fromSqlServerTime(fila.horaInicio),
        horaFin: LuxonAdapter.fromSqlServerTime(fila.horaFin),
        extendido: !!fila.extendido,
        diaSalida:
          fila.salidaDiaId !== null && fila.salidaDiaId !== undefined
            ? {
                diaId: fila.salidaDiaId,
                diaNombre: fila.salidaDiaNombre ?? '',
              }
            : null,
      });
    }
  }

  const todosDias = Array.from(diasMap.values()).sort((a, b) => a.orden - b.orden);

  let grupos: HorarioDetalle['grupos'] = [];
  let dias: HorarioDetalle['dias'] = [];

  if (horario.rotativo) {
    const gruposMap = new Map<number, HorarioDetalle['grupos'][number]>();
    for (const g of gruposRows) {
      gruposMap.set(g.vigenciaGrupoId, {
        vigenciaGrupoId: g.vigenciaGrupoId,
        fechaInicio: LuxonAdapter.fromSqlServerDate(g.fechaInicio),
        fechaFin: LuxonAdapter.fromSqlServerDate(g.fechaFin),
        orden: g.orden,
        dias: [],
      });
    }
    for (const dia of todosDias) {
      const grupo = dia.vigenciaGrupoId
        ? gruposMap.get(dia.vigenciaGrupoId)
        : undefined;
      if (grupo) {
        grupo.dias.push(dia);
      }
    }
    grupos = Array.from(gruposMap.values()).sort((a, b) => a.orden - b.orden);
    for (const g of grupos) {
      g.dias.sort((a, b) => a.orden - b.orden);
    }
  } else {
    dias = todosDias.filter((d) => d.vigenciaGrupoId === null);
  }

  return {
    horarioId: horario.horarioId,
    nombre: horario.nombre,
    areaId: horario.areaId,
    areaNombre: horario.areaNombre,
    unidadId: horario.unidadId,
    extendido: !!horario.extendido,
    rotativo: !!horario.rotativo,
    regular: !!horario.regular,
    horasLaborales: horario.horasLaborales,
    dias,
    grupos,
    usuarios: [],
  };
}
