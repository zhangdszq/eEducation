const {
  override,
  addBabelPlugins,
  addWebpackExternals,
  useBabelRc,
  addWebpackModuleRule,
} = require('customize-cra');

const {devDependencies} = require('./package.json');

const isElectron = process.env.BROWSER === 'none';
// TODO: You can customize your env
// TODO: 这里你可以定制自己的env
const isProd = process.env.ENV === 'production';

const webWorkerConfig = () => config => {
  config.optimization = {
    ...config.optimization,
    noEmitOnErrors: false,
  }
  config.output = {
    ...config.output,
    globalObject: 'this'
  }
  return config;
}

const sourceMap = () => config => {
  // TODO: Please use 'source-map' in production environment
  // TODO: 建议上发布环境用 'source-map'
  config.devtool = isProd ? 'source-map' : 'cheap-module-eval-source-map'
  return config;
}

const setElectronDeps = isProd ? {
  ...devDependencies,
  "agora-electron-sdk": "commonjs2 agora-electron-sdk"
} : {
  "agora-electron-sdk": "commonjs2 agora-electron-sdk"
}


module.exports = override(
  sourceMap(),
  webWorkerConfig(),
  addWebpackModuleRule({
    test: /\.worker\.js$/,
    use: { loader: 'worker-loader' },
  }),
  isElectron && addWebpackExternals(setElectronDeps),
  addBabelPlugins(
    '@babel/plugin-proposal-optional-chaining'
  ),
  useBabelRc()
)
