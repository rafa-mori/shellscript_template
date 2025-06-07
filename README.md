# Secure and Modular Bash Script Template

> **License:** MIT  
> **Copyright (C) 2025 Rafael Mori**  
> **Inspired by Adrelanos' [helper-scripts](https://github.com/Whonix/helper-scripts)**

Este repositório fornece um template robusto para escrever scripts Bash seguros, modulares e fáceis de manter — agora com foco em automação cloud-native, incluindo ambientes Kubernetes em Azure!

---

## Sumário

- [Destaque: Cloud-Native com Azure/Kubernetes](#destaque-cloud-native-com-azurekubernetes)
- [Principais Características](#principais-características)
- [Exemplo Clássico de Uso](#exemplo-clássico-de-uso)
- [Por que usar este template?](#por-que-usar-este-template)
- [Comparativo Prático](docs/COMPARATIVO.md)
- [Casos de Uso Detalhados](#casos-de-uso-detalhados)
- [Como contribuir](#como-contribuir)
- [Licença](#licença)

## Destaque: Cloud-Native com Azure/Kubernetes

Este template agora inclui exemplos e configurações otimizadas para ambientes cloud-native, especialmente aqueles baseados em Azure Kubernetes Service (AKS). Aproveite os benefícios de escalabilidade, resiliência e gerenciamento simplificado que o Kubernetes oferece.

## Principais Características

- **Segurança em Primeiro Lugar**: Previne execução como root ou via sudo, e impõe opções de shell seguras (`errexit`, `nounset`, `pipefail`).
- **Design Modular**: Funções são prefixadas e exportadas seletivamente para evitar poluição do namespace global.
- **Registro e Cores**: Logger embutido com suporte a cores, detecção de fundo e saída em alto contraste para melhor UX.
- **Exemplo de Wrapper**: Demonstra como criar um ponto de entrada seguro para seus scripts, com roteamento de argumentos e validação de ambiente.
- **Utilitários Extensíveis**: Inclui utilitários para prompts de usuário, entrada de segredos e gerenciamento de buffer de terminal.

## Exemplo Clássico de Uso

```bash
# Uso do wrapper seguro
./examples/secure_wrapper.sh 2 arg1 arg2
```

Isso roteará a execução de forma segura para o script e função apropriados, garantindo que todas as verificações de ambiente e registro estejam em vigor.

## Por que usar este template?

- Evita erros comuns de script shell.
- Facilita a manutenção e extensão dos seus scripts.
- Fornece uma base profissional para automação, DevOps e tarefas de CI/CD.

## Casos de Uso Detalhados

Para uma compreensão mais profunda de como este template pode ser utilizado, consulte os casos de uso detalhados incluídos na documentação. Eles fornecem exemplos práticos e explicações sobre como tirar o máximo proveito das funcionalidades oferecidas.

## Como contribuir

Contribuições são bem-vindas! Sinta-se à vontade para enviar pull requests ou relatar problemas. Juntos, podemos melhorar ainda mais este template e ajudar a comunidade a criar scripts Bash seguros e eficientes.

## Licença

Este projeto está licenciado sob a Licença MIT - veja o arquivo [LICENSE](LICENSE) para detalhes.

---

### Compartilhe com a Comunidade

Sinta-se à vontade para usar este template como base para seus próprios scripts e compartilhar melhorias ou casos de uso com a comunidade via Gist, DEV.to ou outras plataformas!
