# Usar a imagem base do Python 3.11 no Alpine Linux 3.19
FROM python:3.11-alpine3.19
LABEL mantainer="peagahvieira2003@gmail.com"

# Não escrever arquivos .pyc no disco
ENV PYTHONDONTWRITEBYTECODE=1

# Fazer o Python exibir saídas imediatamente (sem buffering)
ENV PYTHONUNBUFFERED=1

# Instalar dependências do sistema necessárias
RUN apk add --no-cache \
    gcc \
    libc-dev \
    libffi-dev \
    musl-dev \
    postgresql-dev \
    npm

# Copiar o diretório do projeto local e a pasta "scripts" para dentro do container
COPY . /djangoapp
COPY scripts /scripts

# Definir o diretório de trabalho dentro do container
WORKDIR /djangoapp

# Expor a porta 8000 para permitir conexões externas ao container
EXPOSE 8000

# Instalar dependências do NPM e compilar a aplicação
RUN npm install && \
    npm run build

# Criar e ativar um ambiente virtual, atualizar o pip e instalar as dependências do projeto
RUN python -m venv /venv && \
    /venv/bin/pip install --upgrade pip && \
    /venv/bin/pip install -r /djangoapp/requirements.txt

# Adicionar um usuário sem privilégios e ajustar permissões
RUN adduser --disabled-password --no-create-home duser && \
    chown -R duser:duser /venv && \
    chown -R duser:duser /djangoapp && \
    chmod -R +x /scripts

# Adicionar as pastas scripts e venv/bin ao PATH do container
ENV PATH="/scripts:/venv/bin:$PATH"

# Mudar para o usuário não privilegiado
USER duser

# Executar o script de comandos
CMD ["commands.sh"]
