
import localdb as db
from pony.orm import *
import json
import numpy as np

@db_session
def from_db(act, clgroup, vid_id=None, dblimit=None):
    raw = None

    if vid_id is None:
        raw = select(x for x in db.Sens if x.act==act)
    else:
        raw = select(x for x in db.Sens if x.vid_id==vid_id)

    done = []

    if dblimit is not None:
        raw = raw[:dblimit]

    for x in raw:
        try:
            grip = json.loads(x.grip)
            dist = [x.dist]
            proc_ = json.loads(x.processed)
            proc = proc_[8][0:2]+proc_[9][0:2]+proc_[10][0:2]+proc_[11][0:2]+proc_[12][0:2]+proc_[13][0:2]
            line = grip + dist + proc + [clgroup]
            
            done.append(line)

        except Exception as e:
            print("Error, likely invalid data in db. Don't use this dataset if many errors appear")

    return np.array(done)
    