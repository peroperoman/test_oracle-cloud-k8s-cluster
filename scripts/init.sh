#!/bin/bash
# vars
libraries="
yum-utils
device-mapper-persistent-data
lvm2
docker-ce
kubelet kubeadm --disableexcludes=kubernetes
"

disable_svcs="
firewalld
postfix
tuned
vdo
"

service_ctl() {
    while read disable_svc ;do
        if [ -n "$disable_svc" ] ; then
            sudo systemctl stop $disable_svc
            sudo systemctl disable $disable_svc
        fi
    done <<<$disable_svcs

    sudo setenforce 0
    sudo sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

    sudo swapoff -a
    sudo sed -i '/swap/s/^/###/' /etc/fstab
}

install_library() {
    sudo yum update -y

    sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF >/dev/null
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kube*
EOF

    sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    
    while read library
    do
        if [ -n "$library" ] ; then
            sudo yum install -y $library
        fi
    done <<<$libraries
}

setup_docker() {
    sudo mkdir -m 644 /etc/docker

    sudo tee /etc/docker/daemon.json <<EOF >/dev/null
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable docker && systemctl start docker
    sudo echo '1' > /proc/sys/net/bridge/bridge-nf-call-iptables
    sudo rm -f /etc/containerd/config.toml
    sudo systemctl restart containerd
}

setup_k8s(){
    sudo systemctl enable kubelet && systemctl start kubelet
}

setup_locale() {
    sudo timedatectl set-timezone "Asia/Tokyo"
    sudo localectl set-locale LANG=ja_JP.UTF-8
    sudo localectl set-keymap LANG=jp
    sudo localectl set-x11-keymap LANG=jp
}

service_ctl
install_library
setup_docker
setup_k8s
setup_locale
exit 0
