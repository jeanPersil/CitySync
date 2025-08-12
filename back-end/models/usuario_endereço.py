class Endereco:
    def __init__(self, id, logradouro, numero, bairro, cep, id_cidade):
        self.id = id
        self.logradouro = logradouro
        self.numero = numero
        self.bairro = bairro
        self.cep = cep
        self.id_cidade = id_cidade  

        
        def to_json(self): return {
            "id": self.id,
            "logradouro": self.logradouro,
            "numero": self.numero,
            "bairro": self.bairro,
            "cep": self.cep,
            "id_cidade": self.id_cidade
            }

class Usuario:
    def __init__(self, id, nome, cpf, email, telefone, senha, id_endereco):
        self.id = id
        self.nome = nome
        self.cpf = cpf
        self.email = email
        self.telefone = telefone
        self.senha = senha
        self.id_endereco = id_endereco 
        
        def to_json (self):
            return {
            "id": self.id,
            "nome": self.nome,
            "cpf": self.cpf,
            "email": self.email,
            "telefone": self.telefone,
            "senha": self.senha,
            "id_endereco": self.id_endereco
        }

class Report:  
    def __init__(self, id, endereco, categoria_id, status_id, usuario_id, duracao, descricao, url_imagem):
        self.id = id
        self.endereco = endereco  
        self.categoria_id = categoria_id
        self.status_id = status_id
        self.usuario_id = usuario_id
        self.duracao = duracao
        self.descricao = descricao  
        self.url_imagem = url_imagem

        def to_json(self):
         return {
            "id": self.id,
            "endereco": self.endereco,
            "categoria_id": self.categoria_id,
            "status_id": self.status_id,
            "usuario_id": self.usuario_id,
            "duracao": self.duracao,
            "descricao": self.descricao,
            "url_imagem": self.url_imagem
          }



