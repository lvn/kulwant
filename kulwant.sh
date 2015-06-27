

build_status_line () {
  status=$1
  echo 'HTTP/1.1 $status'
}

build_headers () {
  for arg in $@; do
    echo $arg
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
  status_code=$1
  build_status_line $1
  build_headers
}

serve_page () {
  path=$1
  if [ -r $path ]; then
    content=$(cat $path)
    respond "$content"
  else
    respond_err 404
  fi
}

port=$1
path=$2
serve=1
trap "serve=0" SIGINT
while [ $serve -eq 1 ]; do
  serve_page $path | nc -l $port
done
