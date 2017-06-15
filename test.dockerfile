# A Dockerfile that sets up a full Gym install
FROM quay.io/openai/gym:base

RUN apt-get update \
    && apt-get install -y libav-tools \
    python-numpy \
    python-scipy \
    python-pyglet \
    python-setuptools \
    libpq-dev \
    libjpeg-dev \
    curl \
    cmake \
    swig \
    python-opengl \
    libboost-all-dev \
    libsdl2-dev \
    wget \
    unzip \
    git \
    xpra \
    libav-tools  \
    python3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && easy_install pip

RUN sudo apt-add-repository ppa:libccd-debs -y
RUN sudo apt-add-repository ppa:fcl-debs -y
RUN sudo apt-add-repository ppa:dartsim -y
RUN sudo apt-get update -q
RUN sudo apt-get install libdart6-all-dev -y
RUN sudo apt-get install swig -y
RUN if [[ $TRAVIS_PYTHON_VERSION == 2.7 ]]; then sudo apt-get install swig python-pip python-qt4 python-qt4-dev python-qt4-gl -y; fi
RUN if [[ $TRAVIS_PYTHON_VERSION == 3.4 ]]; then sudo apt-get install python3-pip python3-pyqt4 python3-pyqt4.qtopengl -y; fi


WORKDIR /usr/local/gym/
RUN mkdir -p gym && touch gym/__init__.py
COPY ./gym/version.py ./gym/
COPY ./requirements.txt ./
COPY ./setup.py ./
COPY ./tox.ini ./

RUN pip install tox
# Install the relevant dependencies. Keep printing so Travis knows we're alive.
RUN ["bash", "-c", "( while true; do echo '.'; sleep 60; done ) & tox --notest"]

# Finally, clean cached code (including dot files) and upload our actual code!
RUN mv .tox /tmp/.tox && rm -rf .??* * && mv /tmp/.tox .tox
COPY . /usr/local/gym/

ENTRYPOINT ["/usr/local/gym/bin/docker_entrypoint"]
CMD ["tox"]
