import requests
from validate_docbr import CPF

validarCpf = CPF()

class Usuario:
    def __init__(self, nome, cpf, email, telefone, senha, cep, fk_cidade):
        self.nome = nome
        self.cpf = cpf
        self.email = email
        self.telefone = telefone
        self.senha = senha
        self.cep = cep 
        self.fk_cidade = fk_cidade

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
            self.senha,
            self.cep,
            self.fk_cidade
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


    




