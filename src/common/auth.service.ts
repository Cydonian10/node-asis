import { IUser } from './types/user.js';

export class AuthService {
  public user: IUser = { id: 1, username: 'pepito' };

  public set userAuth(user: IUser) {
    this.user = user;
  }

  public getUser() {
    return this.user;
  }
}

export const authService = new AuthService();
