#!/usr/bin/env bash
set -ex

c=$(buildah from gentoo/stage3-amd64)

buildcmd() {
  buildah run --network host "${c}" -- "$@"
}

env

buildcmd emerge-webrsync
buildcmd mkdir -p /etc/portage/package.use /repo
buildcmd bash -c 'echo "dev-vcs/git -perl" > /etc/portage/package.use/git'
buildcmd emerge --quiet-build -q dev-vcs/git app-portage/repoman
# shellcheck disable=SC2016
buildcmd bash -c 'source /etc/portage/make.conf && rm "${DISTDIR}"/*'
buildcmd bash -c 'echo FEATURES="-ipc-sandbox -network-sandbox" >> /etc/portage/make.conf'

buildah config --entrypoint "/usr/bin/repoman" "${c}"
buildah config --workingdir "/repo" "${c}"

buildah commit --squash --rm "${c}" "ghcr.io/daugustin/repoman:latest"

buildah push "ghcr.io/daugustin/repoman:latest"