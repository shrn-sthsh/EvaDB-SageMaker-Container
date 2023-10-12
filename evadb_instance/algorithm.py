# This file that implements a flask server to do inferences
# Implement EvaDB use case here

import json
import flask
import evadb

# The flask app to serve use cases
app = flask.Flask(__name__)
@app.route('/invocations', methods = ['POST'])
def algorithm():
    '''---------------------- Implement EvaDB use case ----------------------'''
    cursor = evadb.connect().cursor()

    ## Sample flask response
    # response = {}
    # return flask.Response(
    #     response = json.dumps(response),
    #     status = 200, 
    #     mimetype = 'application/json'
    # )
