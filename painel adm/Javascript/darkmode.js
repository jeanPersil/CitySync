document.addEventListener('DOMContentLoaded', () => {
    
    // Referencia o corpo do documento para aplicar o tema
    const body = document.body;

    const applyTheme = (theme) => {
        if (theme === 'dark') {
            body.classList.add('dark-mode');
        } else {
            body.classList.remove('dark-mode');
        }
    };

    // Carregar o tema salvo no localStorage ou usar o padrão 'light'
    const savedTheme = localStorage.getItem('theme') || 'light';
    applyTheme(savedTheme);

    const themeSelect = document.getElementById('theme');

    if (themeSelect) {
        themeSelect.value = savedTheme;

        // Ouvir a mudança no select e salvar a nova preferência
        themeSelect.addEventListener('change', (event) => {
            const newTheme = event.target.value;
            localStorage.setItem('theme', newTheme);
            applyTheme(newTheme);
        });
    }
});