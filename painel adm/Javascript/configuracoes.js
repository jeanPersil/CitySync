// ===== CONSTANTES =====
const CONFIG = {
    LOCAL_STORAGE_KEYS: {
        MODO_ESCURO: 'darkMode',
        CONFIG_PREFERENCES: 'configPreferences',
        CONFIG_SEGURANCA: 'configSeguranca'
    }
};

// ===== ELEMENTOS DO DOM =====
let elementos = {
    menuToggle: null,
    darkModeToggle: null,
    langSelect: null,
    notifyToggle: null,
    twoFAToggle: null,
    savePrefsBtn: null,
    changePasswordBtn: null,
    manageDevicesBtn: null,
    editButtons: null,
    deleteButtons: null
};

// ===== ESTADO DA APLICAÇÃO =====
let estado = {
    menuAberto: true,
    modoEscuroAtivo: false,
    preferencias: {
        idioma: 'pt',
        notificacoes: true
    },
    seguranca: {
        doisFatores: false
    }
};

// ===== INICIALIZAÇÃO =====
document.addEventListener('DOMContentLoaded', function() {
    inicializarElementos();
    carregarPreferencias();
    carregarConfiguracoes();
    inicializarAplicacao();
});

function inicializarElementos() {
    elementos = {
        menuToggle: document.getElementById('menuToggle'),
        darkModeToggle: document.getElementById('dark-mode-toggle'),
        langSelect: document.getElementById('lang'),
        notifyToggle: document.getElementById('notify'),
        twoFAToggle: document.getElementById('2fa'),
        savePrefsBtn: document.querySelector('.action-btn'),
        changePasswordBtn: document.querySelectorAll('.botao-acao')[0],
        manageDevicesBtn: document.querySelectorAll('.botao-acao')[1],
        editButtons: document.querySelectorAll('.botao-acao:nth-child(1)'),
        deleteButtons: document.querySelectorAll('.botao-acao:nth-child(2)')
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

function carregarConfiguracoes() {
    // Carregar preferências do sistema
    const prefsSalvas = localStorage.getItem(CONFIG.LOCAL_STORAGE_KEYS.CONFIG_PREFERENCES);
    if (prefsSalvas) {
        estado.preferencias = JSON.parse(prefsSalvas);
        atualizarInterfacePreferencias();
    }
    
    // Carregar configurações de segurança
    const segurancaSalva = localStorage.getItem(CONFIG.LOCAL_STORAGE_KEYS.CONFIG_SEGURANCA);
    if (segurancaSalva) {
        estado.seguranca = JSON.parse(segurancaSalva);
        atualizarInterfaceSeguranca();
    }
}

function inicializarAplicacao() {
    configurarEventListeners();
}

// ===== CONFIGURAR EVENT LISTENERS =====
function configurarEventListeners() {
    // Menu toggle
    if (elementos.menuToggle) {
        elementos.menuToggle.addEventListener('click', toggleMenuLateral);
    }
    
    // Dark mode toggle
    if (elementos.darkModeToggle) {
        elementos.darkModeToggle.addEventListener('change', toggleModoEscuro);
    }
    
    // Preferências do sistema
    if (elementos.langSelect) {
        elementos.langSelect.addEventListener('change', () => {
            estado.preferencias.idioma = elementos.langSelect.value;
        });
    }
    
    if (elementos.notifyToggle) {
        elementos.notifyToggle.addEventListener('change', () => {
            estado.preferencias.notificacoes = elementos.notifyToggle.checked;
        });
    }
    
    // Botão salvar preferências
    if (elementos.savePrefsBtn) {
        elementos.savePrefsBtn.addEventListener('click', salvarPreferencias);
    }
    
    // Segurança
    if (elementos.twoFAToggle) {
        elementos.twoFAToggle.addEventListener('change', () => {
            estado.seguranca.doisFatores = elementos.twoFAToggle.checked;
            if (elementos.twoFAToggle.checked) {
                mostrarModal2FA();
            }
        });
    }
    
    // Botões de ação
    if (elementos.changePasswordBtn) {
        elementos.changePasswordBtn.addEventListener('click', alterarSenha);
    }
    
    if (elementos.manageDevicesBtn) {
        elementos.manageDevicesBtn.addEventListener('click', gerenciarDispositivos);
    }
    
    // Botões de edição e exclusão na tabela
    elementos.editButtons.forEach((btn, index) => {
        if (index > 1) { 
            btn.addEventListener('click', () => editarUsuario(index - 2));
        }
    });
    
    elementos.deleteButtons.forEach((btn, index) => {
        btn.addEventListener('click', () => excluirUsuario(index));
    });
    
    // Evento de redimensionamento
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

// ===== ATUALIZAR INTERFACES =====
function atualizarInterfacePreferencias() {
    if (elementos.langSelect) {
        elementos.langSelect.value = estado.preferencias.idioma;
    }
    
    if (elementos.notifyToggle) {
        elementos.notifyToggle.checked = estado.preferencias.notificacoes;
    }
}

function atualizarInterfaceSeguranca() {
    if (elementos.twoFAToggle) {
        elementos.twoFAToggle.checked = estado.seguranca.doisFatores;
    }
}

// ===== SALVAR PREFERÊNCIAS =====
function salvarPreferencias(e) {
    if (e) e.preventDefault();
    
    
    localStorage.setItem(
        CONFIG.LOCAL_STORAGE_KEYS.CONFIG_PREFERENCES, 
        JSON.stringify(estado.preferencias)
    );
    
    localStorage.setItem(
        CONFIG.LOCAL_STORAGE_KEYS.CONFIG_SEGURANCA, 
        JSON.stringify(estado.seguranca)
    );
    
    
    mostrarNotificacao('Configurações salvas com sucesso!', 'sucesso');
}

// ===== SEGURANÇA =====
function alterarSenha() {
    mostrarModalAlteracaoSenha();
}

function gerenciarDispositivos() {
    mostrarNotificacao('Funcionalidade de gerenciamento de dispositivos em desenvolvimento.', 'info');
}

function mostrarModal2FA() {
    // Simulação de modal para configurar 2FA
    const modalHTML = `
        <div class="modal-overlay" id="modal2FA">
            <div class="modal">
                <h3>Configurar Autenticação de Dois Fatores</h3>
                <p>Escaneie o código QR com seu aplicativo autenticador:</p>
                <div class="qr-code-placeholder" style="width: 200px; height: 200px; background: #f0f0f0; margin: 15px auto; display: flex; align-items: center; justify-content: center;">
                    <i class="fas fa-qrcode" style="font-size: 48px; color: #ccc;"></i>
                </div>
                <p>Ou insira manualmente: <code>ABCD-EFGH-IJKL-MNOP</code></p>
                <div class="modal-actions">
                    <button class="botao-acao" id="confirmar2FA">Confirmar</button>
                    <button class="botao-acao secundario" id="cancelar2FA">Cancelar</button>
                </div>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
    
    
    document.getElementById('confirmar2FA').addEventListener('click', () => {
        estado.seguranca.doisFatores = true;
        elementos.twoFAToggle.checked = true;
        document.getElementById('modal2FA').remove();
        mostrarNotificacao('Autenticação de dois fatores ativada com sucesso!', 'sucesso');
    });
    
    document.getElementById('cancelar2FA').addEventListener('click', () => {
        estado.seguranca.doisFatores = false;
        elementos.twoFAToggle.checked = false;
        document.getElementById('modal2FA').remove();
    });
}

function mostrarModalAlteracaoSenha() {
    // Simulação de modal para alterar senha
    const modalHTML = `
        <div class="modal-overlay" id="modalSenha">
            <div class="modal">
                <h3>Alterar Senha</h3>
                <div class="form-group">
                    <label for="senhaAtual">Senha Atual:</label>
                    <input type="password" id="senhaAtual" required>
                </div>
                <div class="form-group">
                    <label for="novaSenha">Nova Senha:</label>
                    <input type="password" id="novaSenha" required>
                </div>
                <div class="form-group">
                    <label for="confirmarSenha">Confirmar Nova Senha:</label>
                    <input type="password" id="confirmarSenha" required>
                </div>
                <div class="modal-actions">
                    <button class="action-btn" id="confirmarSenha">Alterar Senha</button>
                    <button class="botao-acao secundario" id="cancelarSenha">Cancelar</button>
                </div>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
    
    
    document.getElementById('confirmarSenha').addEventListener('click', () => {
        const senhaAtual = document.getElementById('senhaAtual').value;
        const novaSenha = document.getElementById('novaSenha').value;
        const confirmarSenha = document.getElementById('confirmarSenha').value;
        
        if (!senhaAtual || !novaSenha || !confirmarSenha) {
            mostrarNotificacao('Por favor, preencha todos os campos.', 'erro');
            return;
        }
        
        if (novaSenha !== confirmarSenha) {
            mostrarNotificacao('As senhas não coincidem.', 'erro');
            return;
        }
        
        if (novaSenha.length < 6) {
            mostrarNotificacao('A senha deve ter pelo menos 6 caracteres.', 'erro');
            return;
        }
        
        
        document.getElementById('modalSenha').remove();
        mostrarNotificacao('Senha alterada com sucesso!', 'sucesso');
    });
    
    document.getElementById('cancelarSenha').addEventListener('click', () => {
        document.getElementById('modalSenha').remove();
    });
}

// ===== GERENCIAMENTO DE USUÁRIOS =====
function editarUsuario(index) {
    const linhas = document.querySelectorAll('.tabela-configuracoes tbody tr');
    if (linhas[index]) {
        const nome = linhas[index].querySelector('td:first-child').textContent;
        mostrarNotificacao(`Editando usuário: ${nome}`, 'info');
        
        // Simulação de modal de edição
        setTimeout(() => {
            mostrarModalEdicaoUsuario(linhas[index]);
        }, 500);
    }
}

function excluirUsuario(index) {
    const linhas = document.querySelectorAll('.tabela-configuracoes tbody tr');
    if (linhas[index]) {
        const nome = linhas[index].querySelector('td:first-child').textContent;
        
        // Modal de confirmação
        const modalHTML = `
            <div class="modal-overlay" id="modalExcluir">
                <div class="modal">
                    <h3>Confirmar Exclusão</h3>
                    <p>Tem certeza que deseja excluir o usuário <strong>${nome}</strong>?</p>
                    <div class="modal-actions">
                        <button class="botao-acao perigo" id="confirmarExclusao">Excluir</button>
                        <button class="botao-acao secundario" id="cancelarExclusao">Cancelar</button>
                    </div>
                </div>
            </div>
        `;
        
        document.body.insertAdjacentHTML('beforeend', modalHTML);
        
        
        document.getElementById('confirmarExclusao').addEventListener('click', () => {
            
            linhas[index].remove();
            document.getElementById('modalExcluir').remove();
            mostrarNotificacao('Usuário excluído com sucesso!', 'sucesso');
        });
        
        document.getElementById('cancelarExclusao').addEventListener('click', () => {
            document.getElementById('modalExcluir').remove();
        });
    }
}

function mostrarModalEdicaoUsuario(linha) {
    const nome = linha.querySelector('td:first-child').textContent;
    const funcao = linha.querySelector('td:nth-child(2)').textContent;
    const status = linha.querySelector('.status').classList.contains('status-ativo');
    
    const modalHTML = `
        <div class="modal-overlay" id="modalEdicao">
            <div class="modal">
                <h3>Editar Usuário</h3>
                <div class="form-group">
                    <label for="editNome">Nome:</label>
                    <input type="text" id="editNome" value="${nome}" required>
                </div>
                <div class="form-group">
                    <label for="editFuncao">Função:</label>
                    <select id="editFuncao">
                        <option value="Administrador" ${funcao === 'Administrador' ? 'selected' : ''}>Administrador</option>
                        <option value="Moderador" ${funcao === 'Moderador' ? 'selected' : ''}>Moderador</option>
                        <option value="Usuário" ${funcao === 'Usuário' ? 'selected' : ''}>Usuário</option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="editStatus">Status:</label>
                    <label class="switch">
                        <input type="checkbox" id="editStatus" ${status ? 'checked' : ''}>
                        <span class="slider round"></span>
                    </label>
                    <span>${status ? 'Ativo' : 'Inativo'}</span>
                </div>
                <div class="modal-actions">
                    <button class="action-btn" id="salvarEdicao">Salvar</button>
                    <button class="botao-acao secundario" id="cancelarEdicao">Cancelar</button>
                </div>
            </div>
        </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
    
    // Configurar eventos do modal
    document.getElementById('salvarEdicao').addEventListener('click', () => {
        const novoNome = document.getElementById('editNome').value;
        const novaFuncao = document.getElementById('editFuncao').value;
        const novoStatus = document.getElementById('editStatus').checked;
        
        
        linha.querySelector('td:first-child').textContent = novoNome;
        linha.querySelector('td:nth-child(2)').textContent = novaFuncao;
        
        const statusElement = linha.querySelector('.status');
        statusElement.textContent = novoStatus ? 'Ativo' : 'Inativo';
        statusElement.className = novoStatus ? 'status status-ativo' : 'status status-inativo';
        
        document.getElementById('modalEdicao').remove();
        mostrarNotificacao('Usuário atualizado com sucesso!', 'sucesso');
    });
    
    document.getElementById('cancelarEdicao').addEventListener('click', () => {
        document.getElementById('modalEdicao').remove();
    });
    
    
    document.getElementById('editStatus').addEventListener('change', function() {
        document.querySelector('#modalEdicao span').textContent = this.checked ? 'Ativo' : 'Inativo';
    });
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

// ===== ESTILOS PARA MODAIS =====
function adicionarEstilosModais() {
    const estilos = `
        <style>
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background-color: rgba(0, 0, 0, 0.5);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 2000;
            }
            
            .modal {
                background-color: var(--bg-card);
                border-radius: 12px;
                padding: 25px;
                width: 90%;
                max-width: 500px;
                box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
            }
            
            .modal h3 {
                margin-top: 0;
                margin-bottom: 15px;
            }
            
            .modal-actions {
                display: flex;
                gap: 10px;
                justify-content: flex-end;
                margin-top: 20px;
            }
            
            .botao-acao.secundario {
                background-color: var(--bg-main);
                color: var(--text-primary);
            }
            
            .botao-acao.perigo {
                background-color: var(--accent-red);
                color: white;
            }
            
            .botao-acao.perigo:hover {
                background-color: #c0392b;
            }
            
            .form-group {
                margin-bottom: 15px;
            }
            
            .form-group label {
                display: block;
                margin-bottom: 5px;
                font-weight: 500;
            }
            
            .form-group input,
            .form-group select {
                width: 100%;
                padding: 10px;
                border-radius: 6px;
                border: 1px solid var(--border-color);
                background-color: var(--bg-main);
                color: var(--text-primary);
            }
        </style>
    `;
    
    document.head.insertAdjacentHTML('beforeend', estilos);
}

// Adicionar estilos para modais quando o script carregar
adicionarEstilosModais();

// ===== EXPORTAÇÃO PARA USO EXTERNO =====
window.Configuracoes = {
    salvarPreferencias: salvarPreferencias,
    mostrarNotificacao: mostrarNotificacao
};