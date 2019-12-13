const fetchConfig = {
  timeout: 5000,
  headers: {},
}

export async function AgoraFetch (input: RequestInfo, init?: RequestInit): Promise<any> {
  return new Promise((resolve, reject) => {
    fetch(input, init).then(resolve, reject);
    if (fetchConfig.timeout) {
      const err = new Error("Connection timed out");
      setTimeout(reject, fetchConfig.timeout, err);
    }
  });
}
// export const AgoraFetch = (...args: any[]) => {
//   fetch(args)
// }