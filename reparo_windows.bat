@echo off
echo Iniciando reparo do Windows...
echo.

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
echo Executando DISM...
DISM /Online /Cleanup-Image /RestoreHealth

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
echo Executando SFC...
sfc /scannow

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
echo.
echo Processo finalizado.
pause