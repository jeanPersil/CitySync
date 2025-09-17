// ===== CONSTANTES =====
const CONFIG = {
    ANIMACAO_ENTRADA: 300,
    LOCAL_STORAGE_KEYS: {
        MODO_ESCURO: 'darkMode',
        DADOS_USUARIO: 'dadosUsuario'
    }
};

// ===== ELEMENTOS DO DOM =====
let elementos = {
    menuToggle: null,
    darkModeToggle: null,
    tabs: null,
    tabContents: null,
    formEdicao: null,
    avatar: null,
    notificationBell: null
};

// ===== ESTADO DA APLICAÇÃO =====
let estado = {
    menuAberto: true,
    modoEscuroAtivo: false,
    editando: false,
    dadosUsuario: {
        nome: "Iwin Lima Borges",
        email: "iwin@email.com",
        cargo: "Administrador"
    }
};

// ===== INICIALIZAÇÃO =====
document.addEventListener('DOMContentLoaded', function() {
    inicializarElementos();
    carregarPreferencias();
    carregarDadosUsuario();
    inicializarAplicacao();
});

function inicializarElementos() {
    elementos = {
        menuToggle: document.getElementById('menuToggle'),
        darkModeToggle: document.getElementById('dark-mode-toggle'),
        tabs: document.querySelectorAll('.tab'),
        tabContents: document.querySelectorAll('.tab-content'),
        formEdicao: document.querySelector('form'),
        avatar: document.querySelector('.profile-avatar-lg'),
        notificationBell: document.querySelector('.notification-bell')
    };
}

function carregarPreferencias() {
    // Carregar preferência do modo escuro
    const darkModeSalvo = localStorage.getItem(CONFIG.LOCAL_STORAGE_KEYS.MODO_ESCURO);
    estado.modoEscuroAtivo = darkModeSalvo === 'true';
    
    if (estado.modoEscuroAtivo) {
        document.body.classList.add('dark-mode');
        elementos.darkModeToggle.checked = true;
    }
}

function carregarDadosUsuario() {
    // Carregar dados do usuário do localStorage se existirem
    const dadosSalvos = localStorage.getItem(CONFIG.LOCAL_STORAGE_KEYS.DADOS_USUARIO);
    if (dadosSalvos) {
        estado.dadosUsuario = JSON.parse(dadosSalvos);
        atualizarInterfaceUsuario();
    }
}

function inicializarAplicacao() {
    configurarEventListeners();
    animarElementos();
    configurarObservadorIntersecao();
}

// ===== CONFIGURAR EVENT LISTENERS =====
function configurarEventListeners() {
    // Menu toggle
    if (elementos.menuToggle) {
        elementos.menuToggle.addEventListener('click', toggleMenuLateral);
    }
    
     
    if (elementos.darkModeToggle) {
        elementos.darkModeToggle.addEventListener('change', toggleModoEscuro);
    }
    
    
    elementos.tabs.forEach(tab => {
        tab.addEventListener('click', () => alternarAba(tab.dataset.tab));
    });
    
    
    if (elementos.formEdicao) {
        elementos.formEdicao.addEventListener('submit', salvarDadosUsuario);
    }
    
    // Avatar - efeito hover
    if (elementos.avatar) {
        elementos.avatar.addEventListener('mouseenter', () => {
            elementos.avatar.style.transform = 'scale(1.05)';
        });
        
        elementos.avatar.addEventListener('mouseleave', () => {
            elementos.avatar.style.transform = 'scale(1)';
        });
        
        
        elementos.avatar.addEventListener('click', simularAlteracaoAvatar);
    }
    
    
    if (elementos.notificationBell) {
        elementos.notificationBell.addEventListener('click', mostrarNotificacoes);
    }
    
    
    window.addEventListener('resize', debounce(handleResize, 250));
}

// ===== TOGGLE MENU LATERAL =====
function toggleMenuLateral() {
    estado.menuAberto = !estado.menuAberto;
    
    if (window.innerWidth < 992) {
        const barraLateral = document.querySelector('.barra-lateral');
        if (barraLateral) {
            if (estado.menuAberto) {
                barraLateral.style.transform = 'translateX(0)';
            } else {
                barraLateral.style.transform = 'translateX(-100%)';
            }
        }
    }
}

// ===== TOGGLE MODO ESCURO =====
function toggleModoEscuro() {
    estado.modoEscuroAtivo = !estado.modoEscuroAtivo;
    
    if (estado.modoEscuroAtivo) {
        document.body.classList.add('dark-mode');
    } else {
        document.body.classList.remove('dark-mode');
    }
    
    localStorage.setItem(CONFIG.LOCAL_STORAGE_KEYS.MODO_ESCURO, estado.modoEscuroAtivo);
}

// ===== ALTERNAR ENTRE ABAS =====
function alternarAba(abaId) {
    
    elementos.tabs.forEach(tab => {
        tab.classList.remove('active');
    });
    
    
    elementos.tabContents.forEach(content => {
        content.classList.remove('active');
    });
    
    
    const tabAtiva = document.querySelector(`[data-tab="${abaId}"]`);
    const conteudoAtivo = document.getElementById(abaId);
    
    if (tabAtiva && conteudoAtivo) {
        tabAtiva.classList.add('active');
        conteudoAtivo.classList.add('active');
    }
}

// ===== SALVAR DADOS DO USUÁRIO =====
function salvarDadosUsuario(e) {
    e.preventDefault();
    
    // Obter valores do formulário
    const novoNome = document.getElementById('name').value;
    const novoEmail = document.getElementById('email').value;
    
    // Validar dados
    if (!novoNome || !novoEmail) {
        mostrarNotificacao('Por favor, preencha todos os campos.', 'erro');
        return;
    }
    
    if (!validarEmail(novoEmail)) {
        mostrarNotificacao('Por favor, insira um e-mail válido.', 'erro');
        return;
    }
    
    
    estado.dadosUsuario.nome = novoNome;
    estado.dadosUsuario.email = novoEmail;
    
    
    localStorage.setItem(
        CONFIG.LOCAL_STORAGE_KEYS.DADOS_USUARIO, 
        JSON.stringify(estado.dadosUsuario)
    );
    
    // Atualizar interface
    atualizarInterfaceUsuario();
    
    // Mostrar feedback
    mostrarNotificacao('Dados salvos com sucesso!', 'sucesso');
}

function validarEmail(email) {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
}

// ===== ATUALIZAR INTERFACE COM DADOS DO USUÁRIO =====
function atualizarInterfaceUsuario() {
    
    document.getElementById('name').value = estado.dadosUsuario.nome;
    document.getElementById('email').value = estado.dadosUsuario.email;
    
    
    const elementoNome = document.querySelector('.profile-name');
    if (elementoNome) {
        elementoNome.textContent = estado.dadosUsuario.nome;
    }
    
    
    const elementoNomePerfil = document.querySelector('.profile-card h2');
    if (elementoNomePerfil) {
        elementoNomePerfil.textContent = estado.dadosUsuario.nome;
    }
    
    
    const elementoCargo = document.querySelector('.profile-card .role');
    if (elementoCargo) {
        elementoCargo.textContent = estado.dadosUsuario.cargo;
    }
}

// ===== SIMULAR ALTERAÇÃO DE AVATAR =====
function simularAlteracaoAvatar() {
    mostrarNotificacao('Funcionalidade de alterar avatar em desenvolvimento.', 'info');
}

// ===== MOSTRAR NOTIFICAÇÕES =====
function mostrarNotificacoes() {
    
    const countElement = document.querySelector('.notification-count');
    if (countElement && countElement.textContent !== '0') {
        countElement.textContent = '0';
        countElement.style.display = 'none';
        mostrarNotificacao('Notificações marcadas como lidas.', 'info');
    }
}

// ===== ANIMAÇÕES =====
function animarElementos() {
    const elementosAnimados = document.querySelectorAll('.animated');
    
    elementosAnimados.forEach((elemento, index) => {
        setTimeout(() => {
            elemento.style.opacity = '1';
            elemento.style.transform = 'translateY(0)';
        }, index * 150);
    });
}

// ===== OBSERVADOR DE INTERSEÇÃO (LAZY LOADING) =====
function configurarObservadorIntersecao() {
    if ('IntersectionObserver' in window) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('visivel');
                    observer.unobserve(entry.target);
                }
            });
        }, { threshold: 0.1 });
        
        // Observar elementos animados
        document.querySelectorAll('.animated').forEach(el => {
            observer.observe(el);
        });
    }
}

// ===== HANDLE RESIZE =====
function handleResize() {
    // Ajustar menu lateral em telas pequenas
    if (window.innerWidth < 992 && estado.menuAberto) {
        const barraLateral = document.querySelector('.barra-lateral');
        if (barraLateral) {
            barraLateral.style.transform = 'translateX(-100%)';
            estado.menuAberto = false;
        }
    }
}

// ===== NOTIFICAÇÕES =====
function mostrarNotificacao(mensagem, tipo = 'info') {
    const toast = document.createElement('div');
    toast.className = `toast-message ${tipo}`;
    toast.innerHTML = `
        <i class="fas fa-${obterIconeNotificacao(tipo)}"></i>
        <span>${mensagem}</span>
    `;
    
    // Estilos para o toast
    toast.style.cssText = `
        position: fixed;
        bottom: 20px;
        right: 20px;
        padding: 12px 20px;
        border-radius: 6px;
        background: ${obterCorNotificacao(tipo)};
        color: white;
        display: flex;
        align-items: center;
        gap: 10px;
        z-index: 1000;
        opacity: 0;
        transform: translateY(20px);
        transition: all 0.3s ease;
    `;
    
    document.body.appendChild(toast);
    
    
    toast.offsetHeight;
    
    
    toast.style.opacity = '1';
    toast.style.transform = 'translateY(0)';
    
    
    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateY(20px)';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
}

function obterIconeNotificacao(tipo) {
    const icones = {
        'sucesso': 'check-circle',
        'erro': 'exclamation-circle',
        'aviso': 'exclamation-triangle',
        'info': 'info-circle'
    };
    return icones[tipo] || 'info-circle';
}

function obterCorNotificacao(tipo) {
    const cores = {
        'sucesso': '#2ecc71',
        'erro': '#e74c3c',
        'aviso': '#f39c12',
        'info': '#3498db'
    };
    return cores[tipo] || '#3498db';
}

// ===== UTILITÁRIOS =====
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// ===== EXPORTAÇÃO PARA USO EXTERNO =====
window.Usuario = {
    salvarDados: salvarDadosUsuario,
    alternarAba: alternarAba,
    mostrarNotificacao: mostrarNotificacao
};