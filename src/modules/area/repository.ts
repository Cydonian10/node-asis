import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type AreaRepo = typeof sqlRepo;

const repo = selectRepo<AreaRepo>({
  sql: sqlRepo,
});

export default repo;
