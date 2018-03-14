import time


def getMeasurement():
    return {"distance": 0.0,
            "timestamp":time.time(),
            "llean":0.0,
            "rlean":0.0,
            "lgrp": 0.0,
            "rgrp": 0.0,
            }


def run(printer=False):
    print(" [x] Running MOCK sensor reader")
    pass

if __name__ == "__main__":
    pass
