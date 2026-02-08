# Multi-architecture Dockerfile for Tesseract OCR with http2cli
# Supports configurable OS and ARCH via build arguments

ARG OS=linux
ARG ARCH=amd64
ARG HTTP2CLI_VERSION=v0.0.3

# Use Debian Slim for comprehensive tesseract language support
FROM debian:bookworm-slim

# Re-declare build arguments after FROM
ARG OS
ARG ARCH
ARG HTTP2CLI_VERSION

# Set labels
LABEL maintainer="http2tesseract"
LABEL description="Tesseract OCR exposed via http2cli HTTP API"
LABEL version="${HTTP2CLI_VERSION}"

# Install tesseract with comprehensive language support
# Install curl for downloading http2cli binary
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        tesseract-ocr \
        tesseract-ocr-eng \
        tesseract-ocr-deu \
        tesseract-ocr-fra \
        tesseract-ocr-spa \
        tesseract-ocr-ita \
        tesseract-ocr-por \
        tesseract-ocr-rus \
        tesseract-ocr-chi-sim \
        tesseract-ocr-chi-tra \
        tesseract-ocr-jpn \
        tesseract-ocr-kor \
        tesseract-ocr-ara \
        tesseract-ocr-hin \
        curl \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Download and install http2cli binary from GitHub releases
RUN BINARY_NAME="http2cli-${OS}-${ARCH}" && \
    if [ "${OS}" = "windows" ]; then BINARY_NAME="${BINARY_NAME}.exe"; fi && \
    echo "Downloading http2cli ${HTTP2CLI_VERSION} for ${OS}/${ARCH}..." && \
    curl -L -o /usr/local/bin/http2cli \
        "https://github.com/aom/http2cli/releases/download/${HTTP2CLI_VERSION}/${BINARY_NAME}" && \
    chmod +x /usr/local/bin/http2cli

# Create directory for configuration
RUN mkdir -p /etc/http2cli

# Copy configuration file
COPY config.yaml /etc/http2cli/config.yaml

# Expose the default http2cli port
EXPOSE 8080

# Create a non-root user for running the service
RUN useradd -r -u 1000 -m -d /home/http2cli http2cli && \
    chown -R http2cli:http2cli /etc/http2cli
USER http2cli

# Set working directory
WORKDIR /home/http2cli

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Set entrypoint to start http2cli server
ENTRYPOINT ["http2cli", "--config", "/etc/http2cli/config.yaml"]
