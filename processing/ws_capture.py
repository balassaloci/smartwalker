import cv2

import time
import base64
import json
import sensor_reader as sr
import async_uploader as uploader

cam = cv2.VideoCapture(0)


act = "test_xy"
reclen = 5
recrepeat = 1
delaybetween = 10

img_counter = 0

sr.run()

def captureAndSend(period):

    print(" [x] captureAndSend() starting")

    fourcc = cv2.VideoWriter_fourcc(*'X264')
    filename = "tmp/vid_cap_%d.mp4" % time.time()
    out = cv2.VideoWriter(filename, fourcc, 20.0, (720,720))
    measurements = []

    t = None

    while cam.isOpened():
        ret, frame = cam.read()

        frame = frame[0:720, 280:1000] # crop 720x720 mid

        if ret:

            if t is None:
                t = time.time()

            out.write(frame)

            lastmeasure = sr.getMeasurement()
            lastmeasure["act"] = act
            lastmeasure["meta"] = json.dumps(
                {"width": 720,
                 "height": 720,
                 "fps": 20}
            )

            measurements.append(lastmeasure)

            cv2.imshow('frame',frame)

            if time.time() - t > period:
                break

        else:
            break

    out.release()

    with open(filename, "rb") as videofile:

        tEnc = time.time()
        b64_video = base64.b64encode(videofile.read())
        tEnc = time.time() - tEnc
        print(" [x] Encoded file in %f" % tEnc)


        jsonmsg = json.dumps({"measurements": measurements, "video": b64_video})

        uploader.upload(jsonmsg)

    time.sleep(delaybetween)


for _ in range(recrepeat):
    print("")
    print(" [-] Running capture and send")
    captureAndSend(reclen)

# Release everything if job is finished
cam.release()
cv2.destroyAllWindows()
uploader.q.join()


