#!/usr/bin/env bash
set -ex

c=$(buildah from gentoo/stage3)

buildcmd() {
  buildah run --network host "${c}" -- "$@"
}

env | sort

buildcmd emerge-webrsync
buildcmd mkdir -p /etc/portage/package.use /repo
buildcmd bash -c 'echo "dev-vcs/git -perl" > /etc/portage/package.use/git'
buildcmd emerge --quiet-build -NDqu1 --exclude gcc @world
buildcmd emerge --quiet-build -q dev-vcs/git app-portage/repoman
# shellcheck disable=SC2016
buildcmd bash -c 'source /etc/portage/make.conf && rm "${DISTDIR}"/*'
buildcmd echo 'FEATURES="-ipc-sandbox -network-sandbox"' \| tee -a /etc/portage/make.conf

buildah config --entrypoint "/usr/bin/repoman" "${c}"
buildah config --workingdir "/repo" "${c}"

buildah commit --format=docker --squash --rm "${c}" "ghcr.io/${GITHUB_REPOSITORY_OWNER}/repoman:latest"

buildah push "ghcr.io/${GITHUB_REPOSITORY_OWNER}/repoman:latest"
