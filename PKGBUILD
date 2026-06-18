# Maintainer: theBashPerson <twotimetwicer@proton.me>
pkgname=bash-tools-git
pkgver=2.0.0
pkgrel=1
pkgdesc="laziness button — multitools vibecoded while almost asleep"
arch=('any')
url="https://github.com/theBashPerson/bash-tools"
license=('GPL')
depends=('bash' 'fzf')
optdepends=(
    'wl-clipboard: clipboard support for passgen (wayland)'
    'xclip: clipboard support for passgen (x11)'
    'xsel: clipboard support for passgen (x11 alt)'
    'unrar: rar extraction support for extract'
    'p7zip: 7z extraction support for extract'
)
makedepends=('git')
provides=('bash-tools')
conflicts=('bash-tools')
source=("${pkgname}::git+${url}.git")
md5sums=('SKIP')

package() {

    install -d -m 755 "${pkgdir}/brc"

    # install all executable tools (exclude meta files)
    local _exclude=("PKGBUILD" "install.sh" "README.md" "setup.sh" "toggle.sh" "uptools")
    find "${srcdir}/${pkgname}" -maxdepth 1 -type f ! -name ".*" | while read -r f; do
        basename_f=$(basename "$f")
        skip=0
        for ex in "${_exclude[@]}"; do
            [[ "$basename_f" == "$ex" ]] && skip=1 && break
        done
        [[ "$skip" -eq 0 ]] && install -Dm 755 "$f" "${pkgdir}/brc/${basename_f}"
    done

    # install toggle.sh (sourced, not executed)
    if [[ -f "${srcdir}/${pkgname}/toggle.sh" ]]; then
        install -Dm 644 "${srcdir}/${pkgname}/toggle.sh" "${pkgdir}/brc/toggle.sh"
    fi

    # install dot configs
    for dotfile in .rc .devuse; do
        if [[ -f "${srcdir}/${pkgname}/${dotfile}" ]]; then
            install -Dm 644 "${srcdir}/${pkgname}/${dotfile}" "${pkgdir}/brc/${dotfile}"
        fi
    done
}
