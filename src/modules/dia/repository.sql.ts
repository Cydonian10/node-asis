import { connectToDb } from '@src/config/db-sqlserver.js';
import { ErrorUtil } from '@src/util/handleOperationResult.js';
import { Dia } from './dto/dia.dto.js';

const getAll = async (): Promise<Dia[]> => {
  try {
    const pool = await connectToDb();
    const request = pool.request();

    const result = await request.execute<Dia>('usp_GetDias');
    return result.recordset;
  } catch (error) {
    return ErrorUtil.select(error as string);
  }
};

export default {
  getAll,
};
