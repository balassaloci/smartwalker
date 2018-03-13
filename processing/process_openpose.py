import os, errno
import subprocess
import time
from pony.orm import *
import localdb as db
import Queue
import threading


OPENPOSEPATH = "openpose/bin/OpenPoseDemo.exe"

def __runopenpose__(vid_id):
    # cmd = OPENPOSEPATH + " -video tmp/vid_rec_" + vid_id + ".mp4 -write_json tmp/json_" + vid_id + "/"
    cmd = "bin\\OpenPoseDemo.exe" + " -video ..\\tmp\\vid_rec_" + vid_id + ".mp4 -write_json ..\\tmp\\json_" + vid_id + "\\"

    cmd = "sleep 2"

    print(cmd)

    #os.chdir("openpose")
    process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()
    #os.chdir("..\\")

    if error is None:
        print("No error, removing original video file")
        # os.remove("tmp\\vid_rec_" + vid_id + ".mp4")
    else:
        print("error")


@db_session
def __run__(vid_id):
    print(" [x] process_openpose run()" + vid_id)

    try:
        os.makedirs("tmp/json_" + vid_id)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise
    
    __runopenpose__(vid_id)

    frames = os.listdir("tmp\\json_" + vid_id)

    dbentries = select(c for c in db.Sens if c.vid_id==vid_id).order_by(db.Sens.id)[:]

    for x in range(len(min(frames, dbentries))):
        with open("tmp\\json_" + vid_id + "\\" + frames[x], 'rb') as f:
            frame = f.read()
            dbentries[x].opose = frame

        # break

    print(" [x] DONE")

"""
def worker():
    while True:
        item = q.get()
        __run__(item)
        q.task_done()

q = Queue.Queue()
t = threading.Thread(target=worker)
t.daemon = True

def run(vid_id):
    if not t.is_alive():
        t.start()

    q.put(vid_id)
    """
def run(vid_id):
    __run__(vid_id)

if __name__ == "__main__":
    run("1520895486.49")
    run("1520895486.49")
    run("1520895486.49")
    run("1520895486.49")
    while True:
        print("i'm alive")
        time.sleep(1)
    q.join()       # block until all tasks are done