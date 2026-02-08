# http2tesseract

A Docker image that exposes Tesseract OCR functionality via HTTP API using [http2cli](https://github.com/aom/http2cli).

## Features

- 🐳 **Docker-based deployment** - Easy to deploy and scale
- 🌍 **Multi-language support** - Includes 15+ languages (English, German, French, Spanish, Italian, Portuguese, Russian, Chinese, Japanese, Korean, Arabic, Hindi, and more)
- 🔧 **Multiple output formats** - Plain text, hOCR, TSV, ALTO XML
- 🚀 **HTTP API** - RESTful interface for OCR operations
- 🏗️ **Multi-architecture** - Supports linux/amd64, linux/arm64, darwin/arm64
- 📦 **Lightweight** - Built on Debian Slim for optimal size and compatibility

## Quick Start

### Build the Docker Image

Default build (linux/amd64):
```bash
docker build -t http2tesseract:latest .
```

Build for specific architecture:
```bash
# For linux/amd64
docker build --build-arg OS=linux --build-arg ARCH=amd64 -t http2tesseract:linux-amd64 .

# For linux/arm64
docker build --build-arg OS=linux --build-arg ARCH=arm64 -t http2tesseract:linux-arm64 .

# For darwin/arm64 (macOS Apple Silicon)
docker build --build-arg OS=darwin --build-arg ARCH=arm64 -t http2tesseract:darwin-arm64 .
```

### Run the Container

```bash
docker run -d -p 8080:8080 --name tesseract-api http2tesseract:latest
```

### Test the API

Basic OCR (English):
```bash
curl -X POST -F "image=@sample.png" http://localhost:8080/ocr
```

OCR with different language (German):
```bash
curl -X POST -F "image=@sample.png" "http://localhost:8080/ocr?lang=deu"
```

Get version information:
```bash
curl http://localhost:8080/version
```

## API Endpoints

### POST /ocr
Extract text from an image using Tesseract OCR.

**Parameters:**
- `image` (form-data, required): Image file to process (PNG, JPG, TIFF, etc.)
- `lang` (query, optional): Language code (default: `eng`)
  - Examples: `eng`, `deu`, `fra`, `spa`, `ita`, `por`, `rus`, `chi_sim`, `chi_tra`, `jpn`, `kor`, `ara`, `hin`
- `psm` (query, optional): Page segmentation mode 0-13 (default: `3`)
  - `0` = Orientation and script detection (OSD) only
  - `1` = Automatic page segmentation with OSD
  - `3` = Fully automatic page segmentation, but no OSD (default)
  - `6` = Assume a single uniform block of text
  - `11` = Sparse text. Find as much text as possible in no particular order
- `oem` (query, optional): OCR Engine mode 0-3 (default: `3`)
  - `0` = Legacy engine only
  - `1` = Neural nets LSTM engine only
  - `2` = Legacy + LSTM engines
  - `3` = Default, based on what is available

**Example:**
```bash
curl -X POST -F "image=@document.png" \
  "http://localhost:8080/ocr?lang=fra&psm=6"
```

### POST /ocr/hocr
Extract text from image in hOCR format (HTML with position information).

**Parameters:**
- `image` (form-data, required): Image file to process
- `lang` (query, optional): Language code (default: `eng`)

**Example:**
```bash
curl -X POST -F "image=@document.png" \
  "http://localhost:8080/ocr/hocr?lang=eng" > output.html
```

### POST /ocr/tsv
Extract text with bounding box data in TSV format.

**Parameters:**
- `image` (form-data, required): Image file to process
- `lang` (query, optional): Language code (default: `eng`)

**Example:**
```bash
curl -X POST -F "image=@document.png" \
  "http://localhost:8080/ocr/tsv" > output.tsv
```

### POST /ocr/alto
Extract text in ALTO XML format.

**Parameters:**
- `image` (form-data, required): Image file to process
- `lang` (query, optional): Language code (default: `eng`)

**Example:**
```bash
curl -X POST -F "image=@document.png" \
  "http://localhost:8080/ocr/alto" > output.xml
```

### GET /version
Get Tesseract version information.

**Example:**
```bash
curl http://localhost:8080/version
```

### GET /health
Health check endpoint for monitoring.

**Example:**
```bash
curl http://localhost:8080/health
```

## Supported Languages

The following language packages are pre-installed:

- 🇬🇧 English (`eng`)
- 🇩🇪 German (`deu`)
- 🇫🇷 French (`fra`)
- 🇪🇸 Spanish (`spa`)
- 🇮🇹 Italian (`ita`)
- 🇵🇹 Portuguese (`por`)
- 🇷🇺 Russian (`rus`)
- 🇨🇳 Chinese - Simplified (`chi_sim`)
- 🇹🇼 Chinese - Traditional (`chi_tra`)
- 🇯🇵 Japanese (`jpn`)
- 🇰🇷 Korean (`kor`)
- 🇸🇦 Arabic (`ara`)
- 🇮🇳 Hindi (`hin`)

To add more languages, modify the Dockerfile and add the desired `tesseract-ocr-<lang>` packages.

## Configuration

The http2cli configuration is located at `/etc/http2cli/config.yaml` inside the container.

### Key Configuration Options

- **Port**: Default is `8080` (configurable in `config.yaml`)
- **Max upload size**: `50MB` (configurable in `config.yaml`)
- **Command timeout**: `300s` (5 minutes, configurable in `config.yaml`)
- **Max concurrent commands**: `5` (configurable in `config.yaml`)

### Customizing Configuration

To use a custom configuration:

1. Create your own `config.yaml` file
2. Mount it when running the container:

```bash
docker run -d -p 8080:8080 \
  -v $(pwd)/my-config.yaml:/etc/http2cli/config.yaml \
  http2tesseract:latest
```

## Build Arguments

The Dockerfile supports the following build arguments:

- `OS`: Operating system (default: `linux`)
  - Options: `linux`, `darwin`, `windows`
- `ARCH`: Architecture (default: `amd64`)
  - Options: `amd64`, `arm64`
- `HTTP2CLI_VERSION`: http2cli version to install (default: `v0.0.3`)

**Example:**
```bash
docker build \
  --build-arg OS=linux \
  --build-arg ARCH=arm64 \
  --build-arg HTTP2CLI_VERSION=v0.0.3 \
  -t http2tesseract:arm64 .
```

## Docker Compose

Example `docker-compose.yml`:

```yaml
version: '3.8'

services:
  tesseract-api:
    build:
      context: .
      args:
        OS: linux
        ARCH: amd64
        HTTP2CLI_VERSION: v0.0.3
    image: http2tesseract:latest
    container_name: tesseract-api
    ports:
      - "8080:8080"
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 5s
```

Run with:
```bash
docker-compose up -d
```

## Advanced Usage

### Processing Multiple Images

```bash
for img in *.png; do
  echo "Processing $img..."
  curl -X POST -F "image=@$img" \
    "http://localhost:8080/ocr?lang=eng" > "${img%.png}.txt"
done
```

### Using with Python

```python
import requests

url = 'http://localhost:8080/ocr'
files = {'image': open('document.png', 'rb')}
params = {'lang': 'eng', 'psm': '6'}

response = requests.post(url, files=files, params=params)
print(response.text)
```

### Using with JavaScript/Node.js

```javascript
const FormData = require('form-data');
const fs = require('fs');
const axios = require('axios');

const form = new FormData();
form.append('image', fs.createReadStream('document.png'));

axios.post('http://localhost:8080/ocr?lang=eng&psm=6', form, {
  headers: form.getHeaders()
})
.then(response => console.log(response.data))
.catch(error => console.error(error));
```

## Troubleshooting

### Container won't start
- Check logs: `docker logs tesseract-api`
- Verify the configuration file is valid YAML
- Ensure the port 8080 is not already in use

### OCR returns empty results
- Verify the image is in a supported format (PNG, JPG, TIFF)
- Try different PSM values (especially `6` or `11` for different layouts)
- Ensure the correct language is specified

### Performance issues
- Increase `max_concurrent_commands` in config.yaml
- Consider deploying multiple containers behind a load balancer
- Optimize images before processing (resize, convert to grayscale)

## Security Considerations

- The default configuration has no API key authentication. To enable:
  1. Set `security.api_key` in `config.yaml`
  2. Send requests with `X-API-Key` header
- The container runs as a non-root user (`http2cli`) for security
- Only the tesseract command is allowed to execute

## License

This project is provided as-is. Check the licenses of the included components:
- [http2cli](https://github.com/aom/http2cli) - MIT License
- [Tesseract OCR](https://github.com/tesseract-ocr/tesseract) - Apache License 2.0

## Contributing

Issues and pull requests are welcome!

## Resources

- [http2cli Documentation](https://github.com/aom/http2cli)
- [Tesseract OCR Documentation](https://tesseract-ocr.github.io/)
- [Tesseract Language Data](https://github.com/tesseract-ocr/tessdata)
