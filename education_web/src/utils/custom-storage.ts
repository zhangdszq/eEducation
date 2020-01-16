export class CustomStorage {

  private storage: Storage;

  constructor() {
    this.storage = window.sessionStorage;
  }

  read(key: string): any {
    try {
      let json = JSON.parse(this.storage.getItem(key) as string);
      return json
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

  getLanguage() {
    const language = this.read('language') ? this.read('language') : navigator.language;
    return {language};
  }
}

const GlobalStorage = new CustomStorage();
export default GlobalStorage;