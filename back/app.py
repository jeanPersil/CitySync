
from flask import Flask, render_template, jsonify, request
import sqlite3

app = Flask(__name__)

@app.route('/teste')
def login():
    return jsonify({'mensagem' : 'ola mundo'});


if __name__ == '__main__':
    app.run(debug=True)

    
