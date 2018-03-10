import serial
import time
ser = serial.Serial("COM6", 115200, timeout=0)


buffer = ''
while 1:
    try:
        buffer = buffer + ser.readline()
        position = buffer.find('}')
        if position >=0:
            print buffer[:position+1]
            buffer = buffer[position+1:]
    except ser.SerialTimeoutException:
        print('Data could not be read')
        time.sleep(1)
