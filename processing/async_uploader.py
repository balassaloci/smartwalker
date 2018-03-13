import time
import queue
import threading
from websocket import create_connection

SERVER_URL = "ws://localhost:8000/"
# SERVER_URL = "ws://52.201.220.72:8000/"
ws = create_connection(SERVER_URL)


def worker():
    while True:
        print(" [x] Websocket: Starting to send")
        item = q.get()
        ws.send(item)

        print(" [x] Websocket: Sent")
        resp = ws.recv()

        print(" [x] Websocket: Response received")
        q.task_done()
        time.sleep(0.5)


q = queue.Queue()

t = threading.Thread(target=worker)
t.daemon = True
t.start()


#def upload(item):
#    print(" [x] Uploader adding file to queue")
#    q.put(item)
#
#    if not t.is_alive():
#        t = threading.Thread(target=worker)
#        t.daemon = True
#        t.start()

def upload(item):

    print(" [x] Websocket: Starting to send")
    ws.send(item)
    print(" [x] Websocket: Sent")
    resp = ws.recv()
    print(" [x] Websocket: Response received")
