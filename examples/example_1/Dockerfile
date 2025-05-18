FROM golang:latest

# Create the app directory
RUN mkdir -p /go_sample

# Set the Current Working Directory inside the container
WORKDIR /go_sample

# Copy the source code into the container
COPY ./go_sample .

# Install make
RUN apt-get update && apt-get install -y \
    git \
    make \
    curl \
    libzmq3-dev

# Install dependencies
RUN go mod tidy

# Build the Go app
RUN go build \
    -ldflags "-s -w -X main.version=$(git describe --tags) -X main.commit=$(git rev-parse HEAD) -X main.date=$(date +%Y-%m-%d)" \
    -trimpath -o "./$(basename $(realpath './'))" \
    "./cmd"

# Command to run the executable
CMD ["./$(basename $(realpath './'))", "--help"]

