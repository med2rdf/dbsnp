#!/bin/bash

set -e

if [ "$1" = 'dbsnp-rdf' ]; then
  exec bundle exec "$@"
elif [ "$1" = 'convert' -o "$1" = 'ontology' ]; then
  exec bundle exec dbsnp-rdf "$@"
fi

exec "$@"
