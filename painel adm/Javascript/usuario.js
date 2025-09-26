import { toggleMenuLateral, toggleModoEscuro, mostrarNotificacao, debounce } from './utils.js';

// ===== CONSTANTES =====
const CONFIG = {
    ANIMACAO_ENTRADA: 300,
    LOCAL_STORAGE_KEYS: {
        MODO_ESCURO: 'darkMode',
        MENU_ABERTO: 'menuAberto', // Adicionado para consistência
        DADOS_USUARIO: 'dadosUsuario'
    }
};

// ===== ELEMENTOS DO DOM =====
let elementos = {
    menuToggle: null,
    barraLateral: null, // Adicionado
    overlay: null, // Adicionado
    darkModeToggle: null,
    tabs: null,
    tabContents: null,
    formEdicao: null,
    avatar: null,
    notificationBell: null,
    profileNameDisplay: null, // Adicionado
    profileCardName: null, // Adicionado
    profileCardRole: null, // Adicionado
    inputName: null, // Adicionado
    inputEmail: null // Adicionado
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
    criarOverlay(); // Criar overlay antes de carregar preferências
    carregarPreferencias();
    carregarDadosUsuario();
    inicializarAplicacao();
});

function inicializarElementos() {
    elementos = {
        menuToggle: document.getElementById('menuToggle'),
        barraLateral: document.querySelector('.barra-lateral'),
        darkModeToggle: document.getElementById('dark-mode-toggle'),
        tabs: document.querySelectorAll('.tab'),
        tabContents: document.querySelectorAll('.tab-content'),
        formEdicao: document.querySelector('#detalhes form'), // Seleção mais específica
        avatar: document.querySelector('.profile-avatar-lg'),
        notificationBell: document.querySelector('.notification-bell'),
        profileNameDisplay: document.querySelector('.perfil-usuario .profile-name'),
        profileCardName: document.querySelector('.profile-card h2'),
        profileCardRole: document.querySelector('.profile-card .role'),
        inputName: document.getElementById('name'),
        inputEmail: document.getElementById('email')
    };
}

function criarOverlay() {
    elementos.overlay = document.createElement('div');
    elementos.overlay.className = 'overlay';
    document.body.appendChild(elementos.overlay);

    // Fechar menu ao clicar no overlay
    elementos.overlay.addEventListener('click', function() {
        if (estado.menuAberto && window.innerWidth < 992) {
            estado.menuAberto = toggleMenuLateral(elementos.barraLateral, elementos.menuToggle, elementos.overlay, estado.menuAberto);
        }
    });
}

function carregarPreferencias() {
    // Carregar preferência do modo escuro
    const darkModeSalvo = localStorage.getItem(CONFIG.LOCAL_STORAGE_KEYS.MODO_ESCURO);
    estado.modoEscuroAtivo = darkModeSalvo === 'true';

    if (estado.modoEscuroAtivo) {
        document.body.classList.add('dark-mode');
        if (elementos.darkModeToggle) elementos.darkModeToggle.checked = true;
    }

    // Carregar preferência do menu lateral
    const menuAbertoSalvo = localStorage.getItem(CONFIG.LOCAL_STORAGE_KEYS.MENU_ABERTO);
    if (menuAbertoSalvo !== null && window.innerWidth < 992) {
        estado.menuAberto = menuAbertoSalvo === 'true';
        if (!estado.menuAberto) {
            elementos.barraLateral.style.transform = 'translateX(-100%)';
            elementos.menuToggle.innerHTML = '<i class="fas fa-bars"></i>';
        } else {
            elementos.barraLateral.style.transform = 'translateX(0)';
            elementos.menuToggle.innerHTML = '<i class="fas fa-times"></i>';
        }
    } else if (window.innerWidth >= 992) {
        estado.menuAberto = true; // Menu sempre aberto em telas grandes
    }
    verificarTamanhoTela(); // Ajusta o menu na inicialização
}

function carregarDadosUsuario() {
    // Carregar dados do usuário do localStorage se existirem
    const dadosSalvos = localStorage.getItem(CONFIG.LOCAL_STORAGE_KEYS.DADOS_USUARIO);
    if (dadosSalvos) {
        estado.dadosUsuario = JSON.parse(dadosSalvos);
    }
    atualizarInterfaceUsuario(); // Sempre atualiza a interface com os dados carregados (ou padrão)
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
        elementos.menuToggle.addEventListener('click', () => {
            estado.menuAberto = toggleMenuLateral(elementos.barraLateral, elementos.menuToggle, elementos.overlay, estado.menuAberto);
        });
    }

    // Dark mode toggle
    if (elementos.darkModeToggle) {
        elementos.darkModeToggle.addEventListener('change', () => {
            estado.modoEscuroAtivo = toggleModoEscuro(estado.modoEscuroAtivo);
        });
    }

    // Tabs
    elementos.tabs.forEach(tab => {
        tab.addEventListener('click', () => alternarAba(tab.dataset.tab));
    });

    // Formulário de edição
    if (elementos.formEdicao) {
        elementos.formEdicao.addEventListener('submit', salvarDadosUsuario);
    }

    // Avatar - efeito hover e clique
    if (elementos.avatar) {
        elementos.avatar.addEventListener('mouseenter', () => {
            elementos.avatar.style.transform = 'scale(1.05)';
        });

        elementos.avatar.addEventListener('mouseleave', () => {
            elementos.avatar.style.transform = 'scale(1)';
        });

        elementos.avatar.addEventListener('click', simularAlteracaoAvatar);
    }

    // Notificações
    if (elementos.notificationBell) {
        elementos.notificationBell.addEventListener('click', mostrarNotificacoes);
    }

    // Redimensionamento da janela
    window.addEventListener('resize', debounce(handleResize, 250));
}

// ===== VERIFICAR TAMANHO DA TELA E AJUSTAR MENU =====
function verificarTamanhoTela() {
    if (window.innerWidth >= 992) {
        elementos.barraLateral.style.transform = 'translateX(0)';
        elementos.overlay.classList.remove('active');
        estado.menuAberto = true;
        elementos.menuToggle.style.display = 'none';
    } else {
        elementos.menuToggle.style.display = 'block';
        if (!estado.menuAberto) {
            elementos.barraLateral.style.transform = 'translateX(-100%)';
            elementos.overlay.classList.remove('active');
            elementos.menuToggle.innerHTML = '<i class="fas fa-bars"></i>';
        } else {
            elementos.barraLateral.style.transform = 'translateX(0)';
            elementos.overlay.classList.add('active');
            elementos.menuToggle.innerHTML = '<i class="fas fa-times"></i>';
        }
    }
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
    const novoNome = elementos.inputName.value;
    const novoEmail = elementos.inputEmail.value;

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
    if (elementos.inputName) elementos.inputName.value = estado.dadosUsuario.nome;
    if (elementos.inputEmail) elementos.inputEmail.value = estado.dadosUsuario.email;

    if (elementos.profileNameDisplay) {
        elementos.profileNameDisplay.textContent = estado.dadosUsuario.nome;
    }

    if (elementos.profileCardName) {
        elementos.profileCardName.textContent = estado.dadosUsuario.nome;
    }

    if (elementos.profileCardRole) {
        elementos.profileCardRole.textContent = estado.dadosUsuario.cargo;
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
    } else {
        mostrarNotificacao('Nenhuma nova notificação.', 'info');
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

        document.querySelectorAll('.animated').forEach(el => {
            observer.observe(el);
        });
    }
}

// ===== HANDLE RESIZE =====
function handleResize() {
    verificarTamanhoTela();
}

// ===== EXPORTAÇÃO PARA USO EXTERNO =====
window.Usuario = {
    salvarDados: salvarDadosUsuario,
    alternarAba: alternarAba,
    mostrarNotificacao: mostrarNotificacao // Mantido para compatibilidade, mas agora vem de utils
};