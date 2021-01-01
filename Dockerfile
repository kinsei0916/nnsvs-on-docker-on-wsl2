FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04

RUN apt-get update && \
  apt-get install -yq --no-install-recommends \
  git \
  libsndfile1 \
  python3 \
  python3-dev \
  python3-pip \
  wget && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

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

RUN pip3 install --upgrade pip
RUN pip3 install setuptools
RUN pip3 install cython jaconv jupyterlab matplotlib
RUN pip3 install torch==1.7.0+cu110 torchvision==0.8.1+cu110 torchaudio===0.7.0 \
  -f https://download.pytorch.org/whl/torch_stable.html

RUN pip3 install scipy fastdtw scikit-learn pysptk tqdm bandmat hydra-core hydra_colorlog librosa pyworld tensorboard

RUN ln -s /usr/bin/python3 /usr/bin/python && \
  ln -s /usr/bin/pip3 /usr/bin/pip

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

EXPOSE 8888

ENTRYPOINT ["jupyter-lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]

CMD ["--notebook-dir=/workspace"]
