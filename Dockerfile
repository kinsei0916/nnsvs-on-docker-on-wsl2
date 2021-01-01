FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

ARG NB_USER="jovyan"
ARG NB_UID="1000"
ARG NB_GID="100"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

RUN apt-get update && \
  apt-get install -yq --no-install-recommends \
  git \
  libsndfile1 \
  libssl-dev \
  python3 \
  python3-dev \
  python3-pip \
  sudo \
  wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

ENV PATH=/home/$NB_USER/.local/bin:$PATH \
  HOME=/home/$NB_USER

RUN sed -i 's/^#force_color_prompt=yes/force_color_prompt=yes/' /etc/skel/.bashrc

RUN echo "auth requisite pam_deny.so" >> /etc/pam.d/su && \
  sed -i.bak -e 's/^%admin/#%admin/' /etc/sudoers && \
  sed -i.bak -e 's/^%sudo/#%sudo/' /etc/sudoers && \
  useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
  chmod g+w /etc/passwd

WORKDIR /tmp

RUN wget --quiet https://github.com/Kitware/CMake/releases/download/v3.19.2/cmake-3.19.2.tar.gz && \
  tar zxf cmake-3.19.2.tar.gz && \
  cd cmake-3.19.2 && \
  ./bootstrap && \
  make && \
  make install && \
  cd .. && \
  rm cmake-3.19.2.tar.gz && \
  rm -rf cmake-3.19.2

USER $NB_UID

RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install setuptools wheel
RUN python3 -m pip install cython jaconv jupyterlab matplotlib
RUN python3 -m pip install torch==1.7.1+cu110 torchvision==0.8.2+cu110 torchaudio===0.7.2 \
  -f https://download.pytorch.org/whl/torch_stable.html

RUN python3 -m pip install scipy fastdtw scikit-learn pysptk tqdm bandmat hydra-core hydra_colorlog librosa pyworld tensorboard

USER root

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN git clone https://github.com/r9y9/hts_engine_API && \
  cd hts_engine_API/src && \
  mkdir -p build && \
  cd build && \
  cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .. && \
  make -j >/dev/null 2>&1 && \
  make install && \
  cd ../../.. &&\
  rm -rf hts_engine_API

RUN git clone https://github.com/r9y9/sinsy && \
  cd sinsy/src && \
  mkdir -p build && \
  cd build && \
  cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .. && \
  make -j >/dev/null 2>&1 && \
  make install && \
  cd ../../.. &&\
  rm -rf sinsy

USER $NB_UID

EXPOSE 8888

ENTRYPOINT ["jupyter-lab"]

CMD ["--ip=0.0.0.0", "--port=8888", "--no-browser", "--notebook-dir=/workspace"]
