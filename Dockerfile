FROM registry.access.redhat.com/ubi9/nodejs-20 as builder
COPY package*.json $HOME
USER root
RUN npm install
COPY . $HOME
RUN chown -R 1001:0 "$HOME/.npm" && \
    chmod -R 775 "/$HOME/.npm"
USER 1001
FROM registry.access.redhat.com/ubi9/nodejs-20-minimal
COPY --from=builder $HOME $HOME
EXPOSE 8080
CMD /usr/libexec/s2i/run
