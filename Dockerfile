FROM ubuntu:24.04
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Install prerequisites
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    bzip2 \
    ca-certificates \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Set Miniconda environment variables
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

# Install Miniconda silently
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p $CONDA_DIR && \
    rm /tmp/miniconda.sh && \
    $CONDA_DIR/bin/conda clean -afy

# Set shell to bash for conda compatibility
SHELL ["/bin/bash", "-c"]

# Clone your GitHub repository
RUN git clone https://github.com/mdziurzynski/ont_fungal_barcoding_pipeline.git /pipeline

# Create and activate conda environment from environment.yml
WORKDIR /pipeline
RUN conda env create -f ont_fungal_barcoding_env.yml && conda clean -afy

# Activate environment
# Set default environment name
ENV CONDA_DEFAULT_ENV=ont_fungal_barcoding_env
ENV PATH=$CONDA_DIR/envs/$CONDA_DEFAULT_ENV/bin:$PATH

# Activate conda env in bash sessions
RUN echo "conda activate $CONDA_DEFAULT_ENV" >> ~/.bashrc

# Ensure funbaront.sh is executable
RUN chmod +x /pipeline/funbaront.sh

# Set ENTRYPOINT to run funbaront.sh by default
ENTRYPOINT ["funbaront.sh"]

