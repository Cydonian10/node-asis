import { IUser } from '@src/common/types/user.js';
import * as e from 'express';

// **** Express **** //

export interface IReq<T = void> extends e.Request {
  body: T;
  user?: IUser;
}

export interface IRes extends e.Response {
  locals: Record<string, unknown>;
}
