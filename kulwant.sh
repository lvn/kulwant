#!/bin/bash

cleanup () {
  serve=0
  rm -r $KULWANT_TMP
  exit 0
}

get_status_msg () {
  status=$1
  echo ''
}

build_status_line () {
  status=$1
  status_msg=$(get_status_msg $status)
  echo "HTTP/1.1 $status $status_msg"
}

parse_headers () {
  echo ''
}

build_headers () {
  headers=$1
  for arg in $1; do
    echo "$arg: ${headers[\"$arg\"]}"
  done
  echo ''
}

respond () {
  content=$1
  build_status_line 200
  build_headers
  echo $content
}

respond_err () {
  status=$1
  build_status_line $status
  build_headers
  echo "There was an error with your request"
}

serve_file () {
  path=$1
  path_index="${path%%\/}/index.html"
  if [ -r $path ] && [ -f $path ]; then
    content=$(cat $path)
    respond "$content"
  elif [ -r $path_index ] && [ -f $path_index ]; then
    content=$(cat $path_index)
    respond "$content"
  else
    respond_err 404
  fi
}

parse_request () {
  reqline=(`echo $1`)  # hack: this will split the reqline by spaces.
  method=${reqline[0]}
  _path=${reqline[1]}
  path="$serve_root/${_path##/}"

  # TODO: parse headers and stuff
}

handle_request () {
  read req
  parse_request "$req"

  # handle route
  serve_file $path
}


trap "cleanup" SIGINT

port=$1
serve_root=$2
serve=1

KULWANT_TMP="/tmp/kulwant"
[[ -d "$KULWANT_TMP" ]] || mkdir "$KULWANT_TMP"
req_fifo="$KULWANT_TMP$(date +%s)$$"
mkfifo $req_fifo

while [ $serve -eq 1 ]; do
  cat $req_fifo | nc -l $port | (
    handle_request > $req_fifo
  )
done
