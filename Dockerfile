FROM golang:1.17 AS builder

# LD_FLAGS is passed as argument from Makefile. It will be empty, if no argument passed
ARG LD_FLAGS
ARG TARGETPLATFORM
ARG TAGS

ADD . /skbn
WORKDIR /skbn

RUN export GOOS=$(echo ${TARGETPLATFORM} | cut -d / -f1) && \
    export GOARCH=$(echo ${TARGETPLATFORM} | cut -d / -f2)

RUN go env

RUN CGO_ENABLED=0 go build -o /output/skbn -tags "${TAGS}" -ldflags="${LD_FLAGS}" -v ./cmd/skbn.go

# Packaging stage
FROM scratch

COPY --from=builder /output/skbn /
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

USER 10001

ENTRYPOINT ["/skbn"] 
