import numpy as np

import ml_knn
import ml_util
import Queue as queue
import threading
from pony.orm import *
import localdb as db
import time


conditions = ["normal_1", "parkinsons_1", "haemoplegic_1", "limp_right_1"]
conditions = ["r-norm-1", "r-park-1", "r-hemo-1"]
cond_ids = [1, 2, 3, 4]
# conditions = ["normal_1", "parkinsons_1"]
clgroups   = [float(x) for x in range(1, len(conditions) + 1)]

datas = []

for x in range(len(conditions)):
    datas.append(ml_util.from_db(conditions[x], float(x), dblimit=None))

training_data = np.concatenate(datas, axis=0)


def predict(vid_id):

    test_data = ml_util.from_db('', 0.0, vid_id, dblimit=None)
    prediction, confidence = ml_knn.knn_line(training_data, test_data, 1)


    return int(prediction), confidence

   
def worker():

    @db_session
    def store_event(patient, confidence, diagnosis, vid_id):
        start_stamp = min(x.timestamp for x in db.Sens if x.vid_id==vid_id)
        end_stamp = max(x.timestamp for x in db.Sens if x.vid_id==vid_id)

        x = db.Event(
            patient=patient,
            timestamp=end_stamp,
            measurement_from=start_stamp,
            measurement_to=end_stamp,
            confidence=confidence,
            diagnosis=diagnosis
        )
        
    while True:
        vid_id = q.get()
        print(" [x] processing: " + vid_id)
        prediction, confidence = predict(vid_id)
        prediction = int(prediction)

        print("Prediction for " + vid_id + ": " + conditions[prediction] + " confidence: " + str(confidence))

        if confidence > 0.8:
            print("Storing event")
            store_event(1, confidence, cond_ids[prediction], vid_id)
        else:
            print("Not confident enough, skipping event storage")

        print(' [x] processing: ' + vid_id + '\tDONE')
        q.task_done()

q = queue.Queue()

for i in range(1):
    t = threading.Thread(target=worker)
    t.daemon = True
    t.start()

# q.put('1520984019.17') # Normal
# q.put('1520984105.17') # Parkinsons
# q.put('1520984122.7')  # Parkinsons
# q.put('1520984159.55')  # Haemoplegic
# q.put('1520984168.5')  # Haemoplegic
# q.put('1520984266.24')  # Limp right


# q.join()       # block until all tasks are done

