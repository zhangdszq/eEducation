const {
  override,
  addWebpackExternals
} = require('customize-cra');

module.exports = override(
  addWebpackExternals({
    "agora-electron-sdk": "commonjs2 agora-electron-sdk"
  })
)