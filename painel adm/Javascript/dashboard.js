// dashboard.js

document.addEventListener('DOMContentLoaded', function() {
    // ===== ELEMENTOS DO DOM =====
    const menuToggle = document.getElementById('menuToggle');
    const barraLateral = document.querySelector('.barra-lateral');
    const darkModeToggle = document.getElementById('dark-mode-toggle');
    const searchInput = document.querySelector('.search-box input');
    const chartFilter = document.querySelector('.chart-filter');
    const viewAllBtn = document.querySelector('.view-all');
    const actionButtons = document.querySelectorAll('.action-btn');
    const statusBadges = document.querySelectorAll('.status-badge');
    
    // ===== VARIÁVEIS DE ESTADO =====
    let menuAberto = true;
   
    let dadosFiltrados = false;
    
    // ===== INICIALIZAÇÃO =====
    function inicializar() {
        // Inicializar gráficos
        inicializarGraficos();
        
        // Inicializar tooltips
        inicializarTooltips();
        
        // Inicializar eventos
        configurarEventListeners();
        
        // Animar elementos da página
        animarElementos();
    }
    
    // ===== INICIALIZAR GRÁFICOS =====
    function inicializarGraficos() {
        // Animação das barras do gráfico
        const barras = document.querySelectorAll('.bar');
        barras.forEach((barra, index) => {
            setTimeout(() => {
                barra.style.transform = 'scaleY(1)';
                barra.style.opacity = '1';
            }, index * 200);
        });
        
        // Animação do gráfico de pizza
        const pizza = document.querySelector('.pie');
        setTimeout(() => {
            pizza.style.opacity = '1';
            pizza.style.transform = 'rotate(0deg)';
        }, 1000);
    }
    
    // ===== INICIALIZAR TOOLTIPS =====
    function inicializarTooltips() {
        const tooltipElements = document.querySelectorAll('[data-tooltip]');
        
        tooltipElements.forEach(element => {
            element.addEventListener('mouseenter', function(e) {
                const tooltip = document.createElement('div');
                tooltip.className = 'tooltip';
                tooltip.textContent = this.getAttribute('data-tooltip');
                document.body.appendChild(tooltip);
                
                const rect = this.getBoundingClientRect();
                tooltip.style.top = (rect.top - tooltip.offsetHeight - 10) + 'px';
                tooltip.style.left = (rect.left + rect.width / 2 - tooltip.offsetWidth / 2) + 'px';
                
                this.addEventListener('mouseleave', function() {
                    tooltip.remove();
                });
            });
        });
    }
    
    // ===== CONFIGURAR EVENT LISTENERS =====
    function configurarEventListeners() {
        // Toggle do menu lateral
        if (menuToggle) {
            menuToggle.addEventListener('click', toggleMenuLateral);
        }
        
        // Toggle do modo escuro
        if (darkModeToggle) {
            darkModeToggle.addEventListener('change', toggleModoEscuro);
        }
        
        // Filtro de pesquisa
        if (searchInput) {
            searchInput.addEventListener('input', pesquisarConteudo);
        }
        
        // Filtro do gráfico
        if (chartFilter) {
            chartFilter.addEventListener('change', filtrarGrafico);
        }
        
        // Botão "Ver todos"
        if (viewAllBtn) {
            viewAllBtn.addEventListener('click', verTodosReports);
        }
        
        // Botões de ação rápida
        actionButtons.forEach(botao => {
            botao.addEventListener('click', handleActionClick);
        });
        
        // Badges de status (exemplo de interação)
        statusBadges.forEach(badge => {
            badge.addEventListener('click', () => {
                console.log('Status clicado:', badge.textContent);
                // Aqui você pode abrir um modal ou filtrar por status
            });
        });
        
        // Evento de redimensionamento da janela
        window.addEventListener('resize', handleResize);
    }
    
    // ===== TOGGLE MENU LATERAL =====
    function toggleMenuLateral() {
        menuAberto = !menuAberto;
        
        if (menuAberto) {
            barraLateral.style.transform = 'translateX(0)';
            menuToggle.innerHTML = '<i class="fas fa-bars"></i>';
        } else {
            barraLateral.style.transform = 'translateX(-100%)';
            menuToggle.innerHTML = '<i class="fas fa-bars"></i>';
        }
        
        // Salvar preferência no localStorage
        localStorage.setItem('menuAberto', menuAberto);
    }
    
    // ===== TOGGLE MODO ESCURO =====
    function toggleModoEscuro() {
        modoEscuroAtivo = !modoEscuroAtivo;
        
        if (modoEscuroAtivo) {
            document.body.classList.add('dark-mode');
        } else {
            document.body.classList.remove('dark-mode');
        }
        
        // Salvar preferência no localStorage
        localStorage.setItem('darkMode', modoEscuroAtivo);
    }
    
    // ===== PESQUISAR CONTEÚDO =====
    function pesquisarConteudo(e) {
        const termo = e.target.value.toLowerCase();
        
        if (termo.length > 2) {
            // Filtrar tabela de problemas recentes
            const linhasTabela = document.querySelectorAll('.tabela-recentes tbody tr');
            
            linhasTabela.forEach(linha => {
                const textoLinha = linha.textContent.toLowerCase();
                if (textoLinha.includes(termo)) {
                    linha.style.display = '';
                } else {
                    linha.style.display = 'none';
                }
            });
            
            dadosFiltrados = true;
        } else if (dadosFiltrados && termo.length === 0) {
            // Mostrar todas as linhas se o campo estiver vazio
            const linhasTabela = document.querySelectorAll('.tabela-recentes tbody tr');
            linhasTabela.forEach(linha => {
                linha.style.display = '';
            });
            
            dadosFiltrados = false;
        }
    }
    
    // ===== FILTRAR GRÁFICO =====
    function filtrarGrafico(e) {
        const periodo = e.target.value;
        console.log('Filtrando gráfico para:', periodo);
        
        // Simular loading
        const chartWrapper = document.querySelector('.chart-wrapper');
        chartWrapper.style.opacity = '0.5';
        
        // Simular uma requisição assíncrona
        setTimeout(() => {
            // Aqui você faria a requisição real para buscar dados do período selecionado
            // Por enquanto, apenas atualizamos visualmente
            atualizarGrafico(periodo);
            chartWrapper.style.opacity = '1';
        }, 800);
    }
    
    function atualizarGrafico(periodo) {
        // Simular dados diferentes baseados no período
        const dados = {
            'Últimos 7 dias': [42, 51, 27, 36, 18],
            'Últimos 30 dias': [65, 78, 42, 55, 25],
            'Este mês': [35, 45, 22, 30, 15]
        };
        
        const alturas = dados[periodo] || [42, 51, 27, 36, 18];
        const barras = document.querySelectorAll('.bar');
        
        barras.forEach((barra, index) => {
            const valor = alturas[index];
            barra.style.setProperty('--height', `${valor}%`);
            barra.querySelector('.bar-value').textContent = valor;
        });
    }
    
    // ===== VER TODOS REPORTS =====
    function verTodosReports(e) {
        e.preventDefault();
        console.log('Redirecionando para página de todos os reports...');
        // window.location.href = 'gestao.html'; // Descomente para redirecionar
    }
    
    // ===== HANDLE ACTION CLICK =====
    function handleActionClick(e) {
        const acao = this.querySelector('span').textContent;
        
        switch(acao) {
            case 'Novo Report':
                window.location.href = 'novo-report.html';
                break;
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
        console.log('Exportando dados...');
        // Simular processo de exportação
        const Toast = {
            init: function() {
                const toast = document.createElement('div');
                toast.className = 'toast-message';
                toast.innerHTML = `
                    <i class="fas fa-check-circle"></i>
                    <span>Dados exportados com sucesso!</span>
                `;
                document.body.appendChild(toast);
                
                setTimeout(() => {
                    toast.classList.add('show');
                }, 100);
                
                setTimeout(() => {
                    toast.classList.remove('show');
                    setTimeout(() => {
                        toast.remove();
                    }, 300);
                }, 3000);
            }
        };
        
        Toast.init();
    }
    
    function toggleFiltros() {
        console.log('Alternando visibilidade dos filtros...');
        // Implementar lógica para mostrar/ocultar filtros avançados
    }
    
    function gerarRelatorio() {
        console.log('Gerando relatório...');
        // Implementar geração de relatório
    }
    
    // ===== HANDLE RESIZE =====
    function handleResize() {
        // Ajustar layout em telas menores
        if (window.innerWidth < 768) {
            barraLateral.style.transform = 'translateX(-100%)';
            menuAberto = false;
        } else {
            barraLateral.style.transform = 'translateX(0)';
            menuAberto = true;
        }
    }
    
    // ===== ANIMAR ELEMENTOS =====
    function animarElementos() {
        // Animar cards de status
        const cards = document.querySelectorAll('.status-card');
        cards.forEach((card, index) => {
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, index * 150);
        });
        
        // Animar tabela
        const linhasTabela = document.querySelectorAll('.tabela-recentes tbody tr');
        linhasTabela.forEach((linha, index) => {
            setTimeout(() => {
                linha.style.opacity = '1';
                linha.style.transform = 'translateX(0)';
            }, 600 + index * 100);
        });
        
        // Animar atividades
        const atividades = document.querySelectorAll('.activity-item');
        atividades.forEach((atividade, index) => {
            setTimeout(() => {
                atividade.style.opacity = '1';
                atividade.style.transform = 'translateX(0)';
            }, 1000 + index * 150);
        });
    }
    
    // ===== INICIALIZAR APLICAÇÃO =====
    inicializar();
});

// ===== FUNÇÕES ADICIONAIS =====
// Função para formatar números (ex: 1000 → 1K)
function formatarNumero(numero) {
    if (numero >= 1000000) {
        return (numero / 1000000).toFixed(1) + 'M';
    } else if (numero >= 1000) {
        return (numero / 1000).toFixed(1) + 'K';
    }
    return numero;
}

// Função para atualizar dados em tempo real (simulação)
function simularAtualizacaoEmTempoReal() {
    setInterval(() => {
        // Atualizar contadores aleatoriamente para simular dados em tempo real
        const cards = document.querySelectorAll('.status-card');
        cards.forEach(card => {
            const valorElemento = card.querySelector('.card-value');
            let valorAtual = parseInt(valorElemento.textContent);
            const variacao = Math.floor(Math.random() * 5) - 2; // -2 to +2
            const novoValor = Math.max(0, valorAtual + variacao);
            
            valorElemento.textContent = novoValor;
            
            // Atualizar tendência
            const tendencia = card.querySelector('.card-trend');
            if (variacao > 0) {
                tendencia.className = 'card-trend up';
                tendencia.innerHTML = '<i class="fas fa-arrow-up"></i> ' + Math.abs(variacao) + '%';
            } else if (variacao < 0) {
                tendencia.className = 'card-trend down';
                tendencia.innerHTML = '<i class="fas fa-arrow-down"></i> ' + Math.abs(variacao) + '%';
            }
        });
    }, 10000); // Atualizar a cada 10 segundos
}

// Iniciar simulação de atualização em tempo real após 5 segundos
setTimeout(simularAtualizacaoEmTempoReal, 5000);