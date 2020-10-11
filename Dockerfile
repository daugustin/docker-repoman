FROM gentoo/stage3-amd64

RUN emerge-webrsync && \
    mkdir -p /etc/portage/package.use && \
    echo "dev-vcs/git -perl" > /etc/portage/package.use/git && \
    emerge --quiet-build -q dev-vcs/git app-portage/repoman && \
    source /etc/portage/make.conf && \
    rm "${DISTDIR}"/* && \
    echo 'FEATURES="-ipc-sandbox -network-sandbox"' >> /etc/portage/make.conf

RUN mkdir /repo
WORKDIR /repo

ENTRYPOINT ["/usr/bin/repoman"]
