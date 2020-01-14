"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const redisAsync_1 = __importDefault(require("../../lib/redisAsync"));
const logger_1 = require("../../lib/logger");
const hashUser = (uid) => {
    return `u-${uid}`;
};
const hashChannel = (channel) => {
    return `c-${channel}`;
};
const hashChannelMembers = (channel) => {
    return `cm-${channel}`;
};
class ChannelCache {
    // private usersHash: string;
    // private gcInterval: number;
    // private cleanupSchedule?: NodeJS.Timeout;
    constructor() {
        // User/Channel List
        // addUser = async (uid: string) => {
        //   return await this.redisClient.saddAsync(this.usersHash, uid);
        // };
        // removeUser = async (uid: string) => {
        //   return await this.redisClient.sremAsync(this.usersHash, uid);
        // };
        // includeUser = async (uid: string) => {
        //   return await this.redisClient.sismemberAsync(this.usersHash, uid);
        // };
        this.addChannel = (channel) => __awaiter(this, void 0, void 0, function* () {
            logger_1.inMemoryCache.info(`add channel ${channel}`);
            return yield this.redisClient.saddAsync(this.channelsHash, channel);
        });
        this.removeChannel = (channel) => __awaiter(this, void 0, void 0, function* () {
            logger_1.inMemoryCache.info(`remove channel ${channel}`);
            return yield this.redisClient.sremAsync(this.channelsHash, channel);
        });
        this.getChannels = () => __awaiter(this, void 0, void 0, function* () {
            return yield this.redisClient.smembersAsync(this.channelsHash);
        });
        // ---------------- Garbage Collector ----------------
        // initCleanupSchedule = () => {
        //   this.cleanupSchedule = setInterval(async () => {
        //     const now = new Date().getTime();
        //     const channels: string[] = await this.redisClient.smembersAsync(this.channelsHash);
        //     for (const channel of channels) {
        //       const getLtnPromise = this.getChannelAttr(channel, ['lastmodified']);
        //       const getMembersPromise = this.getChannelMembers(channel);
        //       Promise.all([getLtnPromise, getMembersPromise])
        //         .then(([ltn, members]) => {
        //           if ((now - ltn > 1.5*this.gcInterval) && members.length) {
        //           }
        //         })
        //     }
        //   }, this.gcInterval);
        // };
        // ---------------- User Attr Operation ----------------
        this.getUserAttr = (uid, keys) => __awaiter(this, void 0, void 0, function* () {
            return yield this.redisClient.hmgetAsync(hashUser(uid), ...keys);
        });
        this.getAllUserAttr = (uid) => __awaiter(this, void 0, void 0, function* () {
            return yield this.redisClient.hgetallAsync(hashUser(uid));
        });
        this.setUserAttr = (uid, kvs) => __awaiter(this, void 0, void 0, function* () {
            logger_1.inMemoryCache.info(`set user attr for uid, ${JSON.stringify(kvs)}`);
            return yield this.redisClient.hmsetAsync(hashUser(uid), kvs);
        });
        this.clearUserAttr = (uid) => __awaiter(this, void 0, void 0, function* () {
            logger_1.inMemoryCache.info(`clear user attr for ${uid}`);
            return yield this.redisClient.delAsync(hashUser(uid));
        });
        // private flushUser = (uid: string) => {
        //   this.setUserAttr(uid, {
        //     lastmodified: new Date().getTime()
        //   });
        // };
        // ---------------- Channel Attr Operation ----------------
        this.getChannelAttr = (channel, keys) => __awaiter(this, void 0, void 0, function* () {
            return yield this.redisClient.hmgetAsync(hashChannel(channel), ...keys);
        });
        this.getAllChannelAttr = (channel) => __awaiter(this, void 0, void 0, function* () {
            return yield this.redisClient.hgetallAsync(hashChannel(channel));
        });
        this.setChannelAttr = (channel, kvs) => __awaiter(this, void 0, void 0, function* () {
            logger_1.inMemoryCache.info(`set channel attr for ${channel}, ${JSON.stringify(kvs)}`);
            return yield this.redisClient.hmsetAsync(hashChannel(channel), kvs);
        });
        this.clearChannelAttr = (channel) => __awaiter(this, void 0, void 0, function* () {
            logger_1.inMemoryCache.info(`clear channel attr for ${channel}`);
            yield this.redisClient.delAsync(hashChannel(channel));
            yield this.redisClient.delAsync(hashChannelMembers(channel));
        });
        this.addChannelMember = (channel, uid) => __awaiter(this, void 0, void 0, function* () {
            logger_1.inMemoryCache.info(`add member ${uid} to channel ${channel}`);
            if (Array.isArray(uid)) {
                return yield this.redisClient.saddAsync(hashChannelMembers(channel), ...uid);
            }
            else {
                return yield this.redisClient.saddAsync(hashChannelMembers(channel), uid);
            }
        });
        this.getChannelMembers = (channel) => __awaiter(this, void 0, void 0, function* () {
            return yield this.redisClient.smembersAsync(hashChannelMembers(channel));
        });
        this.removeChannelMember = (channel, uid) => __awaiter(this, void 0, void 0, function* () {
            logger_1.inMemoryCache.info(`add member ${uid} to channel ${channel}`);
            return yield this.redisClient.sremAsync(hashChannelMembers(channel), uid);
        });
        this.redisClient = redisAsync_1.default({
            prefix: process.env.AGORA_APPID,
            host: process.env.REDIS_HOST,
            port: Number(process.env.REDIS_PORT)
        });
        this.channelsHash = `channels`;
        // this.usersHash = `${this.namespace}-users`;
        // this.gcInterval = gcInterval;
    }
}
exports.default = ChannelCache;
//# sourceMappingURL=inMemoryCache.js.map