from flask import Flask, jsonify
from flask_cors import CORS  # 👈 import

app = Flask(__name__)
CORS(app)  # 👈 habilita CORS

@app.route('/teste')
def teste():
    return jsonify({'mensagem': 'Iwweizinho apelao!'})

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000)  



@app.route('/login')
def logarUsuario():
    print("Usuario Logado")