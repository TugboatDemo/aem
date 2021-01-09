#!/bin/bash

CRX=/opt/aem/author/crx-quickstart

function timeout() {
  perl -e 'alarm shift; exec @ARGV' "$@"
}

function returnsCode() {
  local url=${1:-http://localhost:4502}
  local code=${2:-500}
  local status=$(curl --head --location --connect-timeout 5 --write-out %{http_code} --silent --output /dev/null ${url})
  [[ $status == ${code} ]]
}

export -f returnsCode

if [ "$1" == "quickstart" ]; then
  CRX/bin/quickstart > /dev/null 2>&1 & disown
fi

if [ "$1" == "stop" ]; then
  CRX/bin/stop
  timeout 60 bash -c 'until returnsCode http://localhost:4502 000; do sleep 0.5; done'
fi

if [ "$1" == "start" ]; then
  CRX/bin/start
  timeout 60 bash -c 'until returnsCode http://localhost:4502 401; do sleep 0.5; done'
fi

if [ "$1" == "status" ]; then
  CRX/bin/status
fi

if [ "$1" == "log" ]; then
  tail -f CRX/logs/error.log
fi

if [ "$1" == "install" ]; then
  cp "${@:2}" CRX/install/
fi

if [ "$1" == "restart" ]; then
  CRX/bin/stop
  timeout 60 bash -c 'until returnsCode http://localhost:4502 000; do sleep 0.5; done'
  CRX/bin/start
  timeout 60 bash -c 'until returnsCode http://localhost:4502 401; do sleep 0.5; done'
fi
