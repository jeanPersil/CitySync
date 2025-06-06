#config.py
from flask_mysqldb import MySQL

mysql = MySQL()

def init_app(app):
    app.config['MYSQL_HOST'] = '127.0.0.1'
    app.config['MYSQL_USER'] = 'root'
    app.config['MYSQL_PASSWORD'] = ''
    app.config['MYSQL_DB'] = 'citySync'
    app.config['MYSQL_PORT'] = 3306

    mysql.init_app(app)