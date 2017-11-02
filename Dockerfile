FROM alpine

COPY watchdog /watchdog

# The aws-cli package doesn't actually manage to include the AWS python moduel :\
RUN apk --no-cache add \
      --repository http://dl-3.alpinelinux.org/alpine/edge/testing \
      aws-cli curl jq bash py-pip && \
      pip install awscli --upgrade --user

CMD [ "/watchdog" ]
