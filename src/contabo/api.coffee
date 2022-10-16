#!/usr/bin/env coffee

> ./contabo.mjs
  uuid > v4:uuid

body = new FormData()
body.append('grant_type','password')
for [k,v] from Object.entries contabo
  body.append(k,v)

req = (url, opt)=>
  retry = 9
  while --retry
    try
      r = await fetch(url,opt)
      break
    catch err
      console.trace()
      console.error url
      console.error err
  if r.status == 204
    return
  r.json()

{access_token} = await req(
  'https://auth.contabo.com/auth/realms/contabo/protocol/openid-connect/token'
  {
    method: 'POST'
    body:new URLSearchParams body
  }
)

export default api = (url, opt={})=>
  req(
    'https://api.contabo.com/v1/'+url
    {
      headers: {
        'Content-Type': 'application/json'
        Authorization: 'Bearer '+access_token
        'x-trace-id':new Date - 0
        'x-request-id':uuid()
      }
      ...opt
    }
  )

api.post = (url, body)=>
  api url,{
    method: 'POST'
    body: JSON.stringify body
  }
