
const express = require("express");
const bodyParser = require("body-parser");
const logger = require("./modules/logger").get("whiteboard");
const app = express();
const http_server = require("http").Server(app);


function initProcess(application) {
    // parse application/json
    application.use(bodyParser.json());
    application.use(bodyParser.urlencoded({ extended: false }));

    // Add headers
    application.use(function (req, res, next) {
        // Website you wish to allow to connect
        res.setHeader("Access-Control-Allow-Origin", "*");

        // Request methods you wish to allow
        res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, PATCH, DELETE");

        // Request headers you wish to allow
        res.setHeader("Access-Control-Allow-Headers", "X-Requested-With,content-type");

        // Set to true if you need the website to include cookies in the requests sent
        // to the API (e.g. in case you use sessions)
        // res.setHeader("Access-Control-Allow-Credentials", true);

        // Pass to next layer of midd leware
        next();
    });
}


const api = require("./modules/Api").cluster;
logger.info(`start in ${process.env.NODE_ENV} master mode`);
initProcess(app);
api(app);
http_server.listen(3785);