class Report:  
    def __init__(self, id, endereco, categoria_id, status_id, usuario_id, descricao, url_imagem):
        self.id = id
        self.endereco = endereco  
        self.categoria_id = categoria_id
        self.status_id = status_id
        self.usuario_id = usuario_id
        self.descricao = descricao  
        self.url_imagem = url_imagem


    def verificar_campos_obrigatorios (self):
        campos_obrigatorios = [
        self.endereco, 
        self.categoria_id, 
        self.usuario_id,
        self.descricao,
        #self.url_imagem
        ]

        return all (campos_obrigatorios)
