# shellcheck shell=bash
function ensure_docker() {
  host="$1"
  mkdir -p ~/.docker
  touch ~/.docker/config.json
  if [ -z "$(jq -r .auths."${host}" ~/.docker/config.json)" ]; then
    docker login "${host}"
  fi
}

function ensure_dockers() {
  ensure_docker "octofactory.githubapp.com"
  ensure_docker "docker.pkg.github.com"
  ensure_docker "containers.pkg.github.com"
}

alias src="cd ~/enterprise2;"
alias sshc="(src; ./chroot-ssh.sh)"
alias r="(src; ./chroot-stop.sh; ./chroot-reset.sh; ./chroot-cluster-stop.sh; ./chroot-cluster-reset.sh test/cluster.conf; ./chroot-cluster-reset.sh test/cluster-ha.conf; ./chroot-cluster-reset.sh test/cluster-dr.conf;)"
alias b="(src; r; ./chroot-build.sh && ./chroot-start.sh && ./chroot-configure.sh)"
alias bc="(src; r; ./chroot-build.sh && ./chroot-cluster-start.sh test/cluster.conf)"
alias bf="ensure_dockers; (export FETCH_DOCKER_IMAGES=1; b)"
alias bcf="ensure_dockers; (export FETCH_DOCKER_IMAGES=1; bc)"
alias bfm="(export ENABLE_MINIO=1; bf)"
alias bcfm="(export ENABLE_MINIO=1; bcf)"
alias stop="(src; ./chroot-stop.sh)"
alias start="(src; ./chroot-start.sh)"
alias urp="sudo update-reverse-proxy"
