
import serial
import time


sr = serial.Serial(port='/dev/tty.usbmodem1431', baudrate=115200, timeout=0)

buffer = ""

while True:
    try:
        #print("iterating")
        buffer += str(sr.readline())
        position = buffer.find("\n")

        if position >= 0:
            print(buffer[:position])
            buffer = buffer[position + 1:]
            #print("no such sign")

        time.sleep(0.1)

    except serial.SerialTimeoutException as e:
        print(e)
        time.sleep(1)

