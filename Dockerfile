ARG R_VERSION=4.4.3
FROM rocker/r-ver:${R_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    build-essential \
    ca-certificates \
    cmake \
    gfortran \
    git \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgdal-dev \
    libgeos-dev \
    libgit2-dev \
    libharfbuzz-dev \
    libjpeg-dev \
    libpng-dev \
    libproj-dev \
    libssl-dev \
    libtiff5-dev \
    libudunits2-dev \
    libxml2-dev \
    pandoc \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /open-prom

ARG COMMON_DEFINITIONS_REPO="https://github.com/IAMconsortium/common-definitions.git"
ARG COMMON_DEFINITIONS_REF="d877b5f56386317b66214bdb8cc694befda5596c"
ARG NOMENCLATURE_IAMC_VERSION="0.31.0"
ENV IAMC_COMMON_DEFINITIONS=/opt/iamc/common-definitions

RUN python3 -m pip install --no-cache-dir --break-system-packages "nomenclature-iamc==${NOMENCLATURE_IAMC_VERSION}" \
    && mkdir -p /opt/iamc \
    && git init ${IAMC_COMMON_DEFINITIONS} \
    && git -C ${IAMC_COMMON_DEFINITIONS} remote add origin ${COMMON_DEFINITIONS_REPO} \
    && git -C ${IAMC_COMMON_DEFINITIONS} fetch --depth 1 origin ${COMMON_DEFINITIONS_REF} \
    && git -C ${IAMC_COMMON_DEFINITIONS} checkout --detach FETCH_HEAD

COPY docker/install-r-packages.R docker/install-r-packages.R

ARG R_UNIVERSE_REPOS="https://pik-piam.r-universe.dev,https://e3modelling.r-universe.dev"
ARG GITHUB_R_PACKAGES="https://github.com/e3modelling/mrprom.git,https://github.com/e3modelling/postprom.git"
ENV R_UNIVERSE_REPOS=${R_UNIVERSE_REPOS}
ENV GITHUB_R_PACKAGES=${GITHUB_R_PACKAGES}

RUN Rscript docker/install-r-packages.R

COPY . .

ENV OPENPROM_CONFIG=config.container.json
ENV PATH="/opt/gams:${PATH}"

ENTRYPOINT ["Rscript", "start.R"]
CMD ["task_id=2"]
