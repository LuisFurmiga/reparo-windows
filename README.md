# Explicação geral

Este script foi criado para executar comandos comuns de diagnóstico e reparo do Windows de forma automatizada.

Ele primeiro confirma se está sendo executado como administrador.  
Depois executa o **DISM**, em seguida o **SFC** e, por fim, verifica os discos `C:` e `D:` com o **CHKDSK**.

Caso o DISM ou o SFC retornem erro, o script interrompe a execução.  
Já no caso do CHKDSK, o script apenas informa se houve erro, mas continua até o final.

---

# 1. Configuração inicial do terminal

```bat
@echo off
echo Iniciando reparo do Windows...
echo.
```

## `@echo off`

Essa linha desativa a exibição dos comandos no terminal.

Sem ela, cada comando executado apareceria na tela antes do resultado.  
Com ela, o usuário vê apenas as mensagens geradas pelo próprio script.

O símbolo `@` impede que a própria linha `echo off` seja exibida.

## `echo Iniciando reparo do Windows...`

Mostra uma mensagem inicial para informar que o processo começou.

## `echo.`

Exibe uma linha em branco no terminal.  
Essa linha é usada apenas para deixar a saída mais organizada e legível.

---

# 2. Verificação de administrador

```bat
REM Verificando se o script está sendo executado com privilégios de administrador
net session >nul 2>&1
set "ADMIN_ERROR=%errorlevel%"
if not "%ADMIN_ERROR%"=="0" (
    echo Este script precisa ser executado como administrador.
    echo Clique com o botao direito no arquivo .bat e escolha "Executar como administrador".
    echo.
    pause
    exit /b 1
)
```

## Objetivo deste bloco

Esse bloco verifica se o arquivo `.bat` foi aberto com permissão de administrador.

Isso é necessário porque os comandos usados depois, como `DISM`, `sfc` e `chkdsk`, precisam de privilégios elevados para funcionar corretamente.

## `REM`

`REM` cria um comentário no arquivo Batch.

Comentários não são executados.  
Eles servem apenas para explicar o que o código está fazendo.

## `net session >nul 2>&1`

O comando `net session` exige permissão administrativa.  
Por isso, ele é usado aqui como teste.

Se o script estiver sendo executado como administrador, o comando retorna sucesso.  
Se não estiver, ele retorna erro.

A parte:

```bat
>nul 2>&1
```

oculta a saída do comando.

Isso impede que mensagens técnicas apareçam para o usuário.

## `set "ADMIN_ERROR=%errorlevel%"`

Armazena o código de saída do comando anterior dentro da variável `ADMIN_ERROR`.

`%errorlevel%` guarda o resultado do último comando executado:

- `0` geralmente significa sucesso.
- Diferente de `0` geralmente significa erro.

## `if not "%ADMIN_ERROR%"=="0" (...)`

Verifica se `ADMIN_ERROR` é diferente de `0`.

Se for diferente, significa que o script não foi executado como administrador.

Nesse caso, o script:

1. Mostra uma mensagem de aviso.
2. Orienta o usuário a executar o `.bat` como administrador.
3. Pausa a tela.
4. Encerra com código de erro `1`.

## `pause`

Aguarda o usuário pressionar uma tecla.

Isso evita que a janela feche rapidamente antes que a mensagem seja lida.

## `exit /b 1`

Encerra o script atual e retorna o código `1`, indicando falha.

O parâmetro `/b` faz com que o comando saia apenas do script Batch, sem necessariamente fechar toda a janela do Prompt de Comando.

---

# 3. Execução do DISM

```bat
echo Executando DISM...
DISM /Online /Cleanup-Image /RestoreHealth
```

## Objetivo deste bloco

Executar o DISM para verificar e reparar a imagem do Windows.

A imagem do Windows é uma base interna usada pelo sistema para manter seus componentes e arquivos essenciais.

## `echo Executando DISM...`

Mostra uma mensagem informando que o DISM será iniciado.

## `DISM /Online /Cleanup-Image /RestoreHealth`

Executa a ferramenta DISM.

### Significado dos parâmetros

## `/Online`

Indica que a ação será feita no Windows em execução no momento.

Ou seja, o comando atua sobre o próprio sistema operacional aberto.

## `/Cleanup-Image`

Informa que a operação será feita sobre a imagem do Windows.

## `/RestoreHealth`

Verifica se há corrupção na imagem do sistema e tenta reparar os problemas encontrados.

---

# 4. Verificação do resultado do DISM

```bat
REM Armazenando o código de erro do DISM para verificação posterior
set "DISM_ERROR=%errorlevel%"

echo.
REM Verificando se o DISM foi bem-sucedido antes de prosseguir
if not "%DISM_ERROR%"=="0" (
    echo Ocorreu um erro durante a execucao do DISM.
    echo Codigo de erro: %DISM_ERROR%
    echo Verifique as mensagens acima para detalhes.
    echo.
    pause
    exit /b %DISM_ERROR%
)
```

## Objetivo deste bloco

Verificar se o DISM terminou corretamente antes de continuar para o SFC.

## `set "DISM_ERROR=%errorlevel%"`

Salva o código de saída do DISM na variável `DISM_ERROR`.

Se o DISM terminou com sucesso, o valor esperado é `0`.

## `if not "%DISM_ERROR%"=="0" (...)`

Verifica se o valor retornado pelo DISM é diferente de `0`.

Se for diferente, significa que houve erro.

Nesse caso, o script:

1. Mostra uma mensagem de erro.
2. Exibe o código de erro retornado pelo DISM.
3. Recomenda verificar as mensagens anteriores.
4. Pausa a tela.
5. Encerra o script retornando o mesmo código de erro do DISM.

## `exit /b %DISM_ERROR%`

Encerra o script usando o código de erro retornado pelo DISM.

Isso é útil porque preserva o motivo original da falha.

---

# 5. Execução do SFC

```bat
echo Executando SFC...
sfc /scannow
```

## Objetivo deste bloco

Executar o SFC para verificar e reparar arquivos protegidos do sistema Windows.

## `echo Executando SFC...`

Mostra uma mensagem informando que o SFC será iniciado.

## `sfc /scannow`

Executa o **System File Checker**.

O parâmetro `/scannow` faz com que o Windows verifique imediatamente todos os arquivos protegidos do sistema.

Se forem encontrados arquivos corrompidos, ausentes ou modificados, o SFC tenta restaurá-los.

---

# 6. Verificação do resultado do SFC

```bat
set "SFC_ERROR=%errorlevel%"

echo.
REM Verificando se o SFC foi bem-sucedido antes de prosseguir
if not "%SFC_ERROR%"=="0" (
    echo O SFC terminou com codigo de erro: %SFC_ERROR%
    echo Verifique as mensagens acima para detalhes.
    echo.
    pause
    exit /b %SFC_ERROR%
)
```

## Objetivo deste bloco

Verificar se o SFC terminou com sucesso antes de continuar para o CHKDSK.

## `set "SFC_ERROR=%errorlevel%"`

Salva o código de saída do SFC na variável `SFC_ERROR`.

## `if not "%SFC_ERROR%"=="0" (...)`

Verifica se o código retornado pelo SFC é diferente de `0`.

Se for diferente, o script entende que o SFC encontrou algum erro ou não conseguiu concluir corretamente.

Nesse caso, o script:

1. Mostra o código de erro.
2. Pede para o usuário verificar as mensagens exibidas acima.
3. Pausa.
4. Encerra usando o mesmo código de erro do SFC.

---

# 7. Execução do CHKDSK na unidade C:

```bat
echo.
REM Verificando se há uma partição C: antes de executar CHKDSK
if exist C:\ (
    echo Executando CHKDSK no C:...
    chkdsk /R C:
    if errorlevel 1 (
        echo O CHKDSK no C: terminou com erro.
        echo Verifique as mensagens acima para detalhes.
        echo.
    )
) else (
    echo Particao C: nao encontrada. Pulando CHKDSK no C:.
)
```

## Objetivo deste bloco

Verificar se a unidade `C:` existe e, caso exista, executar o CHKDSK nela.

## `if exist C:\ (...)`

Verifica se o caminho `C:\` existe.

Se existir, executa o bloco principal.  
Se não existir, executa o bloco `else`.

## `chkdsk /R C:`

Executa o CHKDSK na unidade `C:`.

### Significado dos parâmetros

## `chkdsk`

Ferramenta do Windows usada para verificar problemas no disco e no sistema de arquivos.

## `/R`

Localiza setores defeituosos e tenta recuperar informações legíveis.

O `/R` também inclui a função do `/F`, ou seja, também tenta corrigir erros no sistema de arquivos.

## `C:`

Indica que a unidade analisada será a unidade `C:`.

## `if errorlevel 1 (...)`

Verifica se o CHKDSK retornou código de erro igual ou maior que `1`.

Em Batch, a expressão:

```bat
if errorlevel 1
```

significa:

> Se o código de saída do último comando for maior ou igual a 1.

Como o último comando foi o `chkdsk`, essa verificação identifica se ele terminou com erro.

## Diferença em relação à versão anterior

Nesta versão, o script passou a verificar o retorno do CHKDSK.

Antes, o CHKDSK era executado, mas o script não avaliava se ele terminou com erro.

Agora, se houver erro, o script exibe:

```text
O CHKDSK no C: terminou com erro.
Verifique as mensagens acima para detalhes.
```

## Observação importante

Na unidade `C:`, é comum o CHKDSK não conseguir executar imediatamente porque o Windows está usando essa unidade.

Nesse caso, ele pode perguntar se o usuário deseja agendar a verificação para a próxima reinicialização.

---

# 8. Execução do CHKDSK na unidade D:

```bat
echo.
REM Verificando se há uma partição D: antes de executar CHKDSK
if exist D:\ (
    echo Executando CHKDSK no D:...
    chkdsk /R D:
    if errorlevel 1 (
        echo O CHKDSK no D: terminou com erro.
        echo Verifique as mensagens acima para detalhes.
        echo.
    )
) else (
    echo Particao D: nao encontrada. Pulando CHKDSK no D:.
)
```

## Objetivo deste bloco

Este bloco faz a mesma verificação feita para a unidade `C:`, mas agora para a unidade `D:`.

Como a lógica é a mesma, a explicação não precisa ser repetida em detalhes.

O script:

1. Verifica se `D:\` existe.
2. Se existir, executa:

```bat
chkdsk /R D:
```

3. Verifica se o CHKDSK retornou erro com:

```bat
if errorlevel 1
```

4. Se houver erro, mostra uma mensagem.
5. Se `D:\` não existir, informa que a partição não foi encontrada.

## Diferença prática entre C: e D:

A unidade `C:` geralmente é a unidade principal do Windows.  
A unidade `D:` pode ser uma partição secundária, outro disco, uma unidade de dados ou pode simplesmente não existir.

Por isso, a verificação com:

```bat
if exist D:\
```

é importante.

---

# 9. Finalização do script

```bat
echo.
echo Processo finalizado.
pause
```

## `echo.`

Exibe uma linha em branco.

## `echo Processo finalizado.`

Mostra uma mensagem informando que o script chegou ao fim.

## `pause`

Mantém a janela aberta até que o usuário pressione uma tecla.

Isso permite ler as mensagens finais e possíveis avisos exibidos durante a execução.

---

# Fluxo resumido do script

```text
Início
  ↓
Oculta comandos com @echo off
  ↓
Mostra mensagem inicial
  ↓
Verifica permissão de administrador
  ↓
Se não for administrador:
    mostra aviso
    pausa
    encerra
  ↓
Executa DISM
  ↓
Se DISM retornar erro:
    mostra código de erro
    pausa
    encerra
  ↓
Executa SFC
  ↓
Se SFC retornar erro:
    mostra código de erro
    pausa
    encerra
  ↓
Verifica se C: existe
  ↓
Se existir:
    executa CHKDSK /R C:
    verifica se houve erro
  ↓
Se C: não existir:
    informa que pulou a unidade
  ↓
Verifica se D: existe
  ↓
Se existir:
    executa CHKDSK /R D:
    verifica se houve erro
  ↓
Se D: não existir:
    informa que pulou a unidade
  ↓
Mostra "Processo finalizado"
  ↓
Pausa final
```

---

# Explicação das principais ferramentas usadas

## DISM

O DISM, chamado no script por:

```bat
DISM /Online /Cleanup-Image /RestoreHealth
```

é usado para verificar e reparar a imagem do Windows.

Ele costuma ser executado antes do SFC porque o SFC pode depender dessa imagem para restaurar arquivos do sistema.

---

## SFC

O SFC, chamado no script por:

```bat
sfc /scannow
```

verifica arquivos protegidos do Windows.

Ele procura arquivos corrompidos, alterados ou ausentes e tenta restaurá-los.

---

## CHKDSK

O CHKDSK, chamado no script por:

```bat
chkdsk /R C:
chkdsk /R D:
```

verifica problemas no disco e no sistema de arquivos.

O parâmetro `/R` é mais completo que uma verificação simples, pois tenta localizar setores defeituosos e recuperar dados legíveis.

---

# Sobre o uso de `errorlevel`

O script usa `%errorlevel%` e `if errorlevel 1` para verificar se comandos terminaram com sucesso ou erro.

## `%errorlevel%`

É uma variável especial que guarda o código de saída do último comando executado.

Exemplo:

```bat
set "DISM_ERROR=%errorlevel%"
```

Nesse caso, o valor retornado pelo DISM é salvo na variável `DISM_ERROR`.

## `if errorlevel 1`

Verifica se o último comando retornou código maior ou igual a `1`.

Exemplo:

```bat
if errorlevel 1 (
    echo O CHKDSK no C: terminou com erro.
)
```

Essa forma é útil logo depois de um comando, principalmente dentro de blocos `if (...)`, porque evita problemas comuns de expansão de variáveis em arquivos Batch.

---

# Observações importantes

## 1. O script precisa ser executado como administrador

Sem privilégios de administrador, comandos de reparo do Windows podem falhar.

Por isso, o script valida essa condição logo no início.

---

## 2. DISM e SFC interrompem o script em caso de erro

Se o DISM ou o SFC retornarem erro, o script para.

Isso evita continuar a execução como se o sistema tivesse sido reparado corretamente.

---

## 3. CHKDSK não interrompe o script

Nesta versão, o CHKDSK tem verificação de erro, mas não encerra o script caso falhe.

Ele apenas mostra uma mensagem de aviso.

Isso faz sentido porque pode ser possível verificar `D:` mesmo que tenha ocorrido algum problema ou pendência em `C:`.

---

## 4. CHKDSK no C: pode precisar de reinicialização

Como a unidade `C:` geralmente está em uso pelo Windows, o CHKDSK pode solicitar agendamento para a próxima reinicialização.

Nesse caso, o usuário precisa responder à pergunta exibida no terminal.

---

## 5. O parâmetro `/R` pode demorar

O comando:

```bat
chkdsk /R
```

pode levar bastante tempo, especialmente em discos grandes, lentos ou com defeitos físicos.

---

# Resumo final

Este script automatiza uma rotina de manutenção do Windows.

Ele verifica se possui permissão administrativa, executa reparos na imagem do sistema com DISM, verifica arquivos protegidos com SFC e analisa as unidades `C:` e `D:` com CHKDSK.
