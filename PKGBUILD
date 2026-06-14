# Maintainer: theBashPerson <twotimetwicer@proton.me>
pkgname=bash-tools-git
pkgver=1.0.0
pkgrel=1
pkgdesc="multitools vibecoded while almost sleep"
arch=('any')
url="https://github.com/theBashPerson/bash-tools"
license=('GPL')
depends=('bash' 'fzf')
makedepends=('git')
provides=('bash-tools')
conflicts=('bash-tools')
source=("${pkgname}::git+${url}.git")
md5sums=('SKIP')

package() {
    
    install -d -m 755 "${pkgdir}/brc"

    
    find "${srcdir}/${pkgname}" -maxdepth 1 -type f ! -name "PKGBUILD" ! -name "install.sh" ! -name "README.md" ! -name ".*" -exec install -Dm 755 {} "${pkgdir}/brc/" \;
    
    
    if [ -f "${srcdir}/${pkgname}/.rc" ]; then
        install -m 644 "${srcdir}/${pkgname}/.rc" "${pkgdir}/brc/.rc"
    fi
    if [ -f "${srcdir}/${pkgname}/.devuse" ]; then
        install -m 644 "${srcdir}/${pkgname}/.devuse" "${pkgdir}/brc/.devuse"
    fi
}
