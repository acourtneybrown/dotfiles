# shellcheck shell=bash
ensure_docker() {
  mkdir -p ~/.docker
  touch ~/.docker/config.json
  if [ -z "$(jq -r .auths.\"octofactory.githubapp.com\" ~/.docker/config.json)" ]; then
    docker login octofactory.githubapp.com
  fi
}

alias src="cd ~/enterprise2;"
alias sshc="src; ./chroot-ssh.sh"
alias r="src; ./chroot-stop.sh; ./chroot-reset.sh; ./chroot-cluster-stop.sh; ./chroot-cluster-reset.sh test/cluster.conf; ./chroot-cluster-reset.sh test/cluster-ha.conf; ./chroot-cluster-reset.sh test/cluster-dr.conf;"
alias b="src; r; ./chroot-build.sh && ./chroot-start.sh && ./chroot-configure.sh"
alias bc="src; r; ./chroot-build.sh && ./chroot-cluster-start.sh test/cluster.conf"
alias bf="ensure_docker; (export FETCH_DOCKER_IMAGES=1; b)"
alias bcf="ensure_docker; (export FETCH_DOCKER_IMAGES=1; bc)"
alias bfm="(export ENABLE_MINIO=1; bf)"
alias bcfm="(export ENABLE_MINIO=1; bcf)"
