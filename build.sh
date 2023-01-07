#!/bin/bash -x
docker build . -t gcr.io/linksnaps/ngircd:dev 
docker push gcr.io/linksnaps/ngircd:dev
