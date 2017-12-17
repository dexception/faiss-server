from __future__ import print_function
import os

import grpc
import numpy as np

import faissindex_pb2 as pb2
import faissindex_pb2_grpc as pb2_grpc


def run():
    host = 'localhost'
    port = 50051
    dim = 100
    print("host: %s:%d" % (host, port))

    channel = grpc.insecure_channel('%s:%d' % (host, port))
    stub = pb2_grpc.IndexStub(channel)

    response = stub.Total(pb2.EmptyRequest())
    print("total: %d" % response.count)

    id = 2
    response = stub.Search(pb2.SearchRequest(id=id, count=5))
    print("response: %s, %s" % (response.ids, response.scores))

    embedding = list(np.random.random((dim)).astype('float32'))
    id = 1
    response = stub.Add(pb2.AddRequest(id=id, embedding=embedding))
    print("response: %s" % response.message)

    embedding = list(np.random.random((dim)).astype('float32'))
    id = 1
    response = stub.Add(pb2.AddRequest(id=id, embedding=embedding))
    print("response: %s" % response.message)

    embedding = list(np.random.random((dim)).astype('float32'))
    id = 2
    response = stub.Add(pb2.AddRequest(id=id, embedding=embedding))
    print("response: %s" % response.message)

    embedding = list(np.random.random((dim)).astype('float32'))
    id = 3
    response = stub.Add(pb2.AddRequest(id=id, embedding=embedding))
    print("response: %s" % response.message)

    response = stub.Total(pb2.EmptyRequest())
    print("total: %d" % response.count)

    id = 2
    response = stub.Search(pb2.SearchRequest(id=id, count=5))
    print("response: %s, %s" % (response.ids, response.scores))

    response = stub.Remove(pb2.IdRequest(id=2))
    print("response: %s" % response.message)

    response = stub.Total(pb2.EmptyRequest())
    print("total: %d" % response.count)

    response = stub.Import(pb2.ImportRequest(embs_path='data/starspace_doc_emb_production.tsv', ids_path='data/starspace_doc_id_production.txt'))
    print("response: %s" % response.message)

    response = stub.Total(pb2.EmptyRequest())
    print("total: %d" % response.count)

    id = 2
    response = stub.Search(pb2.SearchRequest(id=id, count=5))
    print("response: %s, %s" % (response.ids, response.scores))


if __name__ == '__main__':
    run()
