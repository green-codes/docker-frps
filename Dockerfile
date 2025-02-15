#

# ===== build stage =====

FROM alpine:latest AS building

# Install required tools (curl and jq for parsing JSON)
RUN apk add --no-cache curl jq

# install frp w/chained one-liner
RUN \
  FRP_VER=$(curl -s https://api.github.com/repos/fatedier/frp/releases/latest | jq -r '.tag_name' | sed 's/v//'); \
  case "$(apk --print-arch)" in \
    "x86_64") export FRP_ARCH="amd64" ;; \
    "aarch64") export FRP_ARCH="arm64" ;; \
  esac; \
  echo Building FRP ${FRP_VER} ${FRP_ARCH}; \
  mkdir -p /frp \
  && curl -L https://github.com/fatedier/frp/releases/download/v${FRP_VER}/frp_${FRP_VER}_linux_${FRP_ARCH}.tar.gz | tar -xz -C /frp --strip-components=1

# ===== main image =====

FROM alpine:latest

#RUN apk add --no-cache curl
COPY --from=building /frp/frps /usr/bin/frps

CMD ["/usr/bin/frps", "-c", "/etc/frp/frps.toml"]
