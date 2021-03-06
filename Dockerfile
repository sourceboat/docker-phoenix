##################################################
# Stage: builder
##################################################

FROM elixir:1.11.3-alpine as builder

ENV HOME=/opt/app \
    MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex

RUN mkdir $HOME
WORKDIR $HOME

RUN apk -U upgrade \
    && apk add --no-cache bash build-base git inotify-tools nodejs npm yarn \
    && mix do local.hex --force, local.rebar --force

SHELL ["/bin/bash", "-c"]

COPY etc/profile.d/ /etc/profile.d
RUN find /etc/profile.d/ -name "*.sh" -exec chmod -v +x {} \;

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

FROM alpine:3.13.2 as runtime

ENV HOME=/opt/app
RUN mkdir $HOME
WORKDIR $HOME

RUN apk -U upgrade \
    && apk add --no-cache bash openssl ncurses-libs

SHELL ["/bin/bash", "-c"]

COPY --from=builder /etc/profile.d /etc/profile.d
COPY --from=builder /opt/scripts /opt/scripts

RUN chown -R nobody:nobody /opt

ENTRYPOINT ["entrypoint.sh"]
CMD ["bash", "-c", "$RELEASE_NAME start"]
EXPOSE 4000
