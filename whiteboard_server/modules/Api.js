const logger = require("./logger").get("whiteboard");
const request = require("request");
const baseUrl = "https://cloudcapiv3.herewhite.com";
const {WHITE_TOKEN} = require("./config");
const multer = require('multer');
const storage = multer.memoryStorage();
const upload = multer({
    storage: storage,
    limits: {
        // 30M size limit
        fieldSize: 30 * 1024 * 1024,
    }
});
const AliService = require('./AliService');
const aliservice = new AliService();



function ClusterApi(app) {
    app.use((req, res, next) => {
        logger.info(`incoming restful request: ${req.method}, ${req.url}, ${req.method === "GET" ? JSON.stringify(req.query) : JSON.stringify(req.body)}`);
        next();
    });

    app.post('/v1/doc/convert', upload.single('doc'), (req, res, next) => {
        // req.file is the `avatar` file
        // req.body will hold the text fields, if there were any
        const file = req.file;
        if (!file) {
            res.status(500).json({
                err: 'no file found'
            });
        } else {
            const buffer = file.buffer;
            const filename = `doc-${new Date().getTime()}`;
            aliservice.uploadToOSS(filename, buffer).then(result => {
                const filesrc = result.name;
                aliservice.convert(filename, filesrc).then(result => {
                    debugger;
                }).catch(e => {
                    next(e);
                });
            }).catch(e => {
                next(e);
            })
        }
    });

    app.post("/v1/room", (req, res) => {
        const { body } = req;
        let name = body.name || "";
        let limit = body.limit || 5;
        let data = {
            name: name,
            limit: limit
        };
        const url = `${baseUrl}/room?token=${WHITE_TOKEN}`
        request({
            url: url,
            method: "POST",
            json: true,
            body: data
        }, (err, response, body) => {
            if (err) {
                next(err);
            } else {
                res.json(body);
            }
        });
    });

    app.post("/v1/room/join", (req, res) => {
        const { body } = req;
        let uuid = body.uuid || "";
        request({
            url: `${baseUrl}/room/join?uuid=${uuid}&token=${WHITE_TOKEN}`,
            method: "POST",
            json: true
        }, (err, response, body) => {
            if (err) {
                next(err);
            } else {
                res.json(body);
            }
        });
    });

    app.post("/v1/room/close", (req, res) => {
        const { body } = req;
        let uuid = body.uuid || "";

        let data = {
            uuid: uuid
        };
        request({
            url: `${baseUrl}/room/close?token=${WHITE_TOKEN}`,
            method: "POST",
            json: true,
            body: data
        }, (err, response, body) => {
            if (err) {
                next(err)
            } else {
                res.json(body);
            }
        });
    });

    app.use((err, req, res, next) => {
        console.error(err.stack)
        res.status(500).send({
            err: err
        })
    })
}


module.exports = {
    cluster: ClusterApi
};