document.addEventListener('DOMContentLoaded', () => {
    // Cache de elementos do DOM
    const domElements = {
        selectAllCheckbox: document.getElementById('select-all'),
        rowCheckboxes: document.querySelectorAll('.row-checkbox'),
        tableHeaders: document.querySelectorAll('th:not(.check-column)'),
        tableBody: document.querySelector('tbody'),
        tableRows: document.querySelectorAll('tbody tr'),
        applyFiltersButton: document.querySelector('.botao-primario'),
        clearFiltersButton: document.querySelector('.botao-secundario'),
        searchInput: document.querySelector('.search-box input'),
        paginationButtons: document.querySelectorAll('.btn-pagina'),
        modalView: document.getElementById('modal-view'),
        modalClose: document.querySelector('.modal-close'),
        modalSecondaryBtn: document.querySelector('.modal-footer .btn-secondary'),
        menuToggle: document.getElementById('menuToggle')
    };

    // Estado da aplicação
    const appState = {
        sortColumn: null,
        sortDirection: 'asc',
        currentPage: 1,
        totalPages: 10,
        selectedRows: new Set()
    };

    domElements.menuToggle.addEventListener('click', () => {
    document.querySelector('.barra-lateral').classList.toggle('open');
});


    document.addEventListener('click', (e) => {
        const sidebar = document.querySelector('.barra-lateral');
        const menuToggle = document.getElementById('menuToggle');
        
        if (sidebar.classList.contains('open') && 
            !sidebar.contains(e.target) && 
            e.target !== menuToggle && 
            !menuToggle.contains(e.target)) {
            sidebar.classList.remove('open');
        }
    });

    
    // --- Lógica de Seleção de Linhas ---
    domElements.selectAllCheckbox.addEventListener('change', function() {
        const isChecked = this.checked;
        domElements.rowCheckboxes.forEach(checkbox => {
            checkbox.checked = isChecked;
        });
        updateSelectedCount();
    });

    domElements.rowCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', updateSelectedCount);
    });

    function updateSelectedCount() {
        const selectedCount = document.querySelectorAll('.row-checkbox:checked').length;
        document.querySelector('.resultados-info span').textContent = `${selectedCount} itens selecionados`;
    }

    // --- Lógica do Modal de Visualização ---
    document.addEventListener('click', function(event) {
        if (event.target.closest('.botao-acao.view')) {
            const button = event.target.closest('.botao-acao.view');
            const row = button.closest('tr');
            
            if (row) {
                fillModalWithData(row);
                openModal();
            }
        }
        
        
        if (event.target === domElements.modalView || 
            event.target === domElements.modalClose || 
            event.target === domElements.modalSecondaryBtn) {
            closeModal();
        }
    });

    function openModal() {
        domElements.modalView.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        document.addEventListener('keydown', handleEscapeKey);
    }

    function closeModal() {
        domElements.modalView.style.display = 'none';
        document.body.style.overflow = '';
        document.removeEventListener('keydown', handleEscapeKey);
    }

    function handleEscapeKey(event) {
        if (event.key === 'Escape') {
            closeModal();
        }
    }

    function fillModalWithData(row) {
        const reportId = row.cells[1].textContent;
        const problem = row.cells[2].textContent;
        const category = row.cells[3].textContent;
        const neighborhood = row.cells[4].textContent;
        const date = row.cells[5].textContent;
        
        
        const priorityElement = row.cells[6].querySelector('.prioridade');
        const statusElement = row.cells[7].querySelector('.status');
        
        const priority = priorityElement ? priorityElement.textContent : 'N/A';
        const status = statusElement ? statusElement.textContent : 'N/A';
        const priorityClass = priorityElement ? priorityElement.className : '';
        const statusClass = statusElement ? statusElement.className : '';

        
        document.querySelector('#modal-view h3').textContent = `Detalhes do Report ${reportId}`;

        const modal = domElements.modalView;
        
        // Preencher informações básicas
        const infoItems = modal.querySelectorAll('.info-item');
        if (infoItems.length >= 5) {
            infoItems[0].querySelector('.info-value').textContent = problem;
            infoItems[1].querySelector('.info-value').textContent = `${problem} na região do ${neighborhood}`;
            infoItems[2].querySelector('.info-value').textContent = `${neighborhood}, Feira de Santana - BA`;
            infoItems[3].querySelector('.info-value').textContent = `${date} 14:30`;
            infoItems[4].querySelector('.info-value').textContent = "Cidadão";
        }

        // Preencher status e prioridade
        const statusInfo = modal.querySelector('.status-info');
        if (statusInfo) {
            const statusElementModal = statusInfo.querySelector('.status');
            const priorityElementModal = statusInfo.querySelector('.prioridade');
            
            if (statusElementModal) {
                statusElementModal.textContent = status;
                statusElementModal.className = 'status ' + statusClass.replace('status ', '');
            }
            
            if (priorityElementModal) {
                priorityElementModal.textContent = priority;
                priorityElementModal.className = 'prioridade ' + priorityClass.replace('prioridade ', '');
            }
        }
    }

    // --- Lógica dos Botões de Ação da Tabela ---
    
    document.addEventListener('click', function(event) {
        // Verificar se o clique foi em um botão de editar
        if (event.target.closest('.botao-acao.edit')) {
            const button = event.target.closest('.botao-acao.edit');
            const row = button.closest('tr');
            const reportId = row.cells[1].textContent;
            alert(`Editando report ${reportId}`);
        }
        
        // Verificar se o clique foi em um botão de excluir
        if (event.target.closest('.botao-acao.delete')) {
            const button = event.target.closest('.botao-acao.delete');
            const row = button.closest('tr');
            const reportId = row.cells[1].textContent;

            if (confirm(`Tem certeza que deseja excluir o report ${reportId}?`)) {
                row.style.opacity = '0.5';
                button.disabled = true;

                setTimeout(() => {
                    row.remove();
                    updateSelectedCount();
                    alert(`Report ${reportId} excluído com sucesso!`);
                }, 500);
            }
        }
    });

    // --- Lógica de Ordenação da Tabela ---
    domElements.tableHeaders.forEach(header => {
        header.addEventListener('click', () => {
            const columnIndex = Array.from(header.parentNode.children).indexOf(header);
            sortTable(columnIndex, header);
        });
    });

    function sortTable(columnIndex, header) {
        const rows = Array.from(domElements.tableRows);
        const direction = appState.sortColumn === columnIndex && appState.sortDirection === 'asc' ? 'desc' : 'asc';

        domElements.tableHeaders.forEach(h => {
            h.querySelector('i').className = 'fas fa-sort';
        });

        header.querySelector('i').className = `fas fa-sort-${direction === 'asc' ? 'up' : 'down'}`;

        rows.sort((a, b) => {
            let aValue = a.cells[columnIndex].textContent.trim();
            let bValue = b.cells[columnIndex].textContent.trim();

            if (columnIndex === 1 || columnIndex === 5) {
                aValue = columnIndex === 1 ? parseInt(aValue.replace('#', '')) : new Date(aValue.split('/').reverse().join('-'));
                bValue = columnIndex === 1 ? parseInt(bValue.replace('#', '')) : new Date(bValue.split('/').reverse().join('-'));
            }

            if (aValue < bValue) return direction === 'asc' ? -1 : 1;
            if (aValue > bValue) return direction === 'asc' ? 1 : -1;
            return 0;
        });

        rows.forEach(row => domElements.tableBody.appendChild(row));

        appState.sortColumn = columnIndex;
        appState.sortDirection = direction;
    }

    // --- Lógica dos Filtros e Pesquisa ---
    domElements.applyFiltersButton.addEventListener('click', () => {
        const filters = {
            neighborhood: document.querySelector('.filter-input[placeholder="Bairro"]').value,
            date: document.querySelector('.filter-input[placeholder="Data"]').value,
            status: document.querySelector('.secao-filtros select:first-of-type').value,
            category: document.querySelector('.secao-filtros select:last-of-type').value
        };
        applyFilters(filters);
    });

    function applyFilters(filters) {
        const rows = domElements.tableRows;
        let visibleCount = 0;

        rows.forEach(row => {
            const neighborhood = row.cells[4].textContent.toLowerCase();
            const date = formatDateForComparison(row.cells[5].textContent);
            const status = row.cells[7].querySelector('.status').className.includes(filters.status) || filters.status === 'todos';
            const category = row.cells[3].textContent.toLowerCase().includes(filters.category) || filters.category === 'todos';

            const neighborhoodMatch = !filters.neighborhood || neighborhood.includes(filters.neighborhood.toLowerCase());
            const dateMatch = !filters.date || date === filters.date;

            if (neighborhoodMatch && dateMatch && status && category) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        document.querySelector('.tabela-info span').textContent = `Mostrando ${visibleCount} de ${rows.length} resultados`;
    }

    function formatDateForComparison(dateString) {
        const parts = dateString.split('/');
        return `${parts[2]}-${parts[1]}-${parts[0]}`;
    }

    domElements.clearFiltersButton.addEventListener('click', () => {
        const filterInputs = document.querySelectorAll('.secao-filtros input, .secao-filtros select');
        filterInputs.forEach(input => {
            if (input.type === 'text' || input.type === 'date') {
                input.value = '';
            } else if (input.tagName === 'SELECT') {
                input.selectedIndex = 0;
            }
        });

        domElements.tableRows.forEach(row => {
            row.style.display = '';
        });

        document.querySelector('.tabela-info span').textContent = `Mostrando ${domElements.tableRows.length} de ${domElements.tableRows.length} resultados`;
    });

    
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

    domElements.searchInput.addEventListener('input', debounce((event) => {
        const searchTerm = event.target.value.toLowerCase().trim();
        let visibleCount = 0;

        domElements.tableRows.forEach(row => {
            const rowText = row.textContent.toLowerCase();
            if (rowText.includes(searchTerm)) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });

        document.querySelector('.tabela-info span').textContent = `Mostrando ${visibleCount} de ${domElements.tableRows.length} resultados`;
    }, 300));

    // --- Lógica de Paginação ---
    domElements.paginationButtons.forEach(button => {
        button.addEventListener('click', (e) => {
            e.preventDefault();
            const action = button.querySelector('i');

            if (action) {
                if (action.classList.contains('fa-chevron-left')) {
                    if (appState.currentPage > 1) navigateToPage(appState.currentPage - 1);
                } else if (action.classList.contains('fa-chevron-right')) {
                    if (appState.currentPage < appState.totalPages) navigateToPage(appState.currentPage + 1);
                }
            } else if (!isNaN(button.textContent)) {
                navigateToPage(parseInt(button.textContent));
            }
        });
    });

    function navigateToPage(page) {
        appState.currentPage = page;

        document.querySelectorAll('.btn-pagina').forEach(btn => {
            btn.classList.remove('active');
            if (parseInt(btn.textContent) === page) {
                btn.classList.add('active');
            }
        });

        document.querySelector('.tabela-info span').textContent = `Página ${page} de ${appState.totalPages}`;

        document.querySelector('.container-tabela').scrollIntoView({ behavior: 'smooth' });
    }

    // --- Inicialização ---
    function init() {
        domElements.tableRows.forEach((row, index) => {
            if (!row.dataset.id) {
                row.dataset.id = `row-${index}`;
            }
        });
        updateSelectedCount();
    }

    init();
});