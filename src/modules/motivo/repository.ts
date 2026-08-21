import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type MotivoRepo = typeof sqlRepo;

const repo = selectRepo<MotivoRepo>({
  sql: sqlRepo,
});

export default repo;
