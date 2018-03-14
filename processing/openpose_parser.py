import json
from PIL import Image, ImageDraw


def getpoints(fname):
    with open(fname, "r") as f:
        parsed = json.loads(f.read().replace('\n', ''))

        if len(parsed["people"]) == 0:
            print("Nobody in the image")
            return []
        else:
            points = []
            for person in parsed["people"]:
                l = person["pose_keypoints"]
                points.append([l[i:i+3] for i in range(0, len(l), 3)])

            return points
            # return parsed["people"][0]["pose_keypoints"]


def printNamed(points):
    names = [
        "Nose", "Neck", "RShoulder", "RElbow", "RWrist", "LShoulder", "LElbow",
        "LWrist", "RHip", "RKnee", "RAnkle", "LHip", "LKnee", "LAnkle",
        "REye", "LEye", "Rear", "LEar"
    ]

    for x in range(len(names)):
        print(names[x] + ":\t" + str(points[x]))


def drawOn(img, points, clr):
    draw = ImageDraw.Draw(img)
    r = 10

    for point in points:
        if point[0] != 0 and point[1] != 0:
            draw.ellipse([(point[0]-r, point[1]-r), (point[0] + r, point[1] + r)],
                        fill=clr, outline=clr)

    del draw

    return img

def drawAll():
    colors = ["#FF0000", "#00FF00", "#0000FF", "#FFFFFF"]

    for imid in range(1, 4201):
        print("Working on: %d, done: %d%%" % (imid, 100*imid/4201))

        points = getpoints("imgs/data_out_json/img_%d_keypoints.json" % imid)
        img = Image.open('imgs/img_%d.jpg' % imid)
        for x in range(len(points)):
            img = drawOn(img, points[x], colors[x % len(colors)])

        img.save('imgs/processed/img_%d.jpg' % imid)


imgid = 1
points = getpoints("imgs/data_out_json/img_%d_keypoints.json" % imgid)
print(points)

for p in points:
    print("PERSON ----------------")
    printNamed(p)
    print("")

# drawAll()
# print(getpoints("imgs/data_out_json/img_1_keypoints.json"))

relook_list = [
    2540,
    2527, 2528,
    2538,
    2526,
    10,
    20,
    29,
    47,
    59,
    65,
    77,
    91,
    103,
    104,
    105,
    141
]
"""
Images to look at for filtering stuff

 - 2540: Phantom third person
 - 2527, 2528: sides swap, make sure no clash
 - 2538: one body + phantom person
 - 2526: Phantom person in the corner
 - 10: phantom person in the middle
 - 20: Pantom double leg
 - 29: Phantom person on the side
 - 47: Phantom person other side
 - 59: Phantom double leg
 - 65: Phantom double leg
 - 77: Phantom person on the side
 - 91: Phantom person top mid
 - 103: Phantom person + disproportionate
 - 104: Disproportionate again
 - 105: Phantom person and disproportionate
 - 141: Double phantom legs
"""