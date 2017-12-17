FROM daangn/faiss:py3

RUN cd && mkdir .pip && echo "[global]\nindex-url=http://ftp.daumkakao.com/pypi/simple\ntrusted-host=ftp.daumkakao.com" > ./.pip/pip.conf
#RUN sed -i 's/archive.ubuntu.com/ftp.daumkakao.com/g' /etc/apt/sources.list

ENV GRPC_PYTHON_VERSION 1.4.0
RUN python3 -m pip install --upgrade pip
RUN pip3 install grpcio==${GRPC_PYTHON_VERSION} grpcio-tools==${GRPC_PYTHON_VERSION}

RUN mkdir -p /app
WORKDIR /app

RUN pip3 install pandas
RUN pip3 install gevent==1.2.2
RUN pip3 install click

# for click library
ENV LC_ALL C.UTF-8
ENV LANG C.UTF-8

ENTRYPOINT ["python3"]
CMD ["server.py"]

HEALTHCHECK --interval=3s --timeout=2s \
  CMD ls /tmp/status || exit 1

COPY *.py /app/
