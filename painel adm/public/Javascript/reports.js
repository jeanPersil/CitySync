// ==================================
// 1. CONFIGURAÇÃO INICIAL
// ==================================

document.addEventListener('DOMContentLoaded', function() {
    // Verificar se estamos na página correta
    if (!document.querySelector('.container-painel')) {
        return;
    }

    // Inicializar todas as funcionalidades
    initDarkMode();
    initMenuToggle();
    initModal();
    initTableInteractions();
    initFilters();
});

// ==================================
// 2. MODO ESCURO
// ==================================

function initDarkMode() {
    const darkModeToggle = document.getElementById('dark-mode-toggle');
    const body = document.body;

    // Verificar preferência salva
    const isDarkMode = localStorage.getItem('darkMode') === 'true';
    
    if (isDarkMode) {
        body.classList.add('dark-mode');
        darkModeToggle.checked = true;
    }

    // Alternar modo escuro
    darkModeToggle.addEventListener('change', function() {
        body.classList.toggle('dark-mode');
        localStorage.setItem('darkMode', body.classList.contains('dark-mode'));
    });
}

// ==================================
// 3. MENU MOBILE
// ==================================

function initMenuToggle() {
    const menuToggle = document.getElementById('menuToggle');
    const sidebar = document.querySelector('.barra-lateral');
    const overlay = document.getElementById('overlay');

    if (!menuToggle || !sidebar) return;

    menuToggle.addEventListener('click', function() {
        sidebar.classList.toggle('open');
        overlay.classList.toggle('active');
        document.body.style.overflow = sidebar.classList.contains('open') ? 'hidden' : '';
    });

    // Fechar menu ao clicar no overlay
    overlay.addEventListener('click', function() {
        sidebar.classList.remove('open');
        overlay.classList.remove('active');
        document.body.style.overflow = '';
    });

    // Fechar menu ao redimensionar a tela
    window.addEventListener('resize', function() {
        if (window.innerWidth > 992) {
            sidebar.classList.remove('open');
            overlay.classList.remove('active');
            document.body.style.overflow = '';
        }
    });
}

// ==================================
// 4. MODAL (CORRIGIDO)
// ==================================

function initModal() {
    const modal = document.getElementById('reportModal');
    const viewButtons = document.querySelectorAll('.view-btn');
    const closeButton = document.getElementById('modalClose');
    const modalCloseBtn = document.querySelector('.modal-footer .btn-secondary');

    // Dados de exemplo para os reports
    const reportsData = {
        '001': {
            bairro: 'Centro',
            data: '15/12/2024',
            categoria: 'Iluminação Pública',
            descricao: 'Poste de luz quebrado na Rua Principal, próximo ao número 123. A lâmpada está piscando intermitentemente, causando insegurança na área.',
            status: 'Pendente',
            prioridade: 'Urgente',
            responsavel: 'João Silva',
            dataPrevista: '20/12/2024'
        },
        '002': {
            bairro: 'Jardim das Flores',
            data: '14/12/2024',
            categoria: 'Buraco na Via',
            descricao: 'Buraco de aproximadamente 50cm de diâmetro na Avenida das Flores, próximo ao supermercado. Risco de acidentes.',
            status: 'Em andamento',
            prioridade: 'Alta',
            responsavel: 'Maria Santos',
            dataPrevista: '18/12/2024'
        },
        '003': {
            bairro: 'Vila Nova',
            data: '13/12/2024',
            categoria: 'Coleta de Lixo',
            descricao: 'Lixo acumulado há 3 dias no ponto de coleta da Rua Nova Esperança. Odor forte e risco de proliferação de animais.',
            status: 'Resolvido',
            prioridade: 'Média',
            responsavel: 'Pedro Costa',
            dataPrevista: '15/12/2024'
        }
    };

    // Abrir modal
    viewButtons.forEach(button => {
        button.addEventListener('click', function() {
            const reportId = this.getAttribute('data-id');
            const reportData = reportsData[reportId];
            
            if (reportData) {
                // Preencher dados do modal
                document.getElementById('modalReportId').textContent = reportId;
                document.getElementById('modalBairro').textContent = reportData.bairro;
                document.getElementById('modalData').textContent = reportData.data;
                document.getElementById('modalCategoria').textContent = reportData.categoria;
                document.getElementById('modalDescricao').textContent = reportData.descricao;
                document.getElementById('modalStatus').textContent = reportData.status;
                document.getElementById('modalPrioridade').textContent = reportData.prioridade;
                document.getElementById('modalResponsavel').textContent = reportData.responsavel;
                document.getElementById('modalDataPrevista').textContent = reportData.dataPrevista;

                // Mostrar modal
                modal.classList.add('active');
                document.body.style.overflow = 'hidden';
            }
        });
    });

    // Fechar modal
    function closeModal() {
        modal.classList.remove('active');
        document.body.style.overflow = '';
    }

    // Event listeners para fechar modal
    if (closeButton) {
        closeButton.addEventListener('click', closeModal);
    }

    if (modalCloseBtn) {
        modalCloseBtn.addEventListener('click', closeModal);
    }

    // Fechar modal clicando fora
    modal.addEventListener('click', function(event) {
        if (event.target === modal) {
            closeModal();
        }
    });

    // Fechar modal com ESC
    document.addEventListener('keydown', function(event) {
        if (event.key === 'Escape' && modal.classList.contains('active')) {
            closeModal();
        }
    });
}

// ==================================
// 5. INTERAÇÕES DA TABELA
// ==================================

function initTableInteractions() {
    // Seleção de linhas com checkbox
    const checkboxes = document.querySelectorAll('tbody input[type="checkbox"]');
    const headerCheckbox = document.querySelector('thead input[type="checkbox"]');

    // Selecionar/deselecionar todos
    if (headerCheckbox) {
        headerCheckbox.addEventListener('change', function() {
            const isChecked = this.checked;
            checkboxes.forEach(checkbox => {
                checkbox.checked = isChecked;
                toggleRowSelection(checkbox);
            });
        });
    }

    // Selecionar linha individual
    checkboxes.forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            toggleRowSelection(this);
            updateHeaderCheckbox();
        });
    });

    function toggleRowSelection(checkbox) {
        const row = checkbox.closest('tr');
        if (checkbox.checked) {
            row.classList.add('selected');
        } else {
            row.classList.remove('selected');
        }
    }

    function updateHeaderCheckbox() {
        if (!headerCheckbox) return;
        
        const checkedCount = document.querySelectorAll('tbody input[type="checkbox"]:checked').length;
        const totalCount = checkboxes.length;
        
        headerCheckbox.checked = checkedCount === totalCount;
        headerCheckbox.indeterminate = checkedCount > 0 && checkedCount < totalCount;
    }

    // Ordenação de colunas
    const sortButtons = document.querySelectorAll('th i.fa-sort');
    sortButtons.forEach(button => {
        button.addEventListener('click', function() {
            const th = this.closest('th');
            const columnIndex = Array.from(th.parentNode.children).indexOf(th);
            sortTable(columnIndex);
        });
    });
}

function sortTable(columnIndex) {
    const table = document.querySelector('table');
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr'));
    const isAscending = !table.querySelector('th').classList.contains('asc');
    
    rows.sort((a, b) => {
        const aValue = a.children[columnIndex].textContent.trim();
        const bValue = b.children[columnIndex].textContent.trim();
        
        // Verificar se são números
        if (!isNaN(aValue) && !isNaN(bValue)) {
            return isAscending ? aValue - bValue : bValue - aValue;
        }
        
        // Comparação de strings
        return isAscending ? 
            aValue.localeCompare(bValue, 'pt-BR') : 
            bValue.localeCompare(aValue, 'pt-BR');
    });
    
    // Remover linhas existentes
    while (tbody.firstChild) {
        tbody.removeChild(tbody.firstChild);
    }
    
    // Adicionar linhas ordenadas
    rows.forEach(row => tbody.appendChild(row));
    
    // Atualizar indicadores de ordenação
    table.querySelectorAll('th').forEach(th => {
        th.classList.remove('asc', 'desc');
    });
    
    const currentTh = table.querySelectorAll('th')[columnIndex];
    currentTh.classList.add(isAscending ? 'asc' : 'desc');
}

// ==================================
// 6. FILTROS E PESQUISA
// ==================================

function initFilters() {
    const searchInput = document.querySelector('.search-field input');
    const filterInputs = document.querySelectorAll('.filter-input, .select-field select');
    const applyFiltersBtn = document.querySelector('.botao-primario');
    const clearFiltersBtn = document.querySelector('.botao-secundario');

    // Aplicar filtros
    if (applyFiltersBtn) {
        applyFiltersBtn.addEventListener('click', applyFilters);
    }

    // Limpar filtros
    if (clearFiltersBtn) {
        clearFiltersBtn.addEventListener('click', clearFilters);
    }

    // Pesquisa em tempo real
    if (searchInput) {
        searchInput.addEventListener('input', debounce(applyFilters, 300));
    }

    function applyFilters() {
        const searchTerm = searchInput ? searchInput.value.toLowerCase() : '';
        const rows = document.querySelectorAll('tbody tr');
        
        rows.forEach(row => {
            let shouldShow = true;
            const cells = row.querySelectorAll('td');
            
            // Aplicar pesquisa geral
            if (searchTerm) {
                const rowText = Array.from(cells).map(cell => cell.textContent.toLowerCase()).join(' ');
                shouldShow = rowText.includes(searchTerm);
            }
            
            // Aplicar outros filtros
            filterInputs.forEach((input, index) => {
                if (index > 0 && shouldShow) { // Pular o campo de pesquisa
                    const filterValue = input.value.toLowerCase();
                    if (filterValue && filterValue !== 'todos') {
                        const cellIndex = index + 1; // Ajustar índice para colunas da tabela
                        if (cells[cellIndex]) {
                            const cellText = cells[cellIndex].textContent.toLowerCase();
                            shouldShow = shouldShow && cellText.includes(filterValue);
                        }
                    }
                }
            });
            
            row.style.display = shouldShow ? '' : 'none';
        });
        
        updateTableInfo();
    }

    function clearFilters() {
        // Limpar inputs
        filterInputs.forEach(input => {
            if (input.tagName === 'SELECT') {
                input.selectedIndex = 0;
            } else {
                input.value = '';
            }
        });
        
        // Reaplicar filtros (vazios)
        applyFilters();
    }

    function updateTableInfo() {
        const visibleRows = document.querySelectorAll('tbody tr:not([style*="display: none"])');
        const totalRows = document.querySelectorAll('tbody tr').length;
        const infoElement = document.querySelector('.tabela-info span');
        
        if (infoElement) {
            infoElement.textContent = `Mostrando 1-${visibleRows.length} de ${totalRows} resultados`;
        }
    }

    // Debounce para pesquisa
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
}

// ==================================
// 7. PAGINAÇÃO
// ==================================

function initPagination() {
    const paginationButtons = document.querySelectorAll('.btn-pagina');
    
    paginationButtons.forEach(button => {
        button.addEventListener('click', function() {
            if (this.classList.contains('active')) return;
            
            // Remover classe active de todos os botões
            paginationButtons.forEach(btn => btn.classList.remove('active'));
            
            // Adicionar classe active ao botão clicado
            this.classList.add('active');
            
            // Aqui você implementaria a lógica de paginação real
            // Por enquanto, apenas simula a mudança de página
            simulatePageChange();
        });
    });

    function simulatePageChange() {
        // Simular carregamento de nova página
        const tableBody = document.querySelector('tbody');
        tableBody.style.opacity = '0.5';
        
        setTimeout(() => {
            tableBody.style.opacity = '1';
            // Aqui você carregaria os dados da nova página
        }, 300);
    }
}

// ==================================
// 8. INICIALIZAÇÃO DA PAGINAÇÃO
// ==================================

// Chamar a inicialização da paginação
initPagination();