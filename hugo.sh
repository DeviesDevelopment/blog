#!/bin/sh

docker run \
        -p 1313:1313 \
        -v ${PWD}:/src \
        hugomods/hugo:exts-0.145.0 "$@"

