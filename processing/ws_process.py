from SimpleWebSocketServer import SimpleWebSocketServer, WebSocket
import cStringIO
from PIL import Image
import base64
import json
import random
import time
import localdb as db
from pony.orm import *
import datetime
import process_openpose as popose

@db_session
def save_measurements(measurements, vid_id):
    print(" [.] Starting to save measurements")
    # print(measurements)

    for m in measurements:
        # print(m)

        try:
            x = db.Sens(
                # patient=patient,
                timestamp=datetime.datetime.fromtimestamp(m["timestamp"]),
                grip=json.dumps([m["llean"],m["rlean"],m["lgrp"],m["rgrp"]]),
                dist=m["distance"],
                opose="",
                vid_id=vid_id
            )
        except Exception as e:
            print("unable to save: " + str(e))

    print(" [x] Done saving measurements")


class WsProcessor(WebSocket):

    def handleMessage(self):

        try:
            # echo message back to client
            # self.sendMessage("from server: " + self.data)
            print(" [x] received msg")

            jsontest = json.loads(self.data)

            video = jsontest["video"]
            vid_id = str(time.time())
            measurements = jsontest["measurements"]

            with open("tmp/vid_rec_%s.mp4" % vid_id, "wb") as f:
                f.write(video.decode('base64'))

            save_measurements(measurements, vid_id)

            print(" [x] video file written")

            popose.run(vid_id)


            # images = jsontest["images"]
            # print(len(images))
            # for x in range(len(images)):
            #     try:
            #         img_str = cStringIO.StringIO( base64.b64decode(images[x]))
            #         #print(jsontest["data"])
            #         img = Image.open(img_str)
            #         img.save("rec/rec_%d.jpg" % x)
            #     except Exception as e:
            #         print(e)
            #
            #img_str = cStringIO.StringIO( base64.b64decode(jsontest["img"]))
            # print(jsontest["data"])
            #img = Image.open(img_str)
            # img.show()
            # time.sleep(0.1)
            # img.close()

            # checksum = int(jsontest["data"])

            # making .1% of queries fail deliberately
            # if random.randint(1, 1000) == 10:
            #     checksum +=1

            self.sendMessage("got:" + str(0))


        except Exception as e:
            print(e)

    def handleConnected(self):
        print(self.address, ' [*] connected')

    def handleClose(self):
        print(self.address, ' [*] closed')

server = SimpleWebSocketServer('0.0.0.0', 8000, WsProcessor)
print(" [x] Server up and running")

server.serveforever()

