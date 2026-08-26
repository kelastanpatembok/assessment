declare global {
  namespace App {
    interface Locals {
      user: { userId: string; username: string; role: string; roles: string[] } | null;
      token: string | null;
    }
    interface PageData {
      user?: { userId: string; username: string; role: string; roles: string[] } | null;
    }
  }
}
export {};
