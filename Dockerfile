FROM ubuntu:16.04

RUN apt-get update && apt-get install -y curl
RUN curl -O https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN apt-get install -y bzip2
RUN bash Miniconda3-latest-Linux-x86_64.sh -b && \
      rm Miniconda3-latest-Linux-x86_64.sh

#RUN conda install python=3.7
RUN conda install faiss-cpu==1.5.0 -c pytorch

RUN cd && mkdir .pip && echo "[global]\nindex-url=http://ftp.daumkakao.com/pypi/simple\ntrusted-host=ftp.daumkakao.com" > ./.pip/pip.conf
#RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list

RUN mkdir -p /app
WORKDIR /app

RUN python -m pip install --upgrade pip
RUN pip install pandas
RUN pip install gevent==1.4.0
RUN pip install click
RUN pip install boto3
RUN pip install --upgrade setuptools 2>/dev/null ; pip install google-cloud-storage

ENV GRPC_PYTHON_VERSION 1.19.0
RUN apt-get update && apt-get install -y build-essential
RUN pip install grpcio==${GRPC_PYTHON_VERSION} --no-binary grpcio
RUN pip install grpcio-tools==${GRPC_PYTHON_VERSION}

# 아래 블럭 정리 필요
#RUN pip uninstall -y grpcio
#RUN apt-get update && apt-get install -y python-dev
#RUN apt-get install -y python3-dev
#RUN apt-get install -y build-essential
#RUN pip install grpcio --no-binary grpcio

# for click library
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ENTRYPOINT ["python"]
CMD ["server.py"]

HEALTHCHECK --interval=3s --timeout=2s \
  CMD ls /tmp/status || exit 1

COPY *.py /app/
