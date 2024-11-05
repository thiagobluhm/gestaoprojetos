# Use uma imagem base oficial do Debian
FROM debian:bullseye-slim

# Instale dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    curl \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    wget \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instale o pyenv
RUN curl https://pyenv.run | bash

# Defina variáveis de ambiente para o pyenv
ENV HOME /root
ENV PYENV_ROOT $HOME/.pyenv
ENV PATH $PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH

# Instale a versão desejada do Python e defina-a como padrão
RUN pyenv install 3.11.8 \
    && pyenv global 3.11.8

# Recrie o ambiente para usar a nova versão do Python
RUN eval "$(pyenv init --path)" && \
    eval "$(pyenv init -)" && \
    eval "$(pyenv virtualenv-init -)" && \
    pyenv rehash

# Instale o pip e virtualenv
RUN pip install --upgrade pip && pip install virtualenv

# Defina o diretório de trabalho
WORKDIR /opt/ml

# Copie os arquivos do modelo para o contêiner
COPY . /opt/ml/model

# Copie e instale as dependências
COPY requirements.txt /opt/ml/model/requirements.txt
RUN pip install -r /opt/ml/model/requirements.txt

# Instale MLflow (se não estiver no requirements.txt)
RUN pip install mlflow

# Defina o entrypoint para servir o modelo registrado no MLflow
# Exponha a porta usada pelo MLflow
EXPOSE 5000
EXPOSE 5001

# Defina o entrypoint para servir o modelo registrado no MLflow
ENTRYPOINT ["mlflow"]

# Ajuste o CMD para iniciar o servidor MLflow com o backend store correto
#CMD ["server", "--backend-store-uri", "/opt/ml/model/mlruns", "--default-artifact-root", "/opt/ml/model/mlruns", "-h", "0.0.0.0", "-p", "5000"]

# Defina o entrypoint para servir o modelo registrado no MLflow
#ENTRYPOINT ["mlflow"]

# Ajuste o CMD para usar as variáveis de ambiente
#CMD ["server", "--backend-store-uri", "/opt/ml/model/mlruns", "-p", "5001"]
CMD ["server", "--backend-store-uri", "file:///C:/Users/ThiagoBluhm/OneDrive%20-%20Grupo%20Portfolio/Documentos/_CLIENTES_PORTFOLIO/__techIA/GP/mlruns/543121518920333127/9fc72e278ebb4a0c945f2f9dd626e064/artifacts", "--default-artifact-root", "/opt/ml/model/mlruns/543121518920333127/9fc72e278ebb4a0c945f2f9dd626e064/artifacts", "-h", "0.0.0.0", "-p", "5000"]
# Ajuste o CMD para iniciar o servidor MLflow com o modelo
#CMD ["models", "serve", "-m", "runs:/9fc72e278ebb4a0c945f2f9dd626e064/modelo", "-p", "5000"]