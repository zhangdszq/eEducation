export class CustomStorage {

  private storage: Storage;

  constructor() {
    this.storage = window.sessionStorage;
  }

  read(key: string): any {
    try {
      return JSON.parse(this.storage.getItem(key) as string);
    } catch(_) {
      return this.storage.getItem(key);
    }
  }

  save(key: string, val: any) {
    this.storage.setItem(key, JSON.stringify(val));
  }

  clear(key: string) {
    this.storage.removeItem(key);
  }
}

const GlobalStorage = new CustomStorage();
export default GlobalStorage;