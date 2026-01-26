log "Installing development packages"
packages=(
    jdk8-openjdk openjdk8-doc openjdk8-src
    jdk-openjdk openjdk-doc openjdk-src maven
    python-pip python-dbus python-opengl python-virtualenv python-poetry
    dotnet-sdk aspnet-runtime
    rust cargo
    lua51 luarocks stylua
    zig
    github-cli opencode-bin
    docker docker-buildx docker-compose lazydocker
    azure-cli kubectl k9s azure-kubelogin temporal-cli
    distrobox
)
install_pkgs "${packages[@]}"

packages=(
    https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip
)
install_python_pkgs "${packages[@]}"

log "Configuring development environment"
services=(
    docker
)
enable_services "${services[@]}"

groups=(
    docker
)
enable_groups "${groups[@]}"
