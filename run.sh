PORT=$1
if [[ -z "$PORT" ]]; then
  PORT="50051"
fi
TAG="latest"

if [[ "$PORT" == "50051" ]]; then
  TAG="v20190212"
  CMDS="server.py 0 --debug --no-save --nprobe 100
      --save-path article.index --max-workers=8"
else
  CMDS="server2.py 0 --debug --nprobe 100
      --save-path article.index"
fi

docker run --rm -it -v $(pwd):/app \
  --name "faiss-server-$PORT" \
  -p $PORT:50051 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  daangn/faiss-server:$TAG $CMDS
