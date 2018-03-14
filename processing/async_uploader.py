import time
import queue
import threading
from websocket import create_connection

# SERVER_URL = "ws://localhost:8000/"
SERVER_URL = "ws://34.224.3.38:8000/"
ws = create_connection(SERVER_URL)


def worker():
    while True:
        print(" [x] Websocket: Starting to send")
        item = q.get()
        ws.send(item)

        #time.sleep(5)
        print(" [x] Websocket: Sent")
        resp = ws.recv()

        print(" [x] Websocket: Response received")
        q.task_done()


q = queue.Queue()

t = threading.Thread(target=worker)
t.daemon = True
t.start()


def upload(item):
    print(" [x] Uploader adding file to queue: x")
    q.put(item)


#def upload(item):
#
#    print(" [x] Websocket: Starting to send")
#    ws.send(item)
#    print(" [x] Websocket: Sent")
#    resp = ws.recv()
#    print(" [x] Websocket: Response received")
