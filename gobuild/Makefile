GOPATH=$(shell pwd)/go
GOSRC=${GOPATH}/src
GODEPS=github.com/opencontainers/runc
GODEPPATHS=$(addprefix ${GOSRC}/,${GODEPS})
MAIN=src/serial_fd_handler.go go/src/github.com/opencontainers/runc/contrib/cmd/recvtty/recvtty.go
BIN=$(basename $(notdir ${MAIN}))

ifdef GOARCH
ARCH=GOARCH=${GOARCH}
else
ARCH=
endif

.PHONY: clean all dep

all: ${BIN}

dep: ${GODEPPATHS}

${GODEPPATHS}:
	mkdir -p ${GOSRC}
	GOPATH=${GOPATH} go get -d $(subst ${GOSRC}/,,$@)

${BIN}: ${GODEPPATHS} $(filter %/$@.go, ${MAIN})
	GOPATH=${GOPATH} ${ARCH} go build $(filter %/$@.go, ${MAIN})

clean:
	rm -f   ${BIN}

distclean:
	rm -rf ${BIN} ${GOPATH}
