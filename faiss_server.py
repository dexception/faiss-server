import logging

import numpy as np
from pandas import read_csv

from faiss_index import FaissIndex
import faissindex_pb2 as pb2
import faissindex_pb2_grpc as pb2_grpc

class FaissServer(pb2_grpc.IndexServicer):
    def __init__(self, dim, save_path):
        logging.debug('dim: %d', dim)
        logging.debug('save_path: %s', save_path)
        self._save_path = save_path
        self._index = FaissIndex(dim, save_path)
        logging.debug('ntotal: %d', self._index.ntotal())

    def Total(self, request, context):
        return pb2.TotalResponse(count=self._index.ntotal())

    def Add(self, request, context):
        logging.debug('add - id: %d', request.id)
        xb = np.expand_dims(np.array(request.embedding, dtype=np.float32), 0)
        ids = np.array([request.id], dtype=np.int64)
        self._index.replace(xb, ids)

        return pb2.SimpleResponse(message='Added, %d!' % request.id)

    def Remove(self, request, context):
        logging.debug('remove - id: %d', request.id)
        ids = np.array([request.id], dtype=np.int64)
        removed_count = self._index.remove(ids)

        if removed_count < 1:
            return pb2.SimpleResponse(message='Not existed, %s!' % request.id)
        return pb2.SimpleResponse(message='Removed, %s!' % request.id)

    def Search(self, request, context):
        logging.debug('search - id: %d', request.id)
        D, I = self._index.search_by_id(request.id, request.count)
        return pb2.SearchResponse(ids=I[0], scores=D[0])

    def Restore(self, request, context):
        logging.debug('restore - %s', request.save_path)
        self._save_path = request.save_path
        self._index.restore(request.save_path)
        return pb2.SimpleResponse(message='Restored, %s!' % request.save_path)

    def Import(self, request, context):
        logging.debug('importing - %s, %s', request.embs_path, request.ids_path)
        df = read_csv(request.embs_path, delimiter="\t", header=None)
        X = df.values
        df = read_csv(request.ids_path, header=None)
        ids = df[0].values
        logging.debug('%s', ids)

        X = np.ascontiguousarray(X, dtype=np.float32)
        ids = np.ascontiguousarray(ids, dtype=np.int64)

        self._index.replace(X, ids)
        return pb2.SimpleResponse(message='Imported, %s, %s!' % (request.embs_path, request.ids_path))

    def stop(self):
        logging.debug('saving index to %s', self._save_path)
        self._index.save(self._save_path)

