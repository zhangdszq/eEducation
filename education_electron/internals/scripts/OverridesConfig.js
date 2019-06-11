const fs = require('fs');
const path = require('path');
const process = require('process');

const filepath = path.resolve(__dirname, '../../.env');
const string = `REACT_APP_AGORA_APPID=${process.env.AGORA_APP_ID || ''}`
fs.writeFile(filepath, string, err => {
  if(err) {
    throw err;
  }
});