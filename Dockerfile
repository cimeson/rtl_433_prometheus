# Use the official Golang image to create a build artifact.
# This is based on Debian and sets the GOPATH to /go.
# https://hub.docker.com/_/golang
FROM docker.io/golang:1.20 as gobuilder

# Create and change to the app directory.
WORKDIR /app

# Retrieve application dependencies.
# This allows the container build to reuse cached dependencies.
COPY go.* ./
RUN go mod download

# Copy local code to the container image.
COPY . ./

# Build the binary.
RUN CGO_ENABLED=0 GOOS=linux GOARM=6 go build -mod=readonly -a -v rtl_433_prometheus.go

FROM alpine:latest

# RUN apt-get update && apt-get install -y librtlsdr0
RUN apk add rtl_433 --no-cache

WORKDIR /
COPY --from=gobuilder /app/rtl_433_prometheus /

EXPOSE 9550
ENTRYPOINT ["/rtl_433_prometheus"]
CMD ["--subprocess", "rtl_433 -F json -M newmodel"]
