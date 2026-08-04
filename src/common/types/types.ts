import * as e from 'express';
import { Query } from 'express-serve-static-core';

// **** Express **** //

export interface IReq<T = void> extends e.Request {
  body: T;
}

export interface IReqQuery<T extends Query, U = void> extends e.Request {
  query: T;
  body: U;
}

// types.ts
export interface EmailAccountsConfig {
  colegio: {
    user: string;
    pass: string;
  };
}

export interface GlobalConfig {
  emailAccounts: EmailAccountsConfig;
}
