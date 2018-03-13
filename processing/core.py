import queue
import threading


"""

# Structure here

 - Multiple workers, one each for a sensory readings
   - A worker reads the sensor data
   - Stores data
   - Sends it to the appropriate queue for processing


"""


def worker():
    while True:
        item = q.get()
        print("item: %i" % item)
        q.task_done()


q = queue.Queue()


for i in range(4):
    t = threading.Thread(target=worker)
    t.daemon = True
    t.start()

for item in range(10):
    q.put(item)

q.join()       # block until all tasks are done
