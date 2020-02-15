const {
  override,
  addBabelPlugins,
  addWebpackExternals,
  useBabelRc
} = require('customize-cra');

const isElectron = process.env.BROWSER === 'none';
const isProd = process.env.ENV === 'production';

const sourceMap = () => config => {
  config.devtool = isProd ? 'cheap-module-source-map' : 'cheap-module-eval-source-map'
  console.log("mode", config.mode, isProd, config.devtool);
  return config;
}

module.exports = override(
  sourceMap(),
  isElectron && addWebpackExternals({
    "agora-electron-sdk": "commonjs2 agora-electron-sdk"
  }),
  addBabelPlugins(
    '@babel/plugin-proposal-optional-chaining'
  ),
  useBabelRc()
)