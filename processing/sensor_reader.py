
import serial
import time
import threading
import json

x = "empty"
distsum = 0.0


def worker():
    sr = serial.Serial(port='/dev/tty.usbmodem1411', baudrate=115200, timeout=0)

    buffer = ""
    global x
    global distsum

    while True:
        try:
            #print("iterating")
            buffer += str(sr.readline())
            position = buffer.find("\n")

            if position >= 0:
                # print(buffer[:position])

                x = json.loads(buffer[:position])
                x["timestamp"] = time.time()
                distsum += x["distance"]


                buffer = buffer[position + 1:]
                #print("no such sign")

            # time.sleep(0.1)

        except serial.SerialTimeoutException as e:
            print(e)
            time.sleep(1)

        except Exception as e:
            buffer = ""
            print(" [e] sensor_reader: ")
            print(e)


def getMeasurement():

    global distsum
    global x

    try:
        measurement = x
        measurement["distance"] = distsum
        distsum = 0
        return measurement

    except Exception as e:
        print(e)

        return {}


def run(printer=False):
    t = threading.Thread(target=worker)
    t.daemon = True
    t.start()


if __name__ == "__main__":
    run(True)

    while True:
        time.sleep(0.1)
        print(getMeasurement())


