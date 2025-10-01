log "Installing development packages"
packages=(
    jdk8-openjdk openjdk8-doc openjdk8-src
    jdk-openjdk openjdk-doc openjdk-src
    python-pip python-dbus python-opengl python-virtualenv
    dotnet-sdk aspnet-runtime
    maven python-poetry
    lua51 luarocks stylua
    zig choosenim-bin
    github-cli
    docker docker-compose lazydocker
    azure-cli kubectl k9s azure-kubelogin temporal-cli
    distrobox
)
install_pkgs "${packages[@]}"

packages=(
    https://github.com/dlenski/rsa_ct_kip/archive/HEAD.zip
)
install_python_pkgs "${packages[@]}"

packages=(
    httpyac
)
install_npm_pkgs "${packages[@]}"

log "Configuring development environment"
services=(
    keyd
    docker
    power-profiles-daemon
)
enable_services "${services[@]}"

groups=(
    docker
)
enable_groups "${groups[@]}"
