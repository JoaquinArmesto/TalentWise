import json
import mysql.connector

def db_statement(credentials_file, query):
    query_results = list()

    with open(credentials_file) as credentials:
            credentials_json = json.load(credentials)

    with mysql.connector.connect(user=credentials_json['user'],
                                 host=credentials_json['host'],
                                 port=credentials_json['port'],
                                 password=credentials_json['pass']) as conn:
        with conn.cursor() as cursor:
            for result in cursor.execute(query, multi=True):
                data = result.fetchall()
                if len(data) > 0:
                    query_results.append(data)
            return query_results