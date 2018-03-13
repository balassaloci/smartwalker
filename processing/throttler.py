import time
import sys


class Throttler:

    def __init__(self, fps, printer=False):
        self.__fps = fps
        self.__ddelay = 1.0 / (self.__fps * 1.15)
        self.__lasttimer = time.time()

        # printer related stuff
        self.__printer = printer
        self.__sendcount = 0
        self.__seccount = 0
        self.__actualfps = 0
        self.__sectimer = time.time()

    def iterate(self):
        adjustment = self.__ddelay - (time.time() - self.__lasttimer)
        if adjustment > 0:
            time.sleep(adjustment)

        self.__lasttimer = time.time()

        if self.__printer:
            self.__sendcount += 1
            self.__seccount += 1

            if time.time() - self.__sectimer >= 1.0:
                self.__actualfps = self.__seccount
                self.__seccount = 0
                self.__sectimer = time.time()

            print(' [.] Total: %d speed: %d fps\t\r' %
                             (self.__sendcount, self.__actualfps))
            # sys.stdout.write()

            # sys.stdout.flush()

