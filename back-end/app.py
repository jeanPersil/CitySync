from flask import Flask
from flask_cors import CORS
from config import mysql, init_app

app = Flask(__name__)
CORS(app)

init_app(app)  

from auth import auth_bp
from report import report_bp

app.register_blueprint(auth_bp)
app.register_blueprint(report_bp)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
