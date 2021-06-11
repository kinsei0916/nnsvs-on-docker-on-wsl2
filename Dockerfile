FROM nvidia/cuda:11.3.1-cudnn8-devel-ubuntu18.04

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
  unzip \
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

RUN wget --quiet https://github.com/Kitware/CMake/releases/download/v3.20.3/cmake-3.20.3.tar.gz && \
  tar zxf cmake-3.20.3.tar.gz && \
  cd cmake-3.20.3 && \
  ./bootstrap && \
  make && \
  make install && \
  cd .. && \
  rm cmake-3.20.3.tar.gz && \
  rm -rf cmake-3.20.3

USER $NB_UID

RUN python3 -m pip install --no-cache-dir --upgrade pip
RUN python3 -m pip install --no-cache-dir setuptools wheel
RUN python3 -m pip install --no-cache-dir cython jaconv jupyterlab matplotlib
RUN python3 -m pip install --no-cache-dir torch==1.8.1+cu111 torchvision==0.9.1+cu111 torchaudio==0.8.1 \
  -f https://download.pytorch.org/whl/torch_stable.html

RUN python3 -m pip install --no-cache-dir scipy fastdtw scikit-learn pysptk tqdm bandmat hydra-core hydra_colorlog librosa pyworld tensorboard

USER root

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN wget https://github.com/r9y9/hts_engine_API/archive/3df26131a513d3074542335c4286f0478c1470d2.zip -O hts_engine_API.zip && \
  unzip hts_engine_API.zip && \
  mv hts_engine_API-3df26131a513d3074542335c4286f0478c1470d2 hts_engine_API && \
  mkdir -p hts_engine_API/src/build && \
  cd hts_engine_API/src/build && \
  cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .. && \
  make -j && \
  make install && \
  cd ../../.. && \
  wget https://github.com/r9y9/sinsy/archive/ce0b0d6065daf3a23ebf6611bba8077291ff0b70.zip -O sinsy.zip && \
  unzip sinsy.zip && \
  mv sinsy-ce0b0d6065daf3a23ebf6611bba8077291ff0b70 sinsy && \
  mkdir -p sinsy/src/build && \
  cd sinsy/src/build && \
  cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON .. && \
  make -j && \
  make install && \
  cd ../../.. && \
  rm -rf hts_engine_API.zip hts_engine_API sinsy.zip sinsy

USER $NB_UID

EXPOSE 8888

ENTRYPOINT ["jupyter-lab"]

CMD ["--ip=0.0.0.0", "--port=8888", "--no-browser", "--notebook-dir=/workspace"]
