import os, errno
import subprocess
import time


OPENPOSEPATH = "openpose/bin/OpenPoseDemo.exe"


def run(vid_id):
    print(" [x] process_openpose run()" + vid_id)
    try:
        os.makedirs("tmp/json_" + vid_id)
    except OSError as e:
        if e.errno != errno.EEXIST:
            raise

    cmd = OPENPOSEPATH + " -video tmp/vid_rec_" + vid_id + ".mp4 -write_json tmp/json_" + vid_id + "/"

    # cmd = "sleep 5"

    process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE)
    output, error = process.communicate()

    print(" [x] DONE")

if __name__ == "__main__":
    run("test_" + str(time.time()))