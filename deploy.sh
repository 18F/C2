#!/bin/bash
curl  -H "Accept: application/vnd.github.cannonball-preview+json" \
      -H "Authorization: token $GH_KEY" \
      -X POST --data "{ \"ref\":\"$1\", \"task\":\"deploy\", \"auto_merge\": false, \"required_contexts\": [], \"environment\" : \"$2\" }" \
      https://api.github.com/repos/18F/c2/deployments
