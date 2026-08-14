import { DateTime } from 'luxon';

export class LuxonAdapter {
  public static toSqlServerTime(timeString: string): string {
    const time = DateTime.fromFormat(timeString, 'HH:mm:ss');
    if (!time.isValid) {
      throw new Error('Invalid time format. Expected HH:mm:ss');
    }
    return time.toFormat('HH:mm:ss');
  }

  public static toTime(fecha: string = ''): string | null {
    if (fecha === '') return null;

    const hora = new Date(fecha).toISOString().substring(11, 19);
    return hora;
  }

  /**
   * Convierte una fecha 'YYYY-MM-DD' (o Date) a un Date local a medianoche
   * para enviarlo a SQL Server. Evita el corrimiento de día que produce
   * `new Date('YYYY-MM-DD')` (UTC) en servidores con zona horaria negativa.
   */
  public static toSqlServerDate(
    value: string | Date | null | undefined,
  ): Date | null {
    if (value === null || value === undefined || value === '') return null;
    if (value instanceof Date) return value;

    const dt = DateTime.fromISO(value, { zone: 'utc' });
    if (!dt.isValid) {
      throw new Error(`Fecha inválida (se espera YYYY-MM-DD): ${value}`);
    }
    return new Date(Date.UTC(dt.year, dt.month - 1, dt.day));
  }

  /** Normaliza un valor DATE de SQL Server (Date/ISO) a 'YYYY-MM-DD'. */
  public static fromSqlServerDate(
    value: string | Date | null | undefined,
  ): string | null {
    if (value === null || value === undefined || value === '') return null;

    const dt =
      value instanceof Date
        ? DateTime.fromJSDate(value, { zone: 'utc' })
        : DateTime.fromISO(value, { zone: 'utc' });
    return dt.isValid ? dt.toFormat('yyyy-MM-dd') : String(value);
  }

  /** Normaliza un valor TIME de SQL Server (Date/ISO) a 'HH:mm:ss'. */
  public static fromSqlServerTime(
    value: string | Date | null | undefined,
  ): string {
    if (value === null || value === undefined || value === '') return '';

    const dt =
      value instanceof Date
        ? DateTime.fromJSDate(value, { zone: 'utc' })
        : DateTime.fromISO(value, { zone: 'utc' });
    return dt.isValid ? dt.toFormat('HH:mm:ss') : String(value);
  }
}
