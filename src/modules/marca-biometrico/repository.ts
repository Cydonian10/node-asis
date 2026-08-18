import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type MarcaBiometricoRepo = typeof sqlRepo;

const repo = selectRepo<MarcaBiometricoRepo>({
  sql: sqlRepo,
});

export default repo;
