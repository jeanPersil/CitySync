function mapearCategoria(categoria) {
  const mapeamento = {
    buraco: 1,
    iluminação: 2,
    lixo: 3,
    Semáforo: 4,
    "vazamento/esgoto": 5,
    Transporte: 6,
    outros: 7,
  };

  return mapeamento[categoria.toLowerCase()] || categoria;
}

function mapearStatus(status) {
  const mapeamento = {
    pendente: 1,
    "em andamento": 2,
    resolvido: 3,
  };

  return mapeamento[status.toLowerCase()] || status;
}

let status = mapearCategoria("Vazamento/esgotO");

console.log(status);

module.exports = {
  mapearCategoria,
  mapearStatus,
};
