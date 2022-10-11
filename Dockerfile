##################################################
# Stage: builder
##################################################

FROM elixir:1.14.0-alpine as builder

ENV MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex \
    APP_HOME=/opt/app \
    ERL_AFLAGS="-kernel shell_history enabled"

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk --no-cache --update-cache --available upgrade
RUN apk add --no-cache --update-cache bash ca-certificates libstdc++ build-base git inotify-tools nodejs npm yarn
RUN mix do local.hex --force, local.rebar --force
RUN update-ca-certificates --fresh

SHELL ["/bin/bash", "-c"]

COPY etc /etc/
RUN find /etc/bashrc.d/ -name "*.sh" -exec chmod -v +x {} \;
COPY .bashrc /root/

COPY opt/scripts/ /opt/scripts
ADD https://github.com/vishnubob/wait-for-it/raw/master/wait-for-it.sh /opt/scripts/
RUN find /opt/scripts/ -name "*.sh" -exec chmod -v +x {} \;
ENV PATH=/opt/scripts/:$PATH

ENTRYPOINT ["entrypoint.sh"]
CMD ["mix", "phx.server"]
EXPOSE 4000

##################################################
# Stage: runtime
##################################################

FROM alpine:3.16.2 as runtime

ENV APP_HOME=/opt/app \
    ERL_AFLAGS="-kernel shell_history enabled"

RUN mkdir $APP_HOME
WORKDIR $APP_HOME

RUN apk --no-cache --update-cache --available upgrade \
    && apk add --no-cache --update-cache bash ca-certificates libstdc++ openssl ncurses-libs \
    && update-ca-certificates --fresh

SHELL ["/bin/bash", "-c"]

COPY --from=builder /etc/bashrc.d /etc/bashrc.d
COPY --from=builder /etc/bash.bashrc /etc/bash.bashrc
COPY --from=builder /opt/scripts /opt/scripts
COPY .bashrc /root/

RUN chown -R nobody:nobody /opt
ENV PATH=/opt/scripts/:$PATH

ENTRYPOINT ["entrypoint.sh"]
CMD ["bash", "-c", "$RELEASE_NAME start"]
EXPOSE 4000
