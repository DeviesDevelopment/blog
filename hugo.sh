#!/bin/sh

HUGO_VERSION="0.145.0"

docker run \
        --name devies-blog \
        --rm \
        -p 1313:1313 \
        -v ${PWD}:/src \
        hugomods/hugo:exts-"$HUGO_VERSION" "$@"

