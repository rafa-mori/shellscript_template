# Template Seguro e Modular para Scripts Bash

> **Licença:** GNU AGPL-3.0-ou-posterior  
> **Copyright (C) 2025 Rafael Mori**  
> **Inspirado por helper-scripts de Adrelanos ([link](https://github.com/Whonix/helper-scripts))**

Este repositório oferece um template robusto para escrever scripts Bash seguros, modulares e fáceis de manter. Inclui boas práticas para tratamento de erros, logging, saída colorida e configuração segura do ambiente. A estrutura foi pensada para evitar armadilhas comuns, como execução acidental como root, colisão de nomes de funções e uso incorreto de sourcing.

## Principais Características

- **Segurança em Primeiro Lugar**: Impede execução como root ou via sudo e aplica opções seguras do shell (`errexit`, `nounset`, `pipefail`).
- **Design Modular**: Funções com prefixo e exportação seletiva para evitar poluir o namespace global.
- **Logging & Cores**: Logger integrado com suporte a cores, detecção de fundo do terminal e contraste alto para melhor experiência.
- **Exemplo de Wrapper**: Demonstra como criar um ponto de entrada seguro, roteando argumentos e validando o ambiente.
- **Utilitários Extensíveis**: Inclui utilitários para perguntas ao usuário, entrada de segredos e gerenciamento do buffer do terminal.

## Exemplo de Uso

```bash
# Uso do wrapper seguro
./examples/secure_wrapper.sh 2 arg1 arg2
```

Isso irá direcionar a execução de forma segura para o script e função apropriados, garantindo todas as validações e logging.

## Como Usar

1. **Copie os scripts template** para seu projeto.
2. **Substitua todos os prefixos `myname`** pelo nome do seu script.
3. **Personalize o wrapper** conforme sua necessidade.
4. **Aproveite o logger e utilitários de cor** para saída consistente e tratamento de erros.

## Por que usar este template?

- Evita erros comuns em shell script.
- Facilita manutenção e extensão dos scripts.
- Fornece uma base profissional para automação, DevOps e tarefas de CI/CD.

---

### Compartilhe com a Comunidade

Sinta-se à vontade para usar este template como base para seus próprios scripts e compartilhar melhorias ou casos de uso com a comunidade via Gist, DEV.to ou outras plataformas!
