##################################################
# Stage: base
##################################################

FROM elixir:1.10.3-alpine as base

RUN mkdir /opt/app
WORKDIR /opt/app

RUN apk -U upgrade \
    && apk add --no-cache bash

SHELL ["/bin/bash", "-c"]

COPY root/ /root
RUN find /root/ -name "*.sh" -exec chmod -v +x {} \;

ENTRYPOINT ["/root/entrypoint.sh"]
CMD /root/run-prod.sh
EXPOSE 4000

##################################################
# Stage: default
##################################################

FROM base

RUN apk add --no-cache nodejs npm yarn

CMD /root/run-dev.sh
