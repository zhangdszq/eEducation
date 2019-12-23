const {
  override,
  addBabelPlugins,
  addWebpackExternals,
  useBabelRc
} = require('customize-cra');

const isDev = process.env.BROWSER === 'none';

module.exports = override(
  isDev && addWebpackExternals({
    "agora-electron-sdk": "commonjs2 agora-electron-sdk"
  }),
  addBabelPlugins(
    '@babel/plugin-proposal-optional-chaining'
  ),
  useBabelRc()
)