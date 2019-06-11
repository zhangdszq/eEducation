declare module 'agora-rtc-sdk' {
  const AgoraRTC: any;
  export default AgoraRTC;
}

declare enum ClientRole {
  AUDIENCE = 0,
  STUDENT = 1,
  TEACHER = 2
}
