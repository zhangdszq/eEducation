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
const express_1 = __importDefault(require("express"));
const body_parser_1 = __importDefault(require("body-parser"));
const cors_1 = __importDefault(require("cors"));
const sentry_1 = __importDefault(require("./components/sentry"));
const logger_1 = require("./lib/logger");
require("dotenv").config();
const sentry = new sentry_1.default(process.env.AGORA_APPID || '');
const app = express_1.default();
app.use(body_parser_1.default.json());
app.use(body_parser_1.default.urlencoded({ extended: true }));
app.use(cors_1.default());
sentry.init();
app.get("/sentry", (req, res) => __awaiter(this, void 0, void 0, function* () {
    if (!sentry.online) {
        logger_1.gateway.info('Initializing Sentry...');
        try {
            yield sentry.init();
            logger_1.gateway.info('Sentry initialized successfully');
        }
        catch (err) {
            logger_1.gateway.error(`Sentry failed to initialize ${err}`);
        }
    }
    res.send(sentry.uid);
}));
app.post("/simple_auth", (req, res) => __awaiter(this, void 0, void 0, function* () {
    const { cname, role } = req.body;
    const channelAttr = yield sentry.cache.getAllChannelAttr(cname);
    if (channelAttr.teacherId && role === 2) {
        res.json({
            result: false,
            info: "Teacher already exists in this class"
        });
    }
}));
app.get("/user/:uid", (req, res) => __awaiter(this, void 0, void 0, function* () {
    const uid = req.params.uid;
    const userAttr = yield sentry.cache.getAllUserAttr(uid);
    res.send(`
    ${uid}: 
    ${JSON.stringify(userAttr)}
  `);
}));
app.get("/channel/:cname", (req, res) => __awaiter(this, void 0, void 0, function* () {
    const cname = req.params.cname;
    const channelAttr = yield sentry.cache.getAllChannelAttr(cname);
    const members = yield sentry.cache.getChannelMembers(cname);
    res.send(`
    ${cname}:
    ${JSON.stringify(channelAttr)}
    ${JSON.stringify(members)} 
  `);
}));
app.listen(process.env.SERVER_PORT, () => console.log(`Example app listening on port ${process.env.SERVER_PORT}!`));
//# sourceMappingURL=index.js.map