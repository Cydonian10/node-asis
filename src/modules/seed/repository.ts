import { selectRepo } from '@src/util/repoSelector.js';
import sqlRepo from './repository.sql.js';

export type SeedRepo = typeof sqlRepo;

const repo = selectRepo<SeedRepo>({
  sql: sqlRepo,
});

export default repo;
