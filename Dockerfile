FROM python:3.7

RUN apt-get update -y
RUN apt-get install -y libopenblas-dev python-numpy python3-dev swig git python-pip wget
RUN apt-get install -y curl

RUN pip install matplotlib

RUN wget https://github.com/facebookresearch/faiss/archive/master.zip
RUN apt-get install -y unzip
RUN unzip master.zip
RUN rm master.zip && mv faiss-master /opt/faiss

WORKDIR /opt/faiss

RUN ./configure && \
    make -j $(nproc) && \
    make test && \
    make install

RUN make -C python build && \
    make -C python install

RUN cd && mkdir .pip && echo "[global]\nindex-url=http://ftp.daumkakao.com/pypi/simple\ntrusted-host=ftp.daumkakao.com" > ./.pip/pip.conf
#RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list

RUN mkdir -p /app
WORKDIR /app

RUN pip install pandas
RUN pip install gevent==1.4.0
RUN pip install click
RUN pip install boto3
RUN pip install --upgrade setuptools 2>/dev/null ; pip install google-cloud-storage

ENV GRPC_PYTHON_VERSION 1.19.0
RUN apt-get update && apt-get install -y build-essential
RUN pip install grpcio==${GRPC_PYTHON_VERSION} --no-binary grpcio
RUN pip install grpcio-tools

# for click library
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8

ENTRYPOINT ["python"]
CMD ["server.py"]

HEALTHCHECK --interval=3s --timeout=2s \
  CMD ls /tmp/status || exit 1

COPY *.py /app/
