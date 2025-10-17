class Api {
  // AUTENTICAÇÃO ( LOGIN, LOGOUT )
  constructor() {
    this.url_api = "http://localhost:3000";
  }
  async login(email, senha) {
    try {
      const response = await fetch(`${this.url_api}/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email, senha }),
      });

      const data = await response.json();

      if (!data.success) {
        throw new Error(data.message);
      }
      return {
        success: true,
        data: data,
      };
    } catch (error) {
      return {
        success: false,
        error: error.message,
      };
    }
  }

  async logout() {
    try {
      const response = await fetch(`${this.url_api}/logout`, {
        method: "POST",
        credentials: "include",
      });

      const data = await response.json();

      return data;
    } catch (error) {
      console.error("Erro na API de logout:", error);
      throw error;
    }
  }

  // ==== REPORTES ====
  async obterReportsPorPeriodo(periodoDias) {
    try {
      const response = await fetch(
        `${this.url_api}/reports?periodo=${periodoDias}`
      );

      const data = await response.json();

      if (!data.success) {
        throw new Error(data.message);
      }

      return data;
    } catch (error) {
      return {
        success: false,
        message: error.message,
      };
    }
  }

  async obterReportsFiltrados(parametros) {
    try {
      const response = await fetch(
        `${this.url_api}/reportsFiltrados?${parametros.toString()}`
      );

      const result = await response.json();

      return result;
    } catch (error) {
      console.error("Erro em obterReportsFiltrados:", error);
      return {
        success: false,
        message: error.message || error,
      };
    }
  }

  async editarReport() {}

  async excluirReport(id) {
    const response = await fetch(`${this.url_api}/deletar/${id}`, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
    });

    const result = await response.json();

    if (!result.success) throw new Error(result.message);

    return null;
  }
}

export const api = new Api();
