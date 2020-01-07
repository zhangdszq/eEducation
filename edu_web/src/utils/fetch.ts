const FETCH_TIMEOUT = 5000

export async function AgoraFetch (input: RequestInfo, init?: RequestInit): Promise<any> {
  return new Promise((resolve, reject) => {
    fetch(input, init).then(resolve, reject)
    if (FETCH_TIMEOUT) {
      const err = new Error("request timeout")
      setTimeout(reject, FETCH_TIMEOUT, err)
    }
  })
}