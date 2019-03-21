from __future__ import print_function
import os
import logging
import atexit
from time import time
from multiprocessing import Pool

import click
import grpc
import numpy as np

import faissindex_pb2 as pb2
import faissindex_pb2_grpc as pb2_grpc

@click.group()
def cli():
    pass

_PROCESS_COUNT = 8

_worker_channel_singleton = None
_worker_stub_singleton = None
_timeout = None

_LOGGER = logging.getLogger(__name__)

def _shutdown_worker():
    _LOGGER.info('Shutting worker process down.')
    if _worker_channel_singleton is not None:
        _worker_channel_singleton.stop()

def _initialize_worker(server_address, timeout):
    global _worker_channel_singleton  # pylint: disable=global-statement
    global _worker_stub_singleton  # pylint: disable=global-statement
    global _timeout
    _LOGGER.info('Initializing worker process.')
    _worker_channel_singleton = grpc.insecure_channel(server_address)
    _worker_stub_singleton = pb2_grpc.ServerStub(_worker_channel_singleton)
    _timeout = timeout
    atexit.register(_shutdown_worker)

def _run_worker_query(primality_candidate):
    t = time()
    _LOGGER.info('query primality of %s.', primality_candidate)
    response = _worker_stub_singleton.Total(pb2.EmptyRequest(), timeout=_timeout)
    return time() - t

@click.command()
@click.option('-h', '--host', default='localhost:50051', help='server host:port')
@click.option('-t', '--timeout', default=0.1, help='request timeout')
@click.option('-c', '--count', default=100, help='requests count')
def total(host, timeout, count):
    print("host: %s" % host)

    p = Pool(processes=_PROCESS_COUNT,
            initializer=_initialize_worker,
            initargs=(host, timeout))

    t = time()
    result = p.map(_run_worker_query, range(count))
    result = list(result)
    print(time() - t)
    print(np.array(result).mean())


if __name__ == '__main__':
    cli.add_command(total)
    cli()
