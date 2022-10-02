import json
import mysql.connector
import streamlit as st

# def db_statement(query, credentials_file):

def db_statement(query):
    credentials_json = {
        'user': st.secrets(['DB_USER']),
        'host': st.secrets(['DB_HOSTS']),
        'port': st.secrets(['DB_PORT']),
        'pass': st.secrets(['DB_PASS'])
    }

    query_results = list()


    # with open(credentials_file) as credentials:
    #         credentials_json = json.load(credentials)

    with mysql.connector.connect(user=credentials_json['user'],
                                 host=credentials_json['host'],
                                 port=credentials_json['port'],
                                 password=credentials_json['pass']) as conn:
        with conn.cursor() as cursor:
            for result in cursor.execute(query, multi=True):
                data = result.fetchall()
                if len(data) > 0:
                    query_results.append(data)
            conn.commit()
            return query_results