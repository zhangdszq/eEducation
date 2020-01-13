"use strict";
/// <reference path="../../proto/proto.d.ts" />
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
const agora_rtm_nodejs_1 = __importDefault(require("../../../agora-rtm-nodejs"));
const inMemoryCache_1 = __importDefault(require("./inMemoryCache"));
const logger_1 = require("../../lib/logger");
const mutex_1 = __importDefault(require("../../lib/mutex"));
class Sentry {
    constructor(appId, uid = "agora-sentry") {
        /** Sentry will login to AgoraRTM */
        this.login = () => __awaiter(this, void 0, void 0, function* () {
            // subscribe session events
            this.rtmController.on("Logout", () => {
                logger_1.sentry.error("Sentry offline");
                this.online = false;
            });
            this.rtmController.on("MessageReceivedFromPeer", (peerId, message) => {
                logger_1.sentry.info("->>> incoming message ->>>");
                logger_1.sentry.info(`${peerId}: ${message}`);
                // handle command message
                this.onMessage(peerId, message);
            });
            // do login
            logger_1.sentry.info(`Sentry trying to login... App ID: ${this.appId}, uid: ${this.uid}`);
            yield this.rtmController.login(null, this.uid);
            logger_1.sentry.info("Sentry succeed to login");
            this.online = true;
        });
        /** Sentry will join and listen to target channel */
        this.join = (channel) => {
            return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
                const channelInstance = this.rtmController.createChannel(channel);
                // subscribe channel events
                channelInstance.on("LeaveChannel", (ecode) => {
                    if (ecode) {
                        logger_1.sentry.error("Left channel unexpectedly", ecode);
                    }
                });
                channelInstance.on("GetMembers", (members, ecode) => __awaiter(this, void 0, void 0, function* () {
                    if (ecode) {
                        reject(ecode);
                    }
                    logger_1.sentry.info(`Members in channel ${channel}`);
                    logger_1.sentry.info(JSON.stringify(members));
                    if (members.length <= 1) {
                        try {
                            logger_1.sentry.info(`No members in channel ${channel}, try to unregister`);
                            yield this.unregisterChannel(channel);
                        }
                        catch (err) {
                            logger_1.sentry.warn(`Failed to unregister channel ${channel} ${err}`);
                        }
                    }
                    else {
                        yield this.cache.addChannelMember(channel, members.filter(item => item !== this.uid));
                    }
                    resolve(channelInstance);
                }));
                channelInstance.on("MemberJoined", (peerId, channel) => __awaiter(this, void 0, void 0, function* () {
                    logger_1.sentry.info(`Member ${peerId} joined channel ${channel}`);
                    yield this.cache.addChannelMember(channel, peerId);
                    if (this.joinQueue.has(peerId)) {
                        logger_1.sentry.info(`Delayed join for ${peerId}`);
                        const target = this.joinQueue.get(peerId);
                        clearTimeout(target.timer);
                        this.joinQueue.delete(peerId);
                        this.handleJoinSuccess(peerId, channel, target.userAttr, target.channelAttr);
                    }
                    if (this.gcQueue.has(channel)) {
                        logger_1.sentry.info(`Cancel gc for channel ${channel} since new member joined`);
                        clearTimeout(this.gcQueue.get(channel));
                        this.gcQueue.delete(channel);
                    }
                }));
                channelInstance.on("MemberLeft", (peerId, channel) => __awaiter(this, void 0, void 0, function* () {
                    logger_1.sentry.info(`Member ${peerId} left channel ${channel}`);
                    try {
                        yield this.cache.removeChannelMember(channel, peerId);
                        yield this.cache.clearUserAttr(peerId);
                    }
                    catch (err) {
                        logger_1.sentry.warn(`
              Failed to clear user attribute for user ${peerId} in channel ${channel}, ${err}
            `);
                    }
                    // check if we should unregister this channel
                    const members = yield this.cache.getChannelMembers(channel);
                    if (members.length === 0) {
                        try {
                            logger_1.sentry.info(`No members left in channel ${channel}, try to unregister`);
                            yield this.unregisterChannel(channel);
                        }
                        catch (err) {
                            logger_1.sentry.warn(`Failed to unregister channel ${channel} ${err}`);
                        }
                    }
                    else {
                        for (const member of members) {
                            const response = {
                                name: "MemberLeft",
                                args: {
                                    uid: peerId
                                }
                            };
                            this.sendMessage(member, JSON.stringify(response));
                        }
                    }
                }));
                // do join and fetch members
                try {
                    logger_1.sentry.info(`Entering channel ${channel}`);
                    yield channelInstance.join();
                    logger_1.sentry.info(`Succeed to join channel ${channel}`);
                    channelInstance.getMembers();
                }
                catch (err) {
                    logger_1.sentry.info(`Failed to enter channel ${channel}`);
                    reject(err);
                }
            }));
        };
        this.uid = uid;
        this.appId = appId;
        this.channelList = new Map();
        this.rtmController = new agora_rtm_nodejs_1.default();
        this.cache = new inMemoryCache_1.default();
        this.online = false;
        this.gcQueue = new Map();
        this.joinQueue = new Map();
        this.channelMutex = new mutex_1.default();
    }
    init() {
        return __awaiter(this, void 0, void 0, function* () {
            this.rtmController.initialize(this.appId);
            yield this.login();
            // Recover registry for channel in memory cache
            const channelsInMemory = yield this.cache.getChannels();
            for (const channel of channelsInMemory) {
                const channelAttr = yield this.cache.getAllChannelAttr(channel);
                try {
                    logger_1.sentry.info(`Recovering registry for channel ${channel}`);
                    yield this.registerChannel(channel, channelAttr);
                }
                catch (err) {
                    logger_1.sentry.error(`Failed to Recover registry for channel ${channel}`);
                }
            }
        });
    }
    /** Sentry register Channel in ChannelList */
    registerChannel(channelName, channelAttr) {
        return __awaiter(this, void 0, void 0, function* () {
            yield this.channelMutex.wait(channelName);
            this.channelMutex.lock(channelName);
            if (this.gcQueue.has(channelName)) {
                logger_1.sentry.info(`Cancel gc for channel ${channelName} since new registry`);
                clearTimeout(this.gcQueue.get(channelName));
                this.gcQueue.delete(channelName);
                if (channelAttr) {
                    yield this.cache.setChannelAttr(channelName, channelAttr);
                }
            }
            else {
                logger_1.sentry.info(`Registering channel ${channelName}`);
                const channelController = yield this.join(channelName);
                this.channelList.set(channelName, channelController);
                logger_1.sentry.info(`Current channel list ${JSON.stringify(Array.from(this.channelList.keys()))}`);
                if (channelAttr) {
                    yield this.cache.setChannelAttr(channelName, channelAttr);
                }
                yield this.cache.addChannel(channelName);
                logger_1.sentry.info(`Register channel ${channelName} successfully`);
            }
            this.channelMutex.unlock(channelName);
        });
    }
    unregisterChannel(channelName) {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.gcQueue.has(channelName)) {
                return;
            }
            this.gcQueue.set(channelName, setTimeout(() => __awaiter(this, void 0, void 0, function* () {
                yield this.channelMutex.wait(channelName);
                this.channelMutex.lock(channelName);
                logger_1.sentry.info(`Unregistering channel ${channelName}`);
                const channelController = this.channelList.get(channelName);
                if (channelController) {
                    yield channelController.leave();
                    channelController.release();
                    this.channelList.delete(channelName);
                }
                try {
                    yield this.cache.clearChannelAttr(channelName);
                    yield this.cache.removeChannel(channelName);
                    logger_1.sentry.info(`Unregister channel ${channelName} and clear related attr`);
                }
                catch (err) {
                    logger_1.sentry.warn(`Failed to clear channel attribute for channel ${channelName}, ${err}`);
                }
                this.gcQueue.delete(channelName);
                this.channelMutex.unlock(channelName);
            }), 30000));
        });
    }
    // ---------------- internal handlers ----------------
    // Handlers for request from client
    /** Sentry send response to client by AgoraRTM p2p message */
    sendMessage(peerId, message) {
        logger_1.sentry.info(`Sending message to ${peerId}: ${message}`);
        this.rtmController.sendMessageToPeer(peerId, message);
    }
    /** Sentry get request from client by AgoraRTM p2p message */
    onMessage(peerId, message) {
        // handle command
        try {
            const command = JSON.parse(message);
            switch (command.name) {
                case "Join":
                    this.handleJoin(peerId, command);
                    break;
                case "Chat":
                    this.handleChat(peerId, command);
                    break;
                case "Mute":
                    this.handleMute(peerId, command);
                    break;
                case "Unmute":
                    this.handleUnmute(peerId, command);
                    break;
                case "Ring":
                    this.handleRing(peerId, command);
                    break;
                case "CustomRequest":
                    this.handleCustomRequest(peerId, command);
                    break;
                case "UpdateUserAttr":
                    this.handleUpdateUserAttr(peerId, command);
                    break;
                case "UpdateChannelAttr":
                    this.handleUpdateChannelAttr(peerId, command);
                    break;
                default:
                    this.handleError(peerId, "Undefined Request");
                    break;
            }
        }
        catch (err) {
            this.handleError(peerId, "Invalid Request Format");
        }
    }
    handleJoin(fromId, request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { channel, userAttr, channelAttr } = request.args;
            logger_1.sentry.info("->>> incoming join command ->>>");
            logger_1.sentry.info(`${channel}, ${JSON.stringify(userAttr)}, ${JSON.stringify(channelAttr)}`);
            // if channel not exsits, create it
            if (!this.channelList.has(channel)) {
                logger_1.sentry.info("Channel not exists, create new one");
                try {
                    yield this.registerChannel(channel, channelAttr);
                }
                catch (err) {
                    const response = {
                        name: "JoinFailure",
                        args: {
                            info: `Failed to register channel: ${channel}, ${err}`
                        }
                    };
                    this.sendMessage(fromId, JSON.stringify(response));
                    return;
                }
            }
            const members = yield this.cache.getChannelMembers(channel);
            if (!members.includes(fromId)) {
                if (this.joinQueue.has(fromId)) {
                    return;
                }
                this.joinQueue.set(fromId, {
                    channel,
                    userAttr,
                    channelAttr,
                    timer: setTimeout(() => {
                        this.handleJoinFailure(fromId);
                        this.joinQueue.delete(fromId);
                    }, 30000)
                });
            }
            else {
                this.handleJoinSuccess(fromId, channel, userAttr, channelAttr);
            }
        });
    }
    handleJoinFailure(fromId) {
        return __awaiter(this, void 0, void 0, function* () {
            const response = {
                name: "JoinFailure",
                args: {
                    info: `Not in RTM channel`
                }
            };
            this.sendMessage(fromId, JSON.stringify(response));
        });
    }
    handleJoinSuccess(fromId, channel, userAttr, channelAttr) {
        return __awaiter(this, void 0, void 0, function* () {
            const members = yield this.cache.getChannelMembers(channel);
            yield this.cache.setUserAttr(fromId, Object.assign({}, userAttr, { channel: channel }));
            if (channelAttr) {
                yield this.cache.setChannelAttr(channel, channelAttr);
            }
            let users = [];
            for (const member of members) {
                const attribute = yield this.cache.getAllUserAttr(member);
                users.push(Object.assign({}, attribute, { uid: member }));
                if (member !== fromId) {
                    const response = {
                        name: "MemberJoined",
                        args: Object.assign({ uid: fromId }, userAttr)
                    };
                    this.sendMessage(member, JSON.stringify(response));
                }
            }
            const channelStatus = yield this.cache.getAllChannelAttr(channel);
            const response = {
                name: "JoinSuccess",
                args: {
                    channelAttr: channelStatus,
                    members: users
                }
            };
            this.sendMessage(fromId, JSON.stringify(response));
        });
    }
    handleChat(fromId, request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { message } = request.args;
            const [channel] = yield this.cache.getUserAttr(fromId, ["channel"]);
            logger_1.sentry.info("->>> incoming chat command ->>>");
            logger_1.sentry.info(`${channel}, ${fromId}, ${message}`);
            const members = yield this.cache.getChannelMembers(channel);
            const response = {
                name: "ChannelMessage",
                args: {
                    uid: fromId,
                    message
                }
            };
            for (const member of members) {
                this.sendMessage(member, JSON.stringify(response));
            }
        });
    }
    handleMute(fromId, request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { type, target } = request.args;
            const [channel] = yield this.cache.getUserAttr(fromId, ["channel"]);
            logger_1.sentry.info("->>> incoming mute command ->>>");
            logger_1.sentry.info(`${channel}, ${fromId}, ${type}, ${target}`);
            const members = yield this.cache.getChannelMembers(channel);
            const response = {
                name: "Muted",
                args: {
                    type: type,
                    uid: fromId
                }
            };
            if (target instanceof Array) {
                for (let item of target) {
                    if (members.includes(item)) {
                        this.sendMessage(item, JSON.stringify(response));
                    }
                }
            }
            else {
                if (members.includes(target)) {
                    this.sendMessage(target, JSON.stringify(response));
                }
            }
        });
    }
    handleUnmute(fromId, request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { type, target } = request.args;
            const [channel] = yield this.cache.getUserAttr(fromId, ["channel"]);
            logger_1.sentry.info("->>> incoming unmute command ->>>");
            logger_1.sentry.info(`${channel}, ${fromId}, ${type}, ${target}`);
            const members = yield this.cache.getChannelMembers(channel);
            const response = {
                name: "Unmuted",
                args: {
                    type: type,
                    uid: fromId
                }
            };
            if (target instanceof Array) {
                for (let item of target) {
                    if (members.includes(item)) {
                        this.sendMessage(item, JSON.stringify(response));
                    }
                }
            }
            else {
                if (members.includes(target)) {
                    this.sendMessage(target, JSON.stringify(response));
                }
            }
        });
    }
    handleRing(fromId, request) {
        return __awaiter(this, void 0, void 0, function* () {
            const [channel] = yield this.cache.getUserAttr(fromId, ["channel"]);
            logger_1.sentry.info("->>> incoming ring command ->>>");
            logger_1.sentry.info(`${channel}, ${fromId}`);
            const members = yield this.cache.getChannelMembers(channel);
            const response = {
                name: "Ringing",
                args: {
                    uid: fromId
                }
            };
            for (const member of members) {
                this.sendMessage(member, JSON.stringify(response));
            }
        });
    }
    handleCustomRequest(fromId, request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { type, uid } = request.args;
            const [channel] = yield this.cache.getUserAttr(fromId, ["channel"]);
            logger_1.sentry.info("->>> incoming customrequest command ->>>");
            logger_1.sentry.info(`${channel}, ${fromId}, ${type}, ${uid}`);
            const members = yield this.cache.getChannelMembers(channel);
            const response = {
                name: "CustomRequest",
                args: {
                    type,
                    uid: fromId
                }
            };
            if (members.includes(uid)) {
                this.sendMessage(uid, JSON.stringify(response));
            }
        });
    }
    handleUpdateUserAttr(fromId, request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { uid, userAttr } = request.args;
            const [channel] = yield this.cache.getUserAttr(fromId, ["channel"]);
            logger_1.sentry.info("->>> incoming updateuserattr command ->>>");
            logger_1.sentry.info(`${channel}, ${fromId}, ${uid}, ${userAttr}`);
            const members = yield this.cache.getChannelMembers(channel);
            const response = {
                name: "UserAttrUpdated",
                args: {
                    userAttr: userAttr,
                    target: uid,
                    uid: fromId
                }
            };
            if (members.includes(uid)) {
                yield this.cache.setUserAttr(uid, userAttr);
                for (const member of members) {
                    this.sendMessage(member, JSON.stringify(response));
                }
            }
        });
    }
    handleUpdateChannelAttr(fromId, request) {
        return __awaiter(this, void 0, void 0, function* () {
            const { channelAttr } = request.args;
            const [channel] = yield this.cache.getUserAttr(fromId, ["channel"]);
            logger_1.sentry.info("->>> incoming updatechannelattr command ->>>");
            logger_1.sentry.info(`${channel}, ${fromId}, ${channelAttr}`);
            if (!channelAttr) {
                return;
            }
            const members = yield this.cache.getChannelMembers(channel);
            const response = {
                name: "ChannelAttrUpdated",
                args: {
                    channelAttr,
                    uid: fromId
                }
            };
            yield this.cache.setChannelAttr(channel, channelAttr);
            for (const member of members) {
                this.sendMessage(member, JSON.stringify(response));
            }
        });
    }
    handleError(toId, errInfo) {
        const exception = {
            name: "Error",
            args: {
                info: errInfo
            }
        };
        this.sendMessage(toId, JSON.stringify(exception));
    }
}
exports.default = Sentry;
//# sourceMappingURL=index.js.map