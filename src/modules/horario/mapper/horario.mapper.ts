import { HorarioDetalle } from '../dto/horario-detalle.dto.js';

type DetalleRow = {
  horarioDiaId: number;
  diaId: number;
  diaNombre: string;
  orden: number;
  turnoId: number | null;
  horaInicio: string | null;
  horaFin: string | null;
  extendido: boolean | null;
  salidaDiaId: number | null;
  salidaDiaNombre: string | null;
  vigenciaId: number | null;
  fechaInicio: string | null;
  fechaFin: string | null;
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
 * El SP devuelve el encabezado en la primera fila y el detalle en el tercer set.
 */
export function mapHorarioDetalle(
  recordsets: Array<Array<unknown>>,
): HorarioDetalle | null {
  const horarios = recordsets[0] as HorarioRow[] | undefined;
  const filas = (recordsets[2] ?? []) as DetalleRow[];
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
        vigencia: fila.vigenciaId
          ? {
              vigenciaId: fila.vigenciaId,
              fechaInicio: fila.fechaInicio,
              fechaFin: fila.fechaFin,
            }
          : null,
        turnos: [],
      };
      diasMap.set(fila.horarioDiaId, dia);
    }

    if (fila.turnoId !== null && fila.turnoId !== undefined) {
      dia.turnos.push({
        turnoId: fila.turnoId,
        horaInicio: fila.horaInicio ?? '',
        horaFin: fila.horaFin ?? '',
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
    dias: Array.from(diasMap.values()).sort((a, b) => a.orden - b.orden),
    usuarios: [],
  };
}
