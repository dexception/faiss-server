PORT=$1
if [[ -z "$PORT" ]]; then
  PORT="50051"
fi
TAG="latest"
ENV=""

if [[ "$PORT" == "50051" ]]; then
  TAG="v20190212"
  #ENV="-e OMP_NUM_THREADS=1"
  CMDS="server.py 0 --no-save --nprobe 100
      --save-path article.index --max-workers=1"
elif [[ "$PORT" == "50052" ]]; then
  TAG="v20190212"
  ENV="-e OMP_NUM_THREADS=1"
  CMDS="server.py 0 --no-save --nprobe 100
      --save-path article.index --max-workers=8"
else
  ENV="-e OMP_NUM_THREADS=1"
  CMDS="server2.py 0 --nprobe 100
      --save-path article.index"
fi

docker run --rm -it -v $(pwd):/app \
  --name "faiss-server-$PORT" \
  -p $PORT:50051 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  $ENV \
  daangn/faiss-server:$TAG $CMDS
  #-e OMP_WAIT_POLICY=PASSIVE \
