# Use the official Go image as a build stage
FROM golang:1.22 AS builder

# Set the working directory
WORKDIR /app

# Copy the Go modules manifests
COPY go.mod go.sum ./

# Download the dependencies
RUN go mod download

# Copy the source code
COPY cmd/ ./cmd
COPY internal/ ./internal

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s" -o /bin ./cmd/api

# Start a new stage from scratch
FROM alpine:latest

# Copy the binary from the builder stage
COPY --from=builder /bin/api /usr/local/bin/api

# Command to run the binary
CMD ["api"]