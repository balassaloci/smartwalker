import cv2
# from cv2 import cv

import time
import serial
import base64
import json
from websocket import create_connection
import throttler
#import sensor_reader as sr
import sensor_reader as sr
import datetime
import async_uploader as uploader
from scipy import ndimage

cam = cv2.VideoCapture(0)

# sr = serial.Serial(port='/dev/tty.usbmodem1411', baudrate=115200, timeout=0)

# SERVER_URL = "ws://localhost:8000/"
# SERVER_URL = "ws://52.201.220.72:8000/"

act = "test_xy"
reclen = 5
recrepeat = 1
delaybetween = 10

# lasttime = time.time()
# framedelay = 0.1
img_counter = 0
# maxframes = 10

#ws = create_connection(SERVER_URL)
sr.run()

#print(" [x] Connected to: " + SERVER_URL)

def captureAndSend(period):

    print(" [x] captureAndSend() starting")

    fourcc = cv2.VideoWriter_fourcc(*'X264')
    filename = "tmp/vid_cap_%d.mp4" % time.time()
    out = cv2.VideoWriter(filename, fourcc, 20.0, (720,720))
    measurements = []

    t = None

    # print(" [.] Starting capture")

    # buffer = "" # serial buffer
    # lastmeasure = {}
    # distancesince = 0.0

    while cam.isOpened():
        # print(" [x] doing cam stuff")

        ret, frame = cam.read()

        # print(" [x] cap frame")

        frame = frame[0:720, 280:1000] # crop 720x720 mid
        #frame = ndimage.rotate(frame, 90)

        # frame = frame[0:720, 280:1000] # crop 720x720 mid

        # position = 1
        # while position >= 0:
        # buffer = " "*10
        """while len(buffer) > 5:

            buffer = str(sr.readline())
            #position = buffer.find("\n")

            #if position >= 0:
            try:
                # time.sleep(0.01)
                # print(buffer[:position])

                print(" - Starting to load measurement")

                # measure = json.loads(buffer[:position])
                measure = json.loads(buffer)
                distancesince += measure["distance"]
                lastmeasure = measure
                lastmeasure["timestamp"] = time.time()
                lastmeasure["distance"] = distancesince

                print(" - DONE")
            except Exception as e:
                print(e)

            # lastmeasure = buffer[:position]
            # buffer = buffer[position + 1:]

            # time.sleep(0.1)"""

        if ret:
            # print(" [x] ret is ok")

            if t is None:
                t = time.time()

            out.write(frame)

            # print(" [x] saved frame")
            lastmeasure = sr.getMeasurement()
            lastmeasure["act"] = act
            lastmeasure["meta"] = json.dumps(
                {"width": 720,
                 "height": 720,
                 "fps": 20}
            )

            # print(" [x] got last measurement")
            measurements.append(lastmeasure)

            # print(" [x] Measurement: " + str(lastmeasure))
            #distancesince = 0.0

            # if len(lastmeasure) > 0:
            #     measurements.append(lastmeasure)
            # else:
            #     print(" [x] Skipping add of measurement")

            cv2.imshow('frame',frame)

            if time.time() - t > period:
                break

            # if cv2.waitKey(1) & 0xFF == ord('q'):
            #     break

        else:
            break

    out.release()

    # print(" [x] Finished capture")

    with open(filename, "rb") as videofile:

        tEnc = time.time()
        b64_video = base64.b64encode(videofile.read())
        tEnc = time.time() - tEnc
        print(" [x] Encoded file in %f" % tEnc)

        #print(" [x] Sending video file")
        #tSend = time.time()

        # print(measurements)

        jsonmsg = json.dumps({"measurements": measurements, "video": b64_video})

        uploader.upload(jsonmsg)
        #ws.send(jsonmsg)

        #tSend = time.time() - tSend
        #print(" [x] Video file sent in %f" % tSend)

        #tResp = time.time()

        #resp = ws.recv()

        #tResp = time.time() - tResp

        #print(" [x] Response received in %f" % tResp)

    time.sleep(delaybetween)


for _ in range(recrepeat):
    print("")
    print(" [-] Running capture and send")
    captureAndSend(reclen)

# Release everything if job is finished
cam.release()
cv2.destroyAllWindows()
uploader.q.join()

quit()
##############################################


# sr = serial.Serial(port='/dev/tty.usbmodem1431', baudrate=115200, timeout=0)

# thro = throttler.Throttler(fps=10, printer=True)

images = []

t = time.time()

for _ in range(100):
    ret, frame = cam.read()
    ret, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 20])
    encodedimg = base64.b64encode(buffer)
    images.append(encodedimg)
    thro.iterate()

jsonmsg = json.dumps({"data": 123, "images": images})

t = time.time() - t

print("Image taking done in %f" % t)

t2 = time.time()
ws.send(jsonmsg)

t2 = time.time() - t2
resp = ws.recv()
print("Image sending done in %f" % t2)


print("")

quit()


time.sleep(1)
while True:
    if img_counter == maxframes:
        print("done")
        quit()

    try:
        # buffer += str(sr.readline())
        # position = buffer.find("\n")

        # if position >= 0:
        #     lastmeasure = buffer[:position]
        #     buffer = buffer[position + 1:]
        #     #print("no such sign")

        # time.sleep(0.0)
        # print("Captured frame # %d" % img_counter)
        # lasttime = time.time()
        ret, frame = cam.read()
        ret, buffer = cv2.imencode('.jpg', frame, [int(cv2.IMWRITE_JPEG_QUALITY), 20])
        encodedimg = base64.b64encode(buffer)
        jsonmsg = json.dumps({"img": encodedimg, "data":"0"})
        ws.send(jsonmsg)
        resp = ws.recv()
        img_counter += 1
        print("done")

        # thro.iterate()
            # img_name = capdir + "/img_{}.jpg".format(img_counter)
            # cv2.imwrite(img_name, frame)
            # storedb(datetime.now(), lastmeasure, img_name, lab, note)
            # img_counter += 1

    except Exception as e:
        print(e)
        time.sleep(1)

