##################################################
# Stage: builder
##################################################

FROM elixir:1.10.3-alpine as builder

ENV HOME=/opt/app \
    MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex

RUN mkdir $HOME
WORKDIR $HOME

RUN apk -U upgrade \
    && apk add --no-cache bash build-base nodejs npm yarn \
    && mix do local.hex --force, local.rebar --force

SHELL ["/bin/bash", "-c"]

COPY root/ /root
COPY opt/scripts/ /opt/scripts
RUN find /opt/scripts/ -name "*.sh" -exec chmod -v +x {} \;

ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
CMD /opt/scripts/run-dev.sh
EXPOSE 4000

##################################################
# Stage: runtime
##################################################

FROM alpine:3.13.2 as runtime

ENV HOME=/opt/app
RUN mkdir $HOME
WORKDIR $HOME

RUN apk -U upgrade \
    && apk add --no-cache bash openssl ncurses-libs

SHELL ["/bin/bash", "-c"]

COPY --from=builder /opt/scripts /opt/scripts

RUN chown -R nobody:nobody /opt

ENTRYPOINT ["/opt/scripts/entrypoint.sh"]
CMD /opt/scripts/run-prod.sh
EXPOSE 4000
