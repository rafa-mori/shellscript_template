# Melhores Práticas para Robustez e Resiliência em Shell Scripting

Shell scripting é uma arte cheia de sutilezas – e são justamente esses detalhes que podem transformar um script comum em uma ferramenta verdadeiramente robusta e confiável. Ao longo dos anos, aprendi (e continuo aprendendo) diversas técnicas para aprimorar meus scripts, e hoje compartilho algumas dessas melhores práticas.

### 1. `printf` vs. `echo`
Embora o `echo` seja prático e simples de usar, ele pode se comportar de maneira diferente entre shells. Em contrapartida, o `printf` é um builtin robusto e consistente, que formata e imprime exatamente o que você especifica.  
**Dica:** Use `printf` sempre que precisar de um controle preciso da saída. Lembre-se de incluir `\n` para as quebras de linha.

```bash
# Exemplo:
printf "Processo iniciado...\n"
```

### 2. Retorno de Valores em Funções
Para “retornar” valores em funções, utilize `echo` e capture a saída, evitando que mensagens de log se misturem.  
**Atenção:** Direcione os loggings para o stderr para preservar a saída padrão que será capturada.

### 3. Cuidado com `exit` em Scripts Importados
Ao usar `source` (ou `.`), evite comandos `exit` fora dos blocos de erro críticos, pois isso encerra a execução do script importador.  
**Boas práticas:**
- Use `return` com códigos de erro dentro de funções.
- Reserve o `exit` somente para situações de falha imperativa.

### 4. Exportação de Funções com `export -f`
Quando usar funções em subprocessos (como com GNU/Parallel), certifique-se de exportá-las com `export -f`. Caso contrário, elas podem não estar disponíveis e causar erros difíceis de depurar.

```bash
minha_funcao() {
  echo "Função exportada corretamente"
}
export -f minha_funcao
```

### 5. Definir Valores Padrão para Variáveis
Utilize a sintaxe `${VAR:-valor}` para garantir que, mesmo que a variável não esteja definida, o script tenha um fallback seguro.

```bash
# Exemplo:
diretorio_destino="${DEST_DIR:-/usr/local/bin}"
```

### 6. Convenções na Nomeação de Variáveis
- **Variáveis locais**: Use sempre letras minúsculas, preferencialmente iniciadas com um underscore (`_minha_variavel`) para evitar conflitos com variáveis de ambiente.
- **Variáveis públicas ou exportadas**: Adote letras maiúsculas e, se possível, o snake_case. Variáveis definidas apenas para a execução atual podem ter um prefixo ou sufixo que identifique seu caráter temporário e podem ser marcadas como `readonly` antes de exportá-las.

### 7. Detecção Confiável do Shell Corrente
Detectar corretamente o shell de execução nem sempre é simples. Uma função robusta para essa finalidade é:

```bash
get_current_shell() {
  local shell_proc
  shell_proc=$(cat /proc/$$/comm)
  case "${0##*/}" in
    ${shell_proc}*)
      local shebang
      shebang=$(head -1 "$0")
      printf '%s\n' "${shebang##*/}"
      ;;
    *)
      printf '%s\n' "$shell_proc"
      ;;
  esac
}
```

Essa abordagem evita armadilhas comuns relacionadas ao uso de `$0` ou `$BASH_SOURCE`, garantindo a identificação correta – essencial inclusive para o uso de `sudo -v` quando necessário.

### 8. Verificação Versátil de Comandos e Pacotes
Nenhum único comando garante verificar se algo existe no sistema, pois um pacote pode fornecer vários componentes. Combine abordagens:

- **`command -v` ou `which`**: Verifica se o comando está no PATH.
- **`type -a`**: Lista todas as ocorrências do comando.
- **`compgen -c`**: Pode listar comandos disponíveis.
- Para distribuições Debian, use o `dpkg-query` para confirmar a instalação do pacote.

```bash
check_command() {
  local cmd="$1"
  if command -v "$cmd" > /dev/null 2>&1 || type -a "$cmd" > /dev/null 2>&1 || compgen -c "$cmd" > /dev/null 2>&1; then
      return 0
  else
      printf "Erro: o comando '%s' não foi encontrado.\n" "$cmd" >&2
      return 1
  fi
}
```

### 9. Linha em Branco no Final do Arquivo
Não subestime: sempre termine seus scripts com uma linha vazia. A ausência dessa quebra pode causar erros de execução em determinados interpretadores.

---

## Conclusão

Adotar essas práticas faz a diferença entre scripts que “apenas funcionam” e ferramentas que são resilientes, portáveis e fáceis de manter. Seja você um iniciante ou um veterano que vive revisitando o RTFM, esses detalhes podem transformar seus scripts, permitindo evitar armadilhas e surpresas inesperadas.

Compartilhar esses conhecimentos é uma forma de elevar o padrão da comunidade e ajudar outros desenvolvedores a produzir código mais robusto e confiável. Essa publicação pode ser o pontapé inicial para muitos melhorarem suas práticas no desenvolvimento em shell. 

Espero de coração estar ajudando e colaborando para que seus scripts e lógicas em shell alcancem - com pequenos detalhes - seus grandes propósitos!

