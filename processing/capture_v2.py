import cv2
import time
from pony.orm import *
from datetime import datetime
import serial
import queue
import threading
import throttler

db = Database()

capdir = "imgs"

lab = "normfast"
note = "run"
maxframes = 500;

class SensCapture(db.Entity):
    """Info on the medical conditions we are able to measure"""
    timestamp = Required(datetime)
    sensordata = Required(str)
    imgname = Required(str)
    label = Required(str)
    note = Required(str)

@db_session
def storedb(timestamp, sensordata, imgname, label, note):
    x = SensCapture(
        timestamp=timestamp,
        sensordata=sensordata,
        imgname = imgname,
        label=label,
        note=note
    )


db.bind('postgres',
        user='postgres',
        password='postgres',
        host='192.168.99.100',
        port='32768')

db.generate_mapping(create_tables=True)

sr = serial.Serial(port='/dev/tty.usbmodem1411', baudrate=115200, timeout=0)

buffer = ""

lastmeasure =""

cam = cv2.VideoCapture(0)

time.sleep(1)

@db_session
def getMaxId():
    return max(x.id for x in SensCapture)

img_counter = getMaxId()
if img_counter is None:
    img_counter = 0
print(img_counter)

lasttime = time.time()
framedelay = 0.1
framecount = 0


while True:
    if framecount == maxframes:
        print("done")
        quit()


    try:
        #print("iterating")
        buffer += str(sr.readline())
        position = buffer.find("\n")

        if position >= 0:
            lastmeasure = buffer[:position]
            buffer = buffer[position + 1:]
            #print("no such sign")

        # time.sleep(0.0)
        if time.time() - lasttime > framedelay:
            print(lastmeasure)
            lasttime = time.time()
            ret, frame = cam.read()
            img_counter += 1
            img_name = capdir + "/img_{}.jpg".format(img_counter)
            cv2.imwrite(img_name, frame, [int(cv2.IMWRITE_JPEG_QUALITY), 20])
            storedb(datetime.now(), lastmeasure, img_name, lab, note)
            framecount += 1

    except serial.SerialTimeoutException as e:
        print(e)
        time.sleep(1)




print("done - sleeping")
time.sleep(10)
print('done')
quit()

############################################################################
#################### This is the end of everything #########################
############################################################################


sr = serial.Serial(port='/dev/tty.usbmodem1431', baudrate=115200, timeout=0)
buffer = ""
cam = cv2.VideoCapture(0)

time.sleep(1)

img_counter = 0     # TODO read from db

for _ in range(10):
    try:
        buffer += sr.readline()

        position = buffer.find("=")

        if position >= 0:
            print(buffer[:position])
            buffer = buffer[position + 1:]

    except serial.SerialTimeoutException as e:
        print(e)
        time.sleep(1)

    ret, frame = cam.read()
    img_counter += 1
    img_name = capdir + "/opencv_frame_{}.png".format(img_counter)
    cv2.imwrite(img_name, frame)

    #time.sleep(0.1)

cam.release()

print("hey")