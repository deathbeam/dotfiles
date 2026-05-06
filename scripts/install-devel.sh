log "Installing development packages"
packages=(
    jdk8-openjdk openjdk8-doc openjdk8-src
    jdk-openjdk openjdk-doc openjdk-src maven
    python-pip python-dbus python-opengl python-virtualenv python-poetry
    dotnet-sdk aspnet-runtime
    rust cargo
    lua51 luarocks stylua
    zig
    jq yq jnv # json/yaml processors
    quicktype # json converter to types
    github-cli
    docker docker-buildx docker-compose bubblewrap lazydocker # container and isolation
    azure-cli kubectl k9s azure-kubelogin temporal-cli
)
install_pkgs "${packages[@]}"

packages=(
    '@mariozechner/pi-coding-agent'
)

install_npm_pkgs "${packages[@]}"

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
