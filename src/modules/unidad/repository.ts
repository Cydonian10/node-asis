import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type UnidadRepo = typeof sqlRepo;

const repo = selectRepo<UnidadRepo>({
  sql: sqlRepo,
});

export default repo;
