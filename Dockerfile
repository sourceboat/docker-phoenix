##################################################
# Stage: builder
##################################################

FROM elixir:1.10.3-alpine as builder

ENV HOME=/opt/app
RUN mkdir $HOME
WORKDIR $HOME

RUN apk -U upgrade \
    && apk add --no-cache bash build-base nodejs npm yarn \
    mix do local.hex --force, local.rebar --force

SHELL ["/bin/bash", "-c"]

COPY root/ /root
RUN find /root/ -name "*.sh" -exec chmod -v +x {} \;

ENTRYPOINT ["/root/entrypoint.sh"]
CMD /root/run-prod.sh
EXPOSE 4000

##################################################
# Stage: release
##################################################

FROM alpine:3.13.2 as release

ENV HOME=/opt/app
RUN mkdir $HOME
WORKDIR $HOME

RUN apk -U upgrade \
    && apk add --no-cache openssl ncurses-libs

RUN chown nobody:nobody $HOME
USER nobody:nobody

COPY --from=builder /root /root

ENTRYPOINT ["/root/entrypoint.sh"]
CMD /root/run-prod.sh
EXPOSE 4000
