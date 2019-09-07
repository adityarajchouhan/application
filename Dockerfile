FROM alpine:3.8

EXPOSE 3000

LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.docker.cmd="docker run -d -p 3000:3000 --name alpine_timeoff"

RUN apk add --no-cache \
    make \
    nodejs npm \
    python
    
RUN adduser --system app --home /app
WORKDIR /app/timeoff-management
COPY . .
RUN mkdir /db && chown app -R /app /db
USER app
WORKDIR /app/timeoff-management

RUN npm install

CMD npm start
