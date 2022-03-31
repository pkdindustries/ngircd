#!/bin/bash -x
docker build . -t gcr.io/ngircd/ngircd:dev 
docker push gcr.io/ngircd/ngircd:dev
