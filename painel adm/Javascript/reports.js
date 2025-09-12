document.addEventListener('DOMContentLoaded', () => {
    // Cache de elementos do DOM
    const domElements = {
        allCheckboxes: document.getElementById('select-all'),
        rowCheckboxes: document.querySelectorAll('.row-checkbox'),
        viewButtons: document.querySelectorAll('.botao-acao.view'),
        editButtons: document.querySelectorAll('.botao-acao.edit'),
        deleteButtons: document.querySelectorAll('.botao-acao.delete'),
        modalView: document.getElementById('modal-view'),
        tableBody: document.querySelector('.container-tabela tbody'),
        applyFiltersButton: document.querySelector('.botao-primario'),
        clearFiltersButton: document.querySelector('.botao-secundario'),
        searchInput: document.querySelector('.search-box input'),
        tableHeaders: document.querySelectorAll('th:not(.check-column):not(:last-child)'),
        paginationButtons: document.querySelectorAll('.btn-pagina, .paginacao button'),
        tableRows: document.querySelectorAll('.container-tabela tbody tr'),
        menuToggle: document.getElementById('menuToggle'), // botão hambúrguer
        sidebar: document.querySelector('.barra-lateral')  // menu lateral
    };

    // Estado da aplicação
    const appState = {
        currentPage: 1,
        totalPages: 10,
        sortColumn: null,
        sortDirection: 'asc',
        selectedRows: new Set()
    };

    // --- Utilitários ---
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

    // --- Toggle do Menu Lateral ---
    if (domElements.menuToggle && domElements.sidebar) {
        domElements.menuToggle.addEventListener('click', () => {
            domElements.sidebar.classList.toggle('open');
        });

        // Fecha ao clicar fora (mobile)
        document.addEventListener('click', (e) => {
            if (
                domElements.sidebar.classList.contains('open') &&
                !domElements.sidebar.contains(e.target) &&
                !domElements.menuToggle.contains(e.target)
            ) {
                domElements.sidebar.classList.remove('open');
            }
        });
    }

    // --- Lógica de Seleção de Linhas (Checkbox) ---
    domElements.allCheckboxes.addEventListener('change', () => {
        const isChecked = domElements.allCheckboxes.checked;
        domElements.rowCheckboxes.forEach(checkbox => {
            checkbox.checked = isChecked;
            toggleRowSelection(checkbox, isChecked);
        });
        updateSelectedCount();
    });

    domElements.rowCheckboxes.forEach(checkbox => {
        checkbox.addEventListener('change', (e) => {
            toggleRowSelection(e.target, e.target.checked);
            updateSelectAllState();
            updateSelectedCount();
        });
    });

    function toggleRowSelection(checkbox, isSelected) {
        const row = checkbox.closest('tr');
        if (isSelected) {
            appState.selectedRows.add(checkbox.value || row.dataset.id);
            row.classList.add('selected');
        } else {
            appState.selectedRows.delete(checkbox.value || row.dataset.id);
            row.classList.remove('selected');
        }
    }

    function updateSelectAllState() {
        const allChecked = domElements.rowCheckboxes.length > 0 &&
            Array.from(domElements.rowCheckboxes).every(checkbox => checkbox.checked);
        const someChecked = !allChecked &&
            Array.from(domElements.rowCheckboxes).some(checkbox => checkbox.checked);

        domElements.allCheckboxes.checked = allChecked;
        domElements.allCheckboxes.indeterminate = someChecked;
    }

    function updateSelectedCount() {
        const selectedCount = appState.selectedRows.size;
        const infoElement = document.querySelector('.resultados-info span');

        if (infoElement) {
            infoElement.textContent = `${selectedCount} item${selectedCount !== 1 ? 's' : ''} selecionado${selectedCount !== 1 ? 's' : ''}`;
        }
    }

    // --- Lógica do Modal de Visualização ---
    domElements.viewButtons.forEach(button => {
        button.addEventListener('click', (event) => {
            const row = event.target.closest('tr');
            if (row) {
                fillModalWithData(row);
                domElements.modalView.style.display = 'flex';
                document.body.style.overflow = 'hidden';
            }
        });
    });

    function fillModalWithData(row) {
        const reportId = row.cells[1].textContent;
        const problem = row.cells[2].textContent;
        const category = row.cells[3].textContent;
        const neighborhood = row.cells[4].textContent;
        const date = row.cells[5].textContent;
        const priority = row.cells[6].querySelector('.prioridade').textContent;
        const status = row.cells[7].querySelector('.status').textContent;

        document.querySelector('#modal-view h3').textContent = `Detalhes do Report ${reportId}`;

        const modal = domElements.modalView;
        modal.querySelector('.info-item:nth-child(1) .info-value').textContent = problem;
        modal.querySelector('.info-item:nth-child(2) .info-value').textContent = `${problem} na região do ${neighborhood}`;
        modal.querySelector('.info-item:nth-child(3) .info-value').textContent = `${neighborhood}, Feira de Santana - BA`;
        modal.querySelector('.info-item:nth-child(4) .info-value').textContent = `${date} 14:30`;
        modal.querySelector('.info-item:nth-child(5) .info-value').textContent = "Cidadão";

        modal.querySelector('.status-info .status').textContent = status;
        modal.querySelector('.status-info .prioridade').textContent = priority;

        const statusElement = modal.querySelector('.status-info .status');
        statusElement.className = 'status ' + (row.cells[7].querySelector('.status').className.replace('status ', ''));

        const priorityElement = modal.querySelector('.status-info .prioridade');
        priorityElement.className = 'prioridade ' + (row.cells[6].querySelector('.prioridade').className.replace('prioridade ', ''));
    }

    function closeModal() {
        domElements.modalView.style.display = 'none';
        document.body.style.overflow = '';
    }

    domElements.modalView.querySelector('.modal-close').addEventListener('click', closeModal);
    domElements.modalView.querySelector('.modal-footer .btn-secondary').addEventListener('click', closeModal);

    domElements.modalView.addEventListener('click', (event) => {
        if (event.target === domElements.modalView) {
            closeModal();
        }
    });

    document.addEventListener('keydown', (event) => {
        if (event.key === 'Escape' && domElements.modalView.style.display === 'flex') {
            closeModal();
        }
    });

    // --- Lógica dos Botões de Ação da Tabela ---
    domElements.editButtons.forEach(button => {
        button.addEventListener('click', () => {
            const row = button.closest('tr');
            const reportId = row.cells[1].textContent;
            alert(`Editando report ${reportId}`);
        });
    });

    domElements.deleteButtons.forEach(button => {
        button.addEventListener('click', () => {
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
        });
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
