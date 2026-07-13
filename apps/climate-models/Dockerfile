FROM python:3.12-slim-bookworm

ARG CLIMATE_ASSESSMENT_REF=v0.1.6

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    CLIMATE_ASSESSMENT_DIR=/opt/climate-assessment \
    CLIMATE_JOBS_DIR=/data/jobs

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
       build-essential \
       gfortran \
       git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt ./requirements.txt
RUN git clone --depth 1 --branch "${CLIMATE_ASSESSMENT_REF}" \
      https://github.com/iiasa/climate-assessment.git /opt/climate-assessment \
    && python -m pip install --upgrade "pip>=22" \
    && python -m pip install --no-cache-dir \
       /opt/climate-assessment -r requirements.txt

COPY app.py climate_runner.py ./

RUN useradd --create-home --uid 10001 climate-app \
    && mkdir -p /data/jobs /opt/climate-assets \
    && chown -R climate-app:climate-app /data /app

USER climate-app
EXPOSE 8501

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8501/_stcore/health', timeout=3)"

CMD ["streamlit", "run", "app.py", "--server.address=0.0.0.0", "--server.port=8501", "--server.headless=true", "--server.fileWatcherType=none"]
