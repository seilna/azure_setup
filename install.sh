# cuda install
wget https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1_amd64
sudo dpkg -i cuda-repo-ubuntu1604-10-0-local-10.0.130-410.48_1.0-1_amd64
sudo apt-key add /var/cuda-repo-10-0-local-10.0.130-410.48/7fa2af80.pub
sudo dpkg -i libcudnn7_7.6.3.30-1+cuda10.0_amd64.deb
sudo apt-get update 
sudo apt-get install -y cuda
sudo apt install -y nvidia-cuda-toolkit
# docker install
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update && sudo apt-get install -y docker-ce
echo 'docker install done.'

# INSTALL NVIDIA_DOCKER
echo 'nvidia-docker install start'
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd
sudo docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
echo 'nvidia-docker install done'

# disk mount
echo "n
p
1


w" | sudo fdisk /dev/sdc
sudo mkfs -t ext4 /dev/sdc1
sudo mkdir /datadrive
sudo chown seilna:seilna /datadrive
sudo mount /dev/sdc1 /datadrive
sudo chown seilna:seilna /etc/fstab
UUID=$(sudo -i blkid | tail -1 | cut -d \" -f2)  >> /etc/fstab
echo "UUID=$UUID   /datadrive   ext4   defaults,nofail   1   2" >> /etc/fstab

# docker image path change
sudo systemctl stop docker
sudo mkdir -p /datadrive/docker_dir && sudo chown seilna:seilna /datadrive/docker_dir
sudo chown seilna:seilna /lib/systemd/system/docker.service
sed -i -e 's/-H fd:\/\//-H fd:\/\/ -g \/datadrive\/docker_dir/g' /lib/systemd/system/docker.service
sudo rm -rf /var/lib/docker
sudo systemctl daemon-reload
sudo systemctl start docker
