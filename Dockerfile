FROM python:3.7.3

# Install base dependencies for setup and dev runtime
RUN apt -q update
RUN apt -qy install -y \
        libxml2-dev libxslt1-dev \
        python-dev python-virtualenv \
        curl software-properties-common \
        ruby-full rubygems autogen autoconf libtool make


RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt -q update && apt -q install -y nodejs npm

RUN npm install gulp gulp-uglify gulp-concat gulp-sass &>> /dev/build.log
RUN gem install -q sass


ENV ROOT_DIR /opt/pythonbrasil12-site
ENV VENV_BASE   "${ROOTDIR}/venv"
ENV VENV_ROOT   "${VENV_BASE}/pybr12-site"
ENV VENV_BIN    "${VENV_ROOT}/bin/"
ENV VENV_PYTHON "${VENV_BIN}python"
ENV VENV_PIP    "${VENV_BIN}pip"

# Build virtualenv with dependencies
RUN virtualenv $VENV_ROOT
COPY requirements.txt /tmp/requirements.txt
RUN $VENV_PIP install pip --upgrade
RUN $VENV_PIP install --retries 15 --timeout 120 -r /tmp/requirements.txt

# Prepare runtime environment
ENV SITE_DIR ${ROOT_DIR}/site
VOLUME $SITE_DIR

WORKDIR $SITE_DIR
ENTRYPOINT . ${VENV_BIN}activate && make dockerhtml dockerserve
