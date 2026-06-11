# ステージ１：ビルドステージ
FROM golang:1.21 AS builder
WORKDIR /app
COPY main.go .
COPY go.mod .
RUN go build -o main .

# ステージ２：実行ステージ
FROM ubuntu:22.04
WORKDIR /app
COPY --from=builder /app/main .
CMD ["./main"]
