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
}
