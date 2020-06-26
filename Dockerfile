# -*-Dockerfile-*-
FROM golang:alpine
RUN apk add -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
     -X http://dl-cdn.alpinelinux.org/alpine/edge/main \
    alpine-sdk gnupg xz curl-dev sqlite-dev binutils-gold \
    autoconf automake ldc git
RUN go get github.com/tianon/gosu
#git=2.26.2-r0 
RUN mkdir /usr/src && cd /usr/src/ && git clone https://github.com/abraunegg/onedrive.git --single-branch -b v2.4.2 && \
    cd onedrive && git init && git switch -c v2.4.2
	#rm /usr/src/onedrive/.git/HEAD && \
    #git -C /usr/src/onedrive checkout v2.4.2
	#git --work-tree=onedrive --git-dir=onedrive/.git checkout v2.4.2 && \

COPY . /usr/src/onedrive
WORKDIR /usr/src/onedrive
RUN cd /usr/src/onedrive/ && \
    sed -i "s/git describe/git describe --always/g" Makefile.in && \
    sed -i "s/d50ca740-c83f-4d1b-b616-12c519384f0c/7bdb6d8b-a3d9-4f3b-9767-efb4128939aa/g" src/onedrive.d && \
    autoreconf -fiv && \
    ./configure && \
    make clean && \
    make && \
    make install

FROM alpine
ENTRYPOINT ["/entrypoint.sh"]
RUN apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/community \
     -X http://dl-cdn.alpinelinux.org/alpine/edge/main \
    bash libcurl libgcc shadow sqlite-libs ldc-runtime curl && \
    mkdir -p /onedrive/conf /onedrive/data
#COPY contrib/docker/entrypoint.sh /
RUN curl https://raw.githubusercontent.com/abraunegg/onedrive/master/contrib/docker/entrypoint.sh -o /entrypoint.sh && chmod +x /entrypoint.sh
COPY --from=0 /go/bin/gosu /usr/local/bin/onedrive /usr/local/bin/



# https://github.com/abraunegg/onedrive.git
# git@github.com:abraunegg/onedrive.git
