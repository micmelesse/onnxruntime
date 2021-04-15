cd orttraining/tools/docker
docker build --network=host --file Dockerfile.amd --tag rocm/tensorflow:rocm3.3-tf2.1-dev-wezhan .