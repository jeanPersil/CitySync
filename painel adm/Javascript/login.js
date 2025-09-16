// Atualiza o ano no rodapé
document.getElementById('ano').textContent = new Date().getFullYear();

// Função para verificar credenciais (simulação)
function verificarCredenciais(email, senha) {
  return email === 'admin@gmail.com' && senha === 'admin123';
}

// Função para preencher o email se "lembrar-me" estiver marcado
function verificarCredenciaisSalvas() {
  const emailSalvo = localStorage.getItem('emailLembrado');
  const lembrarSalvo = localStorage.getItem('lembrarUsuario');
  
  if (emailSalvo && lembrarSalvo === 'true') {
    document.getElementById('email').value = emailSalvo;
    document.getElementById('lembrar').checked = true;
  }
}

// Função para alternar a visibilidade da senha (CORRIGIDA)
function toggleSenha() {
  const senhaInput = document.getElementById('senha');
  const icone = document.getElementById('iconeSenha');

  if (senhaInput.type === "password") {
    senhaInput.type = "text";
    icone.classList.remove("fa-eye");
    icone.classList.add("fa-eye-slash");
  } else {
    senhaInput.type = "password";
    icone.classList.remove("fa-eye-slash");
    icone.classList.add("fa-eye");
  }
}

// Função para lidar com o envio do formulário
function handleLogin(event) {
  event.preventDefault();
  
  const email = document.getElementById('email').value;
  const senha = document.getElementById('senha').value;
  const lembrar = document.getElementById('lembrar').checked;
  const botao = document.querySelector('.botao');
  
  if (!email || !senha) {
    alert('Por favor, preencha todos os campos.');
    return;
  }
  
  if (verificarCredenciais(email, senha)) {
    // Mostrar loading no botão
    botao.innerHTML = 'Entrando... <span class="spinner"></span>';
    botao.disabled = true;

    const spinner = botao.querySelector('.spinner');
    spinner.style.cssText = `
      display: inline-block;
      width: 12px;
      height: 12px;
      border: 2px solid rgba(255,255,255,0.3);
      border-radius: 50%;
      border-top-color: #fff;
      animation: spin 1s ease-in-out infinite;
    `;
    
    const style = document.createElement('style');
    style.textContent = `
      @keyframes spin { to { transform: rotate(360deg); } }
    `;
    document.head.appendChild(style);

    // Salvar email se "lembrar-me" estiver marcado
    if (lembrar) {
      localStorage.setItem('emailLembrado', email);
      localStorage.setItem('lembrarUsuario', 'true');
    } else {
      localStorage.removeItem('emailLembrado');
      localStorage.removeItem('lembrarUsuario');
    }
    
    // Redirecionar após delay
    setTimeout(() => {
      window.location.href = 'dashboard.html';
    }, 1000);
    
  } else {
    alert('Credenciais inválidas. Tente novamente.');
    document.getElementById('senha').value = '';
    document.getElementById('senha').focus();
  }
}

// Adicionar efeitos de interação aos campos
function addFieldInteractions() {
  const campos = document.querySelectorAll('.campo input');
  
  campos.forEach(campo => {
    campo.addEventListener('focus', function() {
      this.parentElement.style.transform = 'translateY(-2px)';
      this.parentElement.style.transition = 'transform 0.2s ease';
    });
    
    campo.addEventListener('blur', function() {
      this.parentElement.style.transform = 'translateY(0)';
    });
    
    if (campo.type === 'email') {
      campo.addEventListener('blur', function() {
        if (this.value && !this.validity.valid) {
          this.style.borderColor = '#ef4444';
        } else {
          this.style.borderColor = '#cbd5e1';
        }
      });
    }
  });
}

// Inicializar tudo quando o DOM estiver carregado
document.addEventListener('DOMContentLoaded', function() {
  verificarCredenciaisSalvas();
  addFieldInteractions();
  document.getElementById('loginForm').addEventListener('submit', handleLogin);

  // Configurar o toggle do olho (CORREÇÃO)
  const toggleSenhaBtn = document.querySelector('.toggle-senha');
  if (toggleSenhaBtn) {
    toggleSenhaBtn.addEventListener('click', toggleSenha);
  }
});