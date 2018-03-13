import numpy as np
import cv2
import time

cap = cv2.VideoCapture(0)

# Define the codec and create VideoWriter object
fourcc = cv2.VideoWriter_fourcc(*'MJPG')
out = cv2.VideoWriter('test_%d.mjpg' % time.time(), fourcc, 20.0, (720,720))

t = None

while cap.isOpened():

    ret, frame = cap.read()
    # frame = frame[280:1001, 0:721]
    frame = frame[0:720, 280:1000]

    if ret:

        if t is None:
            t = time.time()
        # frame = cv2.flip(frame,0)

        # write the flipped frame
        out.write(frame)

        cv2.imshow('frame',frame)

        if time.time() - t > 10:
            break

        if cv2.waitKey(1) & 0xFF == ord('q'):
            break
    else:
        break

# Release everything if job is finished
cap.release()
out.release()
cv2.destroyAllWindows()