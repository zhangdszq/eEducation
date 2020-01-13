"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const winston_1 = require("winston");
const chalk_1 = __importDefault(require("chalk"));
const { combine, colorize, label, printf, splat, timestamp } = winston_1.format;
const createLoggerWithLabel = (loggerLabel) => winston_1.createLogger({
    level: process.env.LOG_LEVEL || "info",
    transports: [new winston_1.transports.Console({})],
    format: combine(timestamp(), splat(), colorize(), label({ label: loggerLabel }), printf(info => `${info.timestamp} ${chalk_1.default.cyan(info.label)} ${info.level}: ${info.message}`))
});
exports.sentry = createLoggerWithLabel("[Sentry:]");
exports.inMemoryCache = createLoggerWithLabel("[InMemoryCache:]");
exports.gateway = createLoggerWithLabel("[Gateway:]");
exports.default = createLoggerWithLabel;
//# sourceMappingURL=logger.js.map