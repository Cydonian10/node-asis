import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type DiaRepo = typeof sqlRepo;

const repo = selectRepo<DiaRepo>({
  sql: sqlRepo,
});

export default repo;
