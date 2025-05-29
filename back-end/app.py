from flask import Flask, jsonify, request  
from flask_cors import CORS
from flask_mysqldb import MySQL

app = Flask(__name__)
CORS(app)

app.config['MYSQL_HOST'] = '127.0.0.1'      
app.config['MYSQL_USER'] = 'root'             
app.config['MYSQL_PASSWORD'] = ''             
app.config['MYSQL_DB'] = 'citySync'      
app.config['MYSQL_PORT'] = 3306               

mysql = MySQL(app)


if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)