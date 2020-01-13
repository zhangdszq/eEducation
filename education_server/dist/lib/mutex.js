"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
class Mutex {
    constructor() {
        this.lockers = new Map();
    }
    lock(key) {
        this.lockers.set(key, true);
    }
    unlock(key) {
        this.lockers.delete(key);
    }
    wait(key) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                if (!this.lockers.get(key)) {
                    resolve();
                }
                else {
                    reject(new Error(`${key} has been locked`));
                }
            });
        });
    }
}
exports.default = Mutex;
//# sourceMappingURL=mutex.js.map