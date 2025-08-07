from flask import Flask
from flask_cors import CORS
from config import init_supabase

app = Flask(__name__)
CORS(app)

init_supabase()  

from controller.auth import auth_bp
from controller.report import report_bp

app.register_blueprint(auth_bp)
app.register_blueprint(report_bp)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
