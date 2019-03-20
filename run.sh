PORT=$1
if [[ -z "$PORT" ]]; then
  PORT=50051
fi

docker run --rm -it -v $(pwd):/app \
  -p $PORT:50051 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  daangn/faiss-server server2.py 0 --debug --no-save --nprobe 100 \
    --save-path 20190320_060037.index --max-workers=1
    #--keys-path data/ids.txt --save-path s3://daangn/ml/temp/test.index

