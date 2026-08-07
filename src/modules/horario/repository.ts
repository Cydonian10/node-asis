import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type HorarioRepo = typeof sqlRepo;

const repo = selectRepo<HorarioRepo>({
  sql: sqlRepo,
});

export default repo;
