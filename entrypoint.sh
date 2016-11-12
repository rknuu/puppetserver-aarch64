#!/bin/sh

/bin/run-parts /entrypoint.d
exec "$@"
