#!/bin/bash -x
TAG=${TAG:-dev}

docker build --platform linux/amd64 --push -t gcr.io/linksnaps/ngircd:"$TAG" .
