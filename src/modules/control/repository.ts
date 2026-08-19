import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type ControlRepo = typeof sqlRepo;

const repo = selectRepo<ControlRepo>({
  sql: sqlRepo,
});

export default repo;
