'''
This file that implements a flask server to do inferences on sample data

Change algorithm as needed for diffrent applications.
'''

# OS level imports
import os
from io import StringIO, BytesIO

# Application imports
import flask

# Data Imports
import json
import pandas as pd

# EvaDB
import evadb

# Data Parser
class parser(object):
    @staticmethod
    def parse(type: str, file) -> pd.DataFrame:
        if type == "application/json":
            return pd.DataFrame(file.json)
        
        elif type == "text/csv":
            return pd.read_csv(StringIO(file.data.decode('utf-8')), header = 0)
        
        elif type == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" or "application/vnd.ms-excel":
            return pd.read_excel(BytesIO(file.data), header = 0)
        
        else:
            raise TypeError("Unknown data file type")


# Flask app to serve predictions on sample 
app = flask.Flask(__name__)

@app.route('/ping', methods = ['GET'])
def ping():
    try:
        if not os.path.exists("/app/learning/input/data/"):
            raise IOError
        response = "Success"
        status = 200

    except Exception as exception:
        response = str(exception)
        status = 404
    
    return flask.Response(
        response = response, 
        status = status, 
        mimetype = "application/json"
    )


@app.route('/invocations', methods = ['POST'])
def run():
    '''----------------------- Sample EvaDB use case -----------------------'''
    '''
    Postgress Initialization

    1. install postgress
    2. start postgress
    3. create base user
    4. create base table
    '''
    os.system("apt -qq install postgresql")
    os.system("service postgresql start")

    os.system("sudo -u postgres psql -c \"CREATE USER eva WITH SUPERUSER PASSWORD 'password'\"")
    os.system("sudo -u postgres psql -c \"CREATE DATABASE evadb\"")


    ''' 
    Install EvaDB extensions
    '''
    os.system("""
        %pip install --quiet \"evadb[postgres,forecasting] 
        @ git+https://github.com/georgia-tech-db/evadb.git@68265d3b138babfe4a20091bc5fa7a67b56072f5\"
    """)
    cursor = evadb.connect().cursor()


    ''' Create Data Source in EvaDB

    We use data source to connect EvaDB directly to underlying 
    database systems like Postgres.
    '''
    params = {
        "user": "eva",
        "password": "password",
        "host": "localhost",
        "port": "5432",
        "database": "evadb",
    }
    query = f"""
        CREATE DATABASE postgres_data WITH ENGINE = 'postgres', 
        PARAMETERS = {params};
    """
    cursor.query(query)


    """ Load the Datasets

    We load the House Property Sales Time Series into our PostgreSQL database.
    (https://www.kaggle.com/datasets/htagholdings/property-sales?resource=download)
    """
    if not os.path.isdir("/app/learning/input/data"):
        if not os.path.isdir("/app"):
            os.mkdir("/app")
        if not os.path.isdir("/app/learning"):
            os.mkdir("/app/learning")
        if not os.path.isdir("/app/learning/input"):
            os.mkdir("/app/learning/input")
        if not os.path.isdir("/app/learning/input/data"):
            os.mkdir("/app/learning/input/data")
    os.system("""
        wget -qnc -O /app/learning/input/data/home_sales.csv 
        https://www.dropbox.com/scl/fi/2e9yyzymm0rwzria2kvzo/raw_sales.csv?rlkey=lfdr9th7csw7ru42mtaw00hx1&dl=0
    """)
    
    cursor.query("""
        USE postgres_data {
            CREATE TABLE IF NOT EXISTS home_sales (
                    datesold VARCHAR(64), 
                    postcode INT, 
                    price INT, 
                    propertyType VARCHAR(64), 
                    bedrooms INT
                )
        }
    """)

    cursor.query("""
        USE postgres_data {
            COPY home_sales(datesold, postcode, price, propertyType, bedrooms)
            FROM '/app/learning/input/data/home_sales.csv'
            DELIMITER ',' CSV HEADER
        }
    """).df()


    ''' Train the Forecast Model

    We use the statsforecast engine to train a time serise forecast model for 
    sale prices of home with two bedrooms.
    (https://github.com/Nixtla/statsforecast)
    '''

    output = cursor.query("""
        CREATE OR REPLACE FUNCTION HomeSaleForecast FROM
            (
            SELECT propertytype, datesold, price
            FROM postgres_data.home_sales
            WHERE bedrooms = 3 AND postcode = 2607
            )
        TYPE Forecasting
        PREDICT 'price'
        HORIZON 3
        TIME 'datesold'
        ID 'propertytype'
        FREQUENCY 'W'
    """).df()
    print(output, end = "\n\n")


    """ Use the Forecast Model
    
    We then use the `HomeSaleForecast` model to predict the sale price for homes
    with two bedrooms for the next three month.
    """

    output = cursor.query("SELECT HomeSaleForecast() ORDER BY price;").df()
    print(output)
    