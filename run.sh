#!/bin/sh
tag="2.187-slim"
docker build -t snyk-jenkins-docker-demo:$tag --build-arg jenkins_tag=$tag .
docker run --rm --name snykjenkins -d -p 9080:8080  snyk-jenkins-docker-demo:$tag

while [ "`docker inspect -f {{.State.Health.Status}} snykjenkins`" != "healthy" ]; do
    sleep 2;
done;

# Adding the Snyk api token
export token=`cat ~/.config/configstore/snyk.json | jq '.api'`
curl -X POST 'http://localhost:9080/credentials/store/system/domain/_/createCredentials' \
--data-urlencode 'json={
  "": "0",
  "credentials": { "scope": "GLOBAL", "id": "snyk", "token": '$token', "description": "snyk", "$class": "io.snyk.jenkins.credentials.DefaultSnykApiToken" } 
}'

# Adding Jenkins jobs
curl -s -XPOST 'http://localhost:9080/createItem?name=goof' --data-binary @resources/goof.xml -H "Content-Type:text/xml"
curl -s -XPOST 'http://localhost:9080/createItem?name=goof_with_build_step' --data-binary @resources/goof_with_build_step.xml -H "Content-Type:text/xml"

