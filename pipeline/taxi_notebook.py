#!/usr/bin/env python
# coding: utf-8

from sys import prefix
import pandas as pd
from sqlalchemy import create_engine
from tqdm.auto import tqdm

dtype = {
    "VendorID": "Int64",
    "passenger_count": "Int64",
    "trip_distance": "float64",
    "RatecodeID": "Int64",
    "store_and_fwd_flag": "string",
    "PULocationID": "Int64",
    "DOLocationID": "Int64",
    "payment_type": "Int64",
    "fare_amount": "float64",
    "extra": "float64",
    "mta_tax": "float64",
    "tip_amount": "float64",
    "tolls_amount": "float64",
    "improvement_surcharge": "float64",
    "total_amount": "float64",
    "congestion_surcharge": "float64"
}

parse_dates = [
    "tpep_pickup_datetime",
    "tpep_dropoff_datetime"
]

def run():
    year = 2021
    month = 1
    pg_user = 'root'
    pg_pass = 'root'
    pg_host = 'localhost'
    pg_database = 'ny_taxi'
    pg_port = 5432
    chunksize = 100000
    target_table = 'yellow_taxi_data'

    prefix = "https://github.com/DataTalksClub/nyc-tlc-data/releases/download/yellow"
    url = f"{prefix}/yellow_tripdata_{year}-{month:02d}.csv.gz"

    df_iter = pd.read_csv(
        url,
        dtype=dtype,
        parse_dates=parse_dates,
        iterator = True,
        chunksize= chunksize,
    )

    #df.head()
    #get_ipython().system('uv add sqlalchemy "psycopg[binary,pool]"')

    engine = create_engine(f'postgresql+psycopg://{pg_user}:{pg_pass}@{pg_host}:{pg_port}/{pg_database}')

    #print(pd.io.sql.get_schema(df, name='yellow_taxi_data', con=engine))

    #get_ipython().system('uv add tqdm')
    first = True
    for df_chunk in tqdm(df_iter):
        if first:
            df_chunk.head(0).to_sql(name=target_table, con=engine, if_exists='replace')
            first = False
        else :
            df_chunk.to_sql(name=target_table, con=engine, if_exists='append')

if __name__ == "__main__":
    run()