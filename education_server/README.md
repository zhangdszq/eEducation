# eEducation (Server)

## Quickstart

Must create a developer account at [Agora.io](https://dashboard.agora.io/signin) to get your own appid and fill it and other config in `.env`

Then just build with docker! ([Why?](#why-docker))

## How to startup

After clone this repo and clone agora-rtm-nodejs as submodule (use git submodule update), follow steps bellow to startup a test service:  
- Set environment parameter by modifing education_server/.env, for detail:  
  - AGORA_APPID: Get this from agora.io  
  - SERVER_PORT: Port for service to listen to, for example, 8080  
  - REDIS_HOST: Since we use docker-compose at test phase, you can just fill in with 'redis'. However, if you are deploying this service to production environment, please modify this value to the host of your redis server , xx.xx.xx.xx  
  - REDIS_PORT: Port which used by redis server, default to be 6379, modify it according to yourself  
- Run `docker-compose up` under /education_server and your service start to work  

<a id="why-docker">

## Why docker
This service depends on agora-rtm-nodejs which requires a Linux with node-gyp environment, and you have to download agora rtm linux sdk before doing build. So we use a dockerfile to simplify these steps.
