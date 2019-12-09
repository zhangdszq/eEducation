import { useAgoraSDK } from './../hooks/use-agora-sdk';
import { useGlobalContext } from '../containers/global-container';
console.log(`CURRENT RUNTIME: ${process.env.REACT_APP_RUNTIME_PLATFORM}`);

export const isElectron = process.env.REACT_APP_RUNTIME_PLATFORM === 'electron'

console.log("platform ", process.env.REACT_APP_RUNTIME_PLATFORM);