#! env/bin/python
from flask import Flask, jsonify, abort
import time
import json
import localdb as db
from pony.orm import *
import datetime


app = Flask(__name__)


measurement = {
    "measurement_id": 1,
    "timestamp": time.time(),
    "grip": [0.0, 1.0, 0.0, 0.1],
    "distance": 1.0,
    "pose": [0.0]*18
    }

@app.errorhandler(404)
def page_not_found(e):
    return "404", 404

@app.errorhandler(500)
def page_not_found(e):
    return "500", 500 
        
@app.route('/getPatients', methods=['GET'])
@db_session
def getPatients():
    try:
        patients = [p.to_dict() for p in db.Patient.select()]
        return jsonify(patients)

    except Exception as e:
        abort(500)

@app.route('/getPatientData/<int:patient_id>', methods=['GET'])
@db_session
def getPatientData(patient_id):

    try:
        p = db.Patient.get(id=patient_id)

        if p is None:
            abort(404)
        else:
            return jsonify(p.to_dict())

    except Exception as e:
        abort(404)


@app.route('/getConditions', methods=['GET'])
@db_session
def getConditions():

    try:
        conditions = [c.to_dict() for c in db.Condition.select()]
        return jsonify(conditions)

    except Exception as e:
        abort(500)


@app.route('/getEvents/<int:patient_id>', methods=['GET'])
@db_session
def getEvents(patient_id):

    try:
        events =\
            [y.to_dict() for y in
             select(x for x in db.Event if x.patient == db.Patient[patient_id])
            ]

        return jsonify(events)

    except Exception as e:
        abort(404)

@app.route('/getLastEvent/<int:patient_id>', methods=['GET'])
@db_session
def getLastEvent(patient_id):

    #try:

    events = [y.to_dict() for y in select(x for x in db.Event if x.id==max(s.id for s in db.Event))]
    return jsonify(events[0])

    #except Exception as e:
    #    abort(404)


@app.route('/getMeasurements/<int:user_id>/<float:date_from>/<float:date_to>', methods=['GET'])
@db_session
def getMeasurements(user_id, date_from, date_to):

    date_from = datetime.datetime.fromtimestamp(date_from)
    date_to = datetime.datetime.fromtimestamp(date_to)
    
    def g(x):
        try:
            return {"distance": x.dist,
                    "grip": json.loads(x.grip),
                    "pose": json.loads(x.processed),
                    "timestamp": x.timestamp,
                    "id": x.id}
        except:
            return {"distance": x.dist,
                    "grip": [],
                    "pose": [],
                    "timestamp": x.timestamp,
                    "id": x.id}
            print(" [x] Unable to load jsons")

    
    # measurements = [g(x) for x in select(db.Sens if x.id < 800]
    measurements = [g(y) for y in select(x for x in db.Sens if x.timestamp >= date_from and x.timestamp <= date_to)]
    # measurements = [measurement, measurement, measurement]
    return jsonify(measurements)

@app.route('/getDistance/hour/<int:user_id>', methods=['GET'])
@db_session
def getDistanceHour(user_id):
    # s = select((raw_sql("date_trunc('hour', timestamp \"x\".dist)"), sum(x.dist)) for x in db.Sens)[:]
    # print(s)

    # select(p for p in Person if raw_sql('abs("p"."age") > 25'))
    # date_trunc(text, timestamp)
    # select((s.group, min(s.gpa), max(s.gpa)) for s in Student)
    return jsonify({})

if __name__ == '__main__':
    app.run(debug=True,
            threaded=True,
            host="0.0.0.0",
            port=8080)
