# NNSVS on Docker on WSL 2

## Installation

First, you have to install WSL 2 (Windows Subsystem for Linux 2) and set up CUDA Toolkit and Docker on it. See [CUDA on WSL User Guide](https://docs.nvidia.com/cuda/wsl-user-guide/).

## Running NNSVS

Use the Docker Compose script to build NNSVS image from Dockerfile.

```shell
docker-compose build
```

Download kiritan_singing.zip from [研究者向け東北きりたん歌唱データベース　ログインページ](https://zunko.jp/kiridev/login.php) and unzip to `./kiritan_singing/`.

Start up JupyterLab by running:

```shell
docker-compose up
```

Open `http://localhost:8888/` to access the notebook.

## References

- [CUDA on WSL User Guide](https://docs.nvidia.com/cuda/wsl-user-guide/)
- [待ってました CUDA on WSL 2](https://qiita.com/ksasaki/items/ee864abd74f95fea1efa)
- [r9y9/nnsvs: Neural network-based singing voice synthesis library for research](https://github.com/r9y9/nnsvs)
- [Google Colaboratory で NNSVS で遊ぶ mini-HOWTO](https://qiita.com/taroushirani/items/ec16cb9a6b3b691f5e74)
- [oatsu-gh/setup-nnsvs-on-wsl: WSL 上で NNSVS が動く環境を作るためのシェルスクリプトとか](https://github.com/oatsu-gh/setup-nnsvs-on-wsl)
