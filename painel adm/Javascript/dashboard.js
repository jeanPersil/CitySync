
// ===== CONSTANTES E CONFIGURAÇÕES =====
const CONFIG = {
    ATUALIZACAO_TEMPO_REAL: 15000, // 15 segundos
    ANIMACAO_ENTRADA: 300,
    NOTIFICACAO_TIMEOUT: 5000,
    LOCAL_STORAGE_KEYS: {
        MODO_ESCURO: 'darkMode',
        MENU_ABERTO: 'menuAberto'
    }
};

// ===== ELEMENTOS DO DOM =====
let elementos = {
    menuToggle: null,
    barraLateral: null,
    darkModeToggle: null,
    searchInput: null,
    chartFilter: null,
    viewAllBtn: null,
    actionButtons: null,
    statusBadges: null,
    overlay: null
};

// ===== ESTADO DA APLICAÇÃO =====
let estado = {
    menuAberto: true,
    modoEscuroAtivo: false,
    dadosFiltrados: false,
    tempoRealAtivo: true
};

// ===== INICIALIZAÇÃO =====
document.addEventListener('DOMContentLoaded', function() {
    inicializarElementos();
    carregarPreferencias();
    inicializarAplicacao();
    configurarServiceWorker();
});

function inicializarElementos() {
    elementos = {
        menuToggle: document.getElementById('menuToggle'),
        barraLateral: document.querySelector('.barra-lateral'),
        darkModeToggle: document.getElementById('dark-mode-toggle'),
        searchInput: document.querySelector('.search-box input'),
        chartFilter: document.querySelector('.chart-filter'),
        viewAllBtn: document.querySelector('.view-all'),
        actionButtons: document.querySelectorAll('.action-btn'),
        statusBadges: document.querySelectorAll('.status-badge'),
        cardsStatus: document.querySelectorAll('.status-card')
    };
    
    // Criar overlay se não existir
    criarOverlay();
}

function criarOverlay() {
    elementos.overlay = document.createElement('div');
    elementos.overlay.className = 'overlay';
    document.body.appendChild(elementos.overlay);
    
    // Fechar menu ao clicar no overlay
    elementos.overlay.addEventListener('click', function() {
        if (estado.menuAberto && window.innerWidth < 992) {
            toggleMenuLateral();
        }
    });
}

function carregarPreferencias() {
    // Carregar preferência do modo escuro
    const darkModeSalvo = localStorage.getItem(CONFIG.LOCAL_STORAGE_KEYS.MODO_ESCURO);
    estado.modoEscuroAtivo = darkModeSalvo === 'true';
    
    if (estado.modoEscuroAtivo) {
        document.body.classList.add('dark-mode');
        elementos.darkModeToggle.checked = true;
    }

    // Carregar preferência do menu lateral - ATUALIZADO
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
    }
    
    // Verificar tamanho da tela ao carregar
    verificarTamanhoTela();
}

function inicializarAplicacao() {
    inicializarGraficos();
    inicializarTooltips();
    configurarEventListeners();
    animarElementos();
    iniciarAtualizacaoTempoReal();
    configurarObservadorIntersecao();
}

// ===== VERIFICAR TAMANHO DA TELA E AJUSTAR MENU =====
function verificarTamanhoTela() {
    if (window.innerWidth >= 992) {
        // Em telas grandes, garantir que o menu esteja visível
        elementos.barraLateral.style.transform = 'translateX(0)';
        elementos.overlay.classList.remove('active');
        estado.menuAberto = true;
        elementos.menuToggle.style.display = 'none';
    } else {
        // Em telas pequenas, usar estado salvo ou padrão (fechado)
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

function inicializarGraficos() {
}

function animarGraficoPizza() {
}

// ===== INICIALIZAR TOOLTIPS =====
function inicializarTooltips() {
    const tooltipElements = document.querySelectorAll('[data-tooltip]');
    
    tooltipElements.forEach(element => {
        element.addEventListener('mouseenter', mostrarTooltip);
        element.addEventListener('mouseleave', esconderTooltip);
        element.addEventListener('focus', mostrarTooltip);
        element.addEventListener('blur', esconderTooltip);
    });
}

function mostrarTooltip(e) {
    const tooltipTexto = this.getAttribute('data-tooltip');
    if (!tooltipTexto) return;

    const tooltip = document.createElement('div');
    tooltip.className = 'tooltip';
    tooltip.textContent = tooltipTexto;
    tooltip.setAttribute('role', 'tooltip');
    document.body.appendChild(tooltip);
    
    const rect = this.getBoundingClientRect();
    const scrollTop = window.pageYOffset || document.documentElement.scrollTop;
    
    tooltip.style.top = `${rect.top + scrollTop - tooltip.offsetHeight - 10}px`;
    tooltip.style.left = `${rect.left + rect.width / 2 - tooltip.offsetWidth / 2}px`;
    
    this._tooltipElement = tooltip;
}

function esconderTooltip() {
    if (this._tooltipElement) {
        this._tooltipElement.remove();
        this._tooltipElement = null;
    }
}

// ===== CONFIGURAR EVENT LISTENERS =====
function configurarEventListeners() {
    // Menu toggle
    if (elementos.menuToggle) {
        elementos.menuToggle.addEventListener('click', toggleMenuLateral);
        elementos.menuToggle.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' || e.key === ' ') toggleMenuLateral();
        });
    }
    
    // Dark mode toggle
    if (elementos.darkModeToggle) {
        elementos.darkModeToggle.addEventListener('change', toggleModoEscuro);
    }
    
    // Search input
    if (elementos.searchInput) {
        elementos.searchInput.addEventListener('input', debounce(pesquisarConteudo, 300));
        elementos.searchInput.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                elementos.searchInput.value = '';
                pesquisarConteudo({ target: elementos.searchInput });
            }
        });
    }
    
    // Chart filter
    if (elementos.chartFilter) {
        elementos.chartFilter.addEventListener('change', filtrarGrafico);
    }
    
    // View all button
    if (elementos.viewAllBtn) {
        elementos.viewAllBtn.addEventListener('click', verTodosReports);
    }
    
    // Action buttons
    elementos.actionButtons.forEach(botao => {
        botao.addEventListener('click', handleActionClick);
        botao.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' || e.key === ' ') handleActionClick.call(botao, e);
        });
    });
    
    // Status badges
    elementos.statusBadges.forEach(badge => {
        badge.addEventListener('click', () => filtrarPorStatus(badge.textContent));
        badge.addEventListener('keypress', (e) => {
            if (e.key === 'Enter' || e.key === ' ') filtrarPorStatus(badge.textContent);
        });
    });
    
    // Eventos de teclado
    document.addEventListener('keydown', handleKeyboardShortcuts);
    
    // Redimensionamento da janela - ATUALIZADO
    window.addEventListener('resize', debounce(function() {
        verificarTamanhoTela();
    }, 250));
}

// ===== TOGGLE MENU LATERAL =====
function toggleMenuLateral() {
    // Não permitir abrir o menu em telas grandes onde ele já está sempre visível
    if (window.innerWidth >= 992) {
        return;
    }
    
    estado.menuAberto = !estado.menuAberto;
    
    if (estado.menuAberto) {
        elementos.barraLateral.style.transform = 'translateX(0)';
        elementos.overlay.classList.add('active');
        elementos.menuToggle.innerHTML = '<i class="fas fa-times"></i>';
        elementos.menuToggle.setAttribute('aria-label', 'Fechar menu');
    } else {
        elementos.barraLateral.style.transform = 'translateX(-100%)';
        elementos.overlay.classList.remove('active');
        elementos.menuToggle.innerHTML = '<i class="fas fa-bars"></i>';
        elementos.menuToggle.setAttribute('aria-label', 'Abrir menu');
    }
    
    // Salvar preferência apenas para telas pequenas
    if (window.innerWidth < 992) {
        localStorage.setItem(CONFIG.LOCAL_STORAGE_KEYS.MENU_ABERTO, estado.menuAberto);
    }
    
    document.dispatchEvent(new CustomEvent('menuToggle', { detail: estado.menuAberto }));
}

// ===== TOGGLE MODO ESCURO =====
function toggleModoEscuro() {
    estado.modoEscuroAtivo = !estado.modoEscuroAtivo;
    
    if (estado.modoEscuroAtivo) {
        document.body.classList.add('dark-mode');
        document.dispatchEvent(new CustomEvent('modoEscuroAlterado', { detail: true }));
    } else {
        document.body.classList.remove('dark-mode');
        document.dispatchEvent(new CustomEvent('modoEscuroAlterado', { detail: false }));
    }
    
    localStorage.setItem(CONFIG.LOCAL_STORAGE_KEYS.MODO_ESCURO, estado.modoEscuroAtivo);
}

// ===== PESQUISAR CONTEÚDO =====
function pesquisarConteudo(e) {
    const termo = e.target.value.toLowerCase().trim();
    
    if (termo.length > 2) {
        filtrarTabela(termo);
        estado.dadosFiltrados = true;
    } else if (estado.dadosFiltrados && termo.length === 0) {
        resetarFiltroTabela();
        estado.dadosFiltrados = false;
    }
}

function filtrarTabela(termo) {
    const linhasTabela = document.querySelectorAll('.tabela-recentes tbody tr');
    let resultados = 0;
    
    linhasTabela.forEach(linha => {
        const textoLinha = linha.textContent.toLowerCase();
        if (textoLinha.includes(termo)) {
            linha.style.display = '';
            linha.classList.add('highlight');
            resultados++;
        } else {
            linha.style.display = 'none';
            linha.classList.remove('highlight');
        }
    });
    
    // Mostrar mensagem se não houver resultados
    mostrarResultadoPesquisa(resultados);
}

function resetarFiltroTabela() {
    const linhasTabela = document.querySelectorAll('.tabela-recentes tbody tr');
    linhasTabela.forEach(linha => {
        linha.style.display = '';
        linha.classList.remove('highlight');
    });
    
    esconderResultadoPesquisa();
}

function mostrarResultadoPesquisa(resultados) {
    let mensagem = document.getElementById('resultado-pesquisa');
    
    if (!mensagem) {
        mensagem = document.createElement('div');
        mensagem.id = 'resultado-pesquisa';
        mensagem.style.cssText = `
            padding: 10px;
            margin: 10px 0;
            background: var(--info-light);
            border-left: 4px solid var(--accent-blue);
            border-radius: 4px;
        `;
        document.querySelector('.tabela-recentes').appendChild(mensagem);
    }
    
    mensagem.textContent = `${resultados} resultado(s) encontrado(s)`;
}

function esconderResultadoPesquisa() {
    const mensagem = document.getElementById('resultado-pesquisa');
    if (mensagem) mensagem.remove();
}

// ===== FILTRAR GRÁFICO =====
function filtrarGrafico(e) {
    const periodo = e.target.value;
    
    // Mostrar indicador de carregamento
    const chartWrapper = document.querySelector('.chart-wrapper');
    chartWrapper.style.opacity = '0.5';
    chartWrapper.classList.add('loading');
    
    // Simular requisição
    setTimeout(() => {
        atualizarGrafico(periodo);
        chartWrapper.style.opacity = '1';
        chartWrapper.classList.remove('loading');
    }, 800);
}

function atualizarGrafico(periodo) {
    const dadosPeriodo = {
        'Últimos 7 dias': [42, 51, 27, 36, 18],
        'Últimos 30 dias': [65, 78, 42, 55, 25],
        'Este mês': [35, 45, 22, 30, 15]
    };
    
    const alturas = dadosPeriodo[periodo] || [42, 51, 27, 36, 18];
    const barras = document.querySelectorAll('.bar');
    
    barras.forEach((barra, index) => {
        const valor = alturas[index];
        barra.style.setProperty('--height', `${valor}%`);
        barra.querySelector('.bar-value').textContent = valor;
    });
    
    // Atualizar evento
    document.dispatchEvent(new CustomEvent('graficoAtualizado', { detail: periodo }));
}

// ===== VER TODOS REPORTS =====
function verTodosReports(e) {
    e.preventDefault();
    // Simular navegação
    window.location.href = 'gestao.html';
}

// ===== HANDLE ACTION CLICK =====
function handleActionClick(e) {
    const acao = this.querySelector('span').textContent;
    
    switch(acao) {
        case 'Exportar Dados':
            exportarDados();
            break;
        case 'Filtrar':
            toggleFiltros();
            break;
        case 'Relatório':
            gerarRelatorio();
            break;
        default:
            console.log('Ação não reconhecida:', acao);
    }
}

function exportarDados() {
    // Simular exportação
    mostrarNotificacao('Dados exportados com sucesso!', 'sucesso');
    
    // Registrar no analytics
    document.dispatchEvent(new CustomEvent('exportacaoIniciada'));
}

function toggleFiltros() {
    const filtrosAvancados = document.querySelector('.filtros-avancados');
    
    if (!filtrosAvancados) {
        criarFiltrosAvancados();
    } else {
        filtrosAvancados.classList.toggle('ativo');
    }
}

function criarFiltrosAvancados() {
    const filtros = document.createElement('div');
    filtros.className = 'filtros-avancados';
    filtros.innerHTML = `
        <h4>Filtros Avançados</h4>
        <div class="filtro-grupo">
            <label>Data Inicial</label>
            <input type="date">
        </div>
        <div class="filtro-grupo">
            <label>Data Final</label>
            <input type="date">
        </div>
        <div class="filtro-grupo">
            <label>Categoria</label>
            <select>
                <option>Todas</option>
                <option>Buraco</option>
                <option>Iluminação</option>
                <option>Limpeza</option>
                <option>Sinalização</option>
            </select>
        </div>
        <button class="aplicar-filtros">Aplicar Filtros</button>
    `;
    
    document.querySelector('.quick-actions').appendChild(filtros);
    setTimeout(() => filtros.classList.add('ativo'), 10);
}

function gerarRelatorio() {
    // Simular geração de relatório
    mostrarNotificacao('Relatório sendo gerado...', 'info');
    
    setTimeout(() => {
        mostrarNotificacao('Relatório gerado com sucesso!', 'sucesso');
    }, 2000);
}

function filtrarPorStatus(status) {
    console.log('Filtrando por status:', status);
    // Implementar filtro por status
    mostrarNotificacao(`Filtrando por: ${status}`, 'info');
}

// ===== ANIMAÇÕES =====
function animarElementos() {
    animarCardsStatus();
    animarTabela();
    animarAtividades();
}

function animarCardsStatus() {
    elementos.cardsStatus.forEach((card, index) => {
        setTimeout(() => {
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
        }, index * 150);
    });
}

function animarTabela() {
    const linhasTabela = document.querySelectorAll('.tabela-recentes tbody tr');
    linhasTabela.forEach((linha, index) => {
        setTimeout(() => {
            linha.style.opacity = '1';
            linha.style.transform = 'translateX(0)';
        }, 600 + index * 100);
    });
}

function animarAtividades() {
    const atividades = document.querySelectorAll('.activity-item');
    atividades.forEach((atividade, index) => {
        setTimeout(() => {
            atividade.style.opacity = '1';
            atividade.style.transform = 'translateX(0)';
        }, 1000 + index * 150);
    });
}

// ===== ATUALIZAÇÃO EM TEMPO REAL =====
function iniciarAtualizacaoTempoReal() {
    if (!estado.tempoRealAtivo) return;
    
    setInterval(() => {
        if (document.visibilityState === 'visible') {
            atualizarDadosTempoReal();
        }
    }, CONFIG.ATUALIZACAO_TEMPO_REAL);
}

function atualizarDadosTempoReal() {
    // Atualizar contadores
    elementos.cardsStatus.forEach(card => {
        const valorElemento = card.querySelector('.card-value');
        let valorAtual = parseInt(valorElemento.textContent);
        const variacao = Math.floor(Math.random() * 5) - 2;
        const novoValor = Math.max(0, valorAtual + variacao);
        
        // Animação de contagem
        animarContagem(valorElemento, valorAtual, novoValor);
        
        // Atualizar tendência
        const tendencia = card.querySelector('.card-trend');
        if (variacao > 0) {
            tendencia.className = 'card-trend up';
            tendencia.innerHTML = '<i class="fas fa-arrow-up"></i> ' + Math.abs(variacao);
        } else if (variacao < 0) {
            tendencia.className = 'card-trend down';
            tendencia.innerHTML = '<i class="fas fa-arrow-down"></i> ' + Math.abs(variacao);
        }
    });
    
    document.dispatchEvent(new CustomEvent('dadosAtualizados'));
}

function animarContagem(elemento, valorInicial, valorFinal) {
    const duracao = 1000;
    const intervalo = 30;
    const passos = duracao / intervalo;
    const incremento = (valorFinal - valorInicial) / passos;
    let valorAtual = valorInicial;
    
    const timer = setInterval(() => {
        valorAtual += incremento;
        
        if ((incremento > 0 && valorAtual >= valorFinal) || 
            (incremento < 0 && valorAtual <= valorFinal)) {
            elemento.textContent = Math.round(valorFinal);
            clearInterval(timer);
        } else {
            elemento.textContent = Math.round(valorAtual);
        }
    }, intervalo);
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
        
        // Observar elementos que podem beneficiar do lazy loading
        document.querySelectorAll('.card, .chart-container, .activity-item').forEach(el => {
            observer.observe(el);
        });
    }
}

// ===== SERVICE WORKER (CACHE E OFFLINE) =====
function configurarServiceWorker() {
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('/sw.js')
            .then(registration => {
                console.log('SW registered: ', registration);
            })
            .catch(registrationError => {
                console.log('SW registration failed: ', registrationError);
            });
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
    
    document.body.appendChild(toast);
    
    // Trigger reflow
    toast.offsetHeight;
    
    toast.classList.add('show');
    
    setTimeout(() => {
        toast.classList.remove('show');
        setTimeout(() => toast.remove(), 300);
    }, CONFIG.NOTIFICACAO_TIMEOUT);
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

function formatarNumero(numero) {
    if (numero >= 1000000) {
        return (numero / 1000000).toFixed(1) + 'M';
    } else if (numero >= 1000) {
        return (numero / 1000).toFixed(1) + 'K';
    }
    return numero;
}

function handleKeyboardShortcuts(e) {
    // Ctrl/Cmd + K para focar na pesquisa
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        elementos.searchInput.focus();
    }
    
    // Esc para limpar pesquisa
    if (e.key === 'Escape' && document.activeElement === elementos.searchInput) {
        elementos.searchInput.value = '';
        pesquisarConteudo({ target: elementos.searchInput });
        elementos.searchInput.blur();
    }
}

// ===== EXPORTAÇÃO PARA USO EXTERNO =====
window.Dashboard = {
    toggleMenu: toggleMenuLateral,
    toggleDarkMode: toggleModoEscuro,
    exportarDados: exportarDados,
    atualizarGrafico: atualizarGrafico,
    mostrarNotificacao: mostrarNotificacao
};