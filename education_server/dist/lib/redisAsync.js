"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const redis_1 = __importDefault(require("redis"));
const bluebird_1 = require("bluebird");
;
const redisAsync = bluebird_1.promisifyAll(redis_1.default);
const createclient = (clientOpts) => {
    return redisAsync.createClient(clientOpts);
};
exports.default = createclient;
//# sourceMappingURL=redisAsync.js.map