const proxy = require('http-proxy-middleware');

const URL = process.env.REACT_APP_AGORA_RECORDING_SERVICE_URL;
const APP_ID = process.env.REACT_APP_AGORA_APP_ID;

module.exports = function (app) {
  // URL && app.use(
  //   '/v1',
  //   proxy({
  //     target: URL.replace('%s', APP_ID),
  //     pathRewrite: {"^/v1": ""},
  //     changeOrigin: true,
  //   })
  // )
}