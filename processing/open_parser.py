import json
import traceback

def massage(parsed, scale):

    final_person = [[0.0, 0.0, 0.0]] * 18

    def preprocess_person(person):
        l = person['pose_keypoints']
        # print(l)
        return [l[i:i+3] for i in range(0, len(l), 3)]

    def scale_person(person, scale):
        # print(person)
        return [[l[0] * scale, l[1] * scale, l[2]] for l in person]

    # No massage for one man teams
    if len(parsed["people"]) == 1:
        return scale_person(preprocess_person(parsed["people"][0]), scale)
    
    elif len(parsed["people"]) == 0:
        return final_person #empty matx

    mid = 1.0 / scale / 2.0

    names = [
        "Nose", "Neck", "RShoulder", "RElbow", "RWrist", "LShoulder", "LElbow",
        "LWrist", "RHip", "RKnee", "RAnkle", "LHip", "LKnee", "LAnkle",
        "REye", "LEye", "Rear", "LEar"
    ]

    # for simplified lookups
    n = {names[x]: x for x in range(len(names))}
    # print(n)

    def getHeight(feet):
        return max(feet["ankle"][1] - feet["hip"][1], 0)
    
    def distFromMid(feet, mid):
        return abs(feet["hip"][0] - mid) + abs(feet["knee"][0] - mid) + abs(feet["ankle"][0] - mid)

    def getLFeet(person, mid):
        f = {"hip": person[n["LHip"]], "knee": person[n["LKnee"]], "ankle": person[n["LAnkle"]]}
        # print(person, f)
        f["height"] = getHeight(f)
        f["distMid"] = distFromMid(f, mid)
        return f

    def getRFeet(person, mid):
        f = {"hip": person[n["RHip"]], "knee": person[n["RKnee"]], "ankle": person[n["RAnkle"]]}
        # print(f)
        f["height"] = getHeight(f)
        f["distMid"] = distFromMid(f, mid)
        return f

    feet = []
    for person_iter in parsed["people"]:
        person = preprocess_person(person_iter)
        # print(person)

        f = getLFeet(person, mid)
        # print(f["height"])
        if f["height"] > 0:
            feet.append(f)

        f = getRFeet(person, mid)

        # print(f["height"])
        if f["height"] > 0:
            feet.append(f)

    feet = sorted(feet, key=lambda r: r["height"]) [:2] # using the two largest
    # print(feet)

    if len(feet) < 2:
        return scale_person(final_person, scale)

    f = [[0.0, 0.0, 0.0] ] * 18
    # print(f)

    if feet[0]["knee"] > feet[1]["knee"]: # feet 0 is on the left
        f[n["LHip"]], f[n["LKnee"]], f[n["LAnkle"]] = feet[0]["hip"], feet[0]["knee"], feet[0]["ankle"]
        f[n["RHip"]], f[n["RKnee"]], f[n["RAnkle"]] = feet[1]["hip"], feet[1]["knee"], feet[1]["ankle"]
    else:
        a, b, c =  feet[1]["hip"], feet[1]["knee"], feet[1]["ankle"]
        f[n["LHip"]], f[n["LKnee"]], f[n["LAnkle"]] = a, b, c
        f[n["RHip"]], f[n["RKnee"]], f[n["RAnkle"]] = feet[0]["hip"], feet[0]["knee"], feet[0]["ankle"]

    return scale_person(f, scale)

def parse(raw, scale):
    #print(raw)

    parsed = json.loads(raw)

    return massage(parsed, scale)

    # if len(parsed["people"]) == 0:
    #     print(" [x] Parser: Nobody in the image")
    #     return []
    # else:
    #     l = parsed["people"][0]["pose_keypoints"]
    #     return [[l[i] * scale, l[i+1] * scale, l[i+2]]
    #             for i in range(0, len(l), 3)]


def sweepdb():
    import localdb as db
    from pony.orm import db_session, select

    @db_session
    def runall():
        # measures = [db.Sens[7921]]
        # measures = db.Sens.select(.Sens.vid_id="1520963375.43")
        # measures = db.Sens.select(x for x in db.Sens if 
        # measures = select(x for x in db.Sens if x.vid_id=="1520963375.43")
        measures = db.Sens.select()

        i = 100
        emptyc = 0
        leggedc = 0
        twolegged = 0

        for m in measures:
            try:
                raw = m.opose
                scale = 1.0 / json.loads(m.meta)['width']

                if len(raw)>5:
                    parsed = parse(m.opose, scale)
                    summedlegs = sum(1 for x in parsed if x[0] > 0.001) / 3
                    if summedlegs > 1:
                        twolegged += 1
                    elif summedlegs == 0:
                        emptyc += 1
                    else:
                        leggedc += 1

                    m.processed = json.dumps(parse(m.opose, scale))
                
                else:
                    emptyc += 1

                # else:
                    # print("Line too short for json: " + raw)
            except Exception:
                print(traceback.format_exc())

        print("Empty: %i\t\t Legged: %i \t\t TwoLegged: %i" % (emptyc, leggedc, twolegged))

    
    runall()


if __name__ == '__main__':
    sweepdb()
