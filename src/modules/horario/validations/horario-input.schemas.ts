import { z } from 'zod';

/**
 * Schemas de entrada reutilizados por crear y actualizar horario.
 * Los campos de id (turnoId, horarioDiaId, vigenciaGrupoId) son opcionales:
 * se usan al actualizar para saber si el turno/dia/grupo ya existe o se crea nuevo.
 */
export const TurnoInputSchema = z.object({
  turnoId: z
    .number({ message: 'turnoId debe ser un número' })
    .int({ message: 'turnoId debe ser un entero' })
    .positive({ message: 'turnoId debe ser mayor a 0' })
    .optional(),
  horaInicio: z
    .string({ message: 'horaInicio es requerido' })
    .regex(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, {
      message: 'horaInicio debe ser una hora válida (HH:mm)',
    }),
  horaFin: z
    .string({ message: 'horaFin es requerido' })
    .regex(/^([01]\d|2[0-3]):[0-5]\d(:[0-5]\d)?$/, {
      message: 'horaFin debe ser una hora válida (HH:mm)',
    }),
  extendido: z
    .boolean({ message: 'extendido debe ser un booleano' })
    .optional(),
  diaSalidaId: z
    .number({ message: 'diaSalidaId debe ser un número' })
    .int({ message: 'diaSalidaId debe ser un entero' })
    .positive({ message: 'diaSalidaId debe ser mayor a 0' })
    .nullable()
    .optional(),
});

export const DiaInputSchema = z.object({
  horarioDiaId: z
    .number({ message: 'horarioDiaId debe ser un número' })
    .int({ message: 'horarioDiaId debe ser un entero' })
    .positive({ message: 'horarioDiaId debe ser mayor a 0' })
    .optional(),
  diaId: z
    .number({ message: 'diaId es requerido' })
    .int()
    .positive({ message: 'diaId debe ser mayor a 0' }),
  orden: z
    .number({ message: 'orden es requerido' })
    .int()
    .min(0, { message: 'orden no puede ser negativo' })
    .optional(),
  turnos: z
    .array(TurnoInputSchema, { message: 'turnos es requerido' })
    .min(1, { message: 'turnos no puede estar vacío' }),
});

export const GrupoVigenciaInputSchema = z.object({
  vigenciaGrupoId: z
    .number({ message: 'vigenciaGrupoId debe ser un número' })
    .int({ message: 'vigenciaGrupoId debe ser un entero' })
    .positive({ message: 'vigenciaGrupoId debe ser mayor a 0' })
    .optional(),
  fechaInicio: z
    .string({ message: 'fechaInicio es requerido' })
    .regex(/^\d{4}-\d{2}-\d{2}$/, {
      message: 'fechaInicio debe ser una fecha válida (YYYY-MM-DD)',
    }),
  fechaFin: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, {
      message: 'fechaFin debe ser una fecha válida (YYYY-MM-DD)',
    })
    .nullable()
    .optional(),
  dias: z
    .array(DiaInputSchema, { message: 'dias es requerido' })
    .min(1, { message: 'dias no puede estar vacío' }),
});