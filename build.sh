#!/bin/sh
DOCKER_BUILDKIT=1


docker build -t myregistry.com:5001/rescue-usb-maker .
# docker push myregistry.com:5001/resce-usb-maker

