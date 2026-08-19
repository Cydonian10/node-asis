import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type TurnoModificadoRepo = typeof sqlRepo;

const repo = selectRepo<TurnoModificadoRepo>({
  sql: sqlRepo,
});

export default repo;
