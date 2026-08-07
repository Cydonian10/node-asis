import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type AsistenciaRepo = typeof sqlRepo;

const repo = selectRepo<AsistenciaRepo>({
  sql: sqlRepo,
});

export default repo;
