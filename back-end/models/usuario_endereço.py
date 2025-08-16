import requests
from validate_docbr import CPF

validarCpf = CPF()

class Endereco:
    def __init__(self, id, logradouro, numero, bairro, cep, id_cidade):
        self.id = id
        self.logradouro = logradouro
        self.numero = numero
        self.bairro = bairro
        self.cep = cep
        self.id_cidade = id_cidade  

    def verificar_campos_obrigatorios(self):
        campos_obrigatorios = [
            self.logradouro,
            self.numero,
            self.bairro,
            self.cep,
            self.id_cidade
        ]

        return all (campos_obrigatorios)
    
    def validar_cep(self):
        url = f"https://viacep.com.br/ws/{self.cep}/json/"
        try:
            resposta = requests.get(url, timeout=5)
            dados = resposta.json()
            return dados if not dados.get("erro") else None
        except requests.exceptions.RequestException:
            return None

        

class Usuario:
    def __init__(self, id, nome, cpf, email, telefone, senha, id_endereco):
        self.id = id
        self.nome = nome
        self.cpf = cpf
        self.email = email
        self.telefone = telefone
        self.senha = senha
        self.id_endereco = id_endereco 
    


    def validar_cpf_usuario(self):
        try:
            return validarCpf.validate(self.cpf)
        except ValueError:
            return False

    def verificar_campos_obrigatorios(self):

        campos_obrigatorios = [ 
            self.nome,
            self.cpf,
            self.email,
            self.telefone,
            self.senha
        ]

        return all (campos_obrigatorios)
    




