# SmartWalker

This repository contains code for the module: EE4-67 Mobile Healthcare and Machine Learning by Professor Yiannis Demiris.

Gait  and  balance  disorders  in  the  elderly  are  associated  with  increased morbidity and mortality, as well as being a major cause of falls. Our device aims to monitor patient health progression over time by extending a walking aid a patient might use rather than having to attach special sensors to the patient.

## Directory explanation

 - `api`: REST API queried by the smartphone companion app. Run it by calling `./app.py`
 - `app`: iOS companion app source code
 - `onboard`: Arduino source code used for the grip and distance measurements
 - `processing`: Sensing and processing all data
   - `ws_capture.py`: Client application running on the device capturing and sending sensor measurements and video snippets
   - `ws_process.py`: Server code receiving a measurements and triggering the data processing workflow
   - `process_openpose.py`: Process video file through openpose and store results
   - `ml_processor.py`: Run machine learning on a specific snippet already in the database
 - `server`: Not used, code is in `processing`

## Git usage

The master branch is protected, meaning you can't directly push there. Create a separate work branch for your stuff and submit a pull request from there to the master making sure someone else from the team reviews the submission.
