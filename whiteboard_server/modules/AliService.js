const OSS = require('ali-oss');
const { RPCClient } = require('@alicloud/pop-core');
const { ALI_SERVICE_KEYID, ALI_SERVICE_SECRET } = require("./config");


class AliService {
  constructor() {
    this.oss = new OSS({
      region: 'cn-shanghai',
      accessKeyId: ALI_SERVICE_KEYID,
      accessKeySecret: ALI_SERVICE_SECRET,
      bucket: 'education-whiteboard-image',
      endpoint: 'oss-cn-shanghai.aliyuncs.com'
    });
    this.imm = new RPCClient({
      endpoint: 'http://imm.cn-shanghai.aliyuncs.com',
      accessKeyId: ALI_SERVICE_KEYID,
      accessKeySecret: ALI_SERVICE_SECRET,
      apiVersion: '2017-09-06'
    });
  }

  uploadToOSS(name, buffer) {
    return new Promise((resolve, reject) => {
      this.oss.put(`input/${name}`, buffer).then(result => {
        resolve(result);
      }).catch(e => {
        reject(e);
      });
    });
  }

  convert(filename, filesrc) {
    return new Promise((resolve, reject) => {
      const params = {
        Project: `EducationWhiteBoard`,
        SrcUri: `oss://education-whiteboard-image/${filesrc}`,
        TgtType: "jpg",
        TgtUri: `oss://education-whiteboard-image/output/${filename}`
      };
      this.imm.request("CreateOfficeConversionTask", params).then(result => {
        resolve(result);
      }).catch(e => {
        reject(e);
      });
    });
  }
}

module.exports = AliService;