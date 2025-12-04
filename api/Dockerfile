FROM golang:1.22-alpine AS builder

WORKDIR /app
COPY go.mod ./
RUN go mod download

COPY . .
RUN go build -o api .

FROM alpine:3.20
WORKDIR /app
COPY --from=builder /app/api /app/api

EXPOSE 8080
CMD ["/app/api"]