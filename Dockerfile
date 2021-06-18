##################################################
# Stage: builder
##################################################

FROM elixir:1.12.1-alpine as builder

ENV MIX_HOME=/opt/mix \
    HEX_HOME=/opt/hex

RUN mkdir /opt/app
WORKDIR /opt/app

RUN apk --no-cache --update-cache --available upgrade \
    && apk add --no-cache --update-cache bash ca-certificates libstdc++ libgcc build-base git inotify-tools nodejs npm yarn \
    && mix do local.hex --force, local.rebar --force \
    && update-ca-certificates --fresh

SHELL ["/bin/bash", "-c"]

COPY etc/profile.d/ /etc/profile.d
RUN find /etc/profile.d/ -name "*.sh" -exec chmod -v +x {} \;
COPY .bashrc /root/.bashrc

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

FROM alpine:3.14.0 as runtime

ENV HOME=/opt/app
RUN mkdir $HOME
WORKDIR $HOME

RUN apk --no-cache --update-cache --available upgrade \
    && apk add --no-cache --update-cache bash ca-certificates libstdc++ libgcc openssl ncurses-libs \
    && update-ca-certificates --fresh

SHELL ["/bin/bash", "-c"]

COPY --from=builder /etc/profile.d /etc/profile.d
COPY --from=builder /opt/scripts /opt/scripts
COPY .bashrc .

RUN chown -R nobody:nobody /opt
ENV PATH=/opt/scripts/:$PATH

ENTRYPOINT ["entrypoint.sh"]
CMD ["bash", "-c", "$RELEASE_NAME start"]
EXPOSE 4000
