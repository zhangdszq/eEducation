#!/bin/sh
deployDir=/home/devops/web_demo/project/education_web
ServerName=${@:$OPTIND:1}

Rev="$(git rev-parse HEAD)"

echo $Rev
cd build
rsync -rvz -e 'ssh -p 20220' --delete --progress -h --exclude=.* --exclude=*.sh . $ServerName:$deployDir

echo service deployed on:$ServerName:$deployDir
