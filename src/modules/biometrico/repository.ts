import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type BiometricoRepo = typeof sqlRepo;

const repo = selectRepo<BiometricoRepo>({
  sql: sqlRepo,
});

export default repo;
