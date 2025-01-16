FROM --platform=amd64 python:3.11-alpine as builder

ARG AWS_CLI_VERSION=2.15.0
RUN apk add --no-cache git unzip groff build-base libffi-dev cmake
RUN git clone --depth 1 --branch v2 https://github.com/aws/aws-cli.git

WORKDIR aws-cli
RUN ./configure --with-install-type=portable-exe --with-download-deps
RUN make
RUN make install

# Build the final image
FROM --platform=amd64 node:alpine
COPY --from=builder /usr/local/lib/aws-cli/ /usr/local/lib/aws-cli/
RUN ln -s /usr/local/lib/aws-cli/aws /usr/local/bin/aws

RUN apk --no-cache add curl && \
    addgroup -g 1410 hiring && \
    adduser -D -u 1410 hiring -G hiring
USER hiring

