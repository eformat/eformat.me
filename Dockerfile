FROM registry.access.redhat.com/ubi9/nodejs-16 as builder
COPY package*.json $HOME
USER root
RUN npm install
COPY . $HOME
USER 1001
FROM registry.access.redhat.com/ubi9/nodejs-16-minimal
COPY --from=builder $HOME $HOME
EXPOSE 8080
CMD /usr/libexec/s2i/run
