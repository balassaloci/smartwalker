#! env/bin/python
from flask import Flask, jsonify, abort
import time
import localdb as db
from pony.orm import *


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


@app.route('/getMeasurements/<int:user_id>/<float:date_from>/<float:date_to>', methods=['GET'])
def getMeasurements(user_id, date_from, date_to):
    
    measurements = [measurement, measurement, measurement]
    return jsonify(measurements)


if __name__ == '__main__':
    app.run(debug=False,
            threaded=True,
            host="0.0.0.0",
            port=8080)
