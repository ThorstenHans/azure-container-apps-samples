FROM golang:1.16-alpine as build

WORKDIR /app

COPY go.mod ./
COPY go.sum ./
RUN go mod download

COPY *.go ./

RUN go build -o /api

FROM alpine:latest

WORKDIR /app

COPY --from=build /api .
EXPOSE 8080

CMD [ "./api" ]
