FROM registry.access.redhat.com/ubi9/nodejs-18 as builder
COPY package*.json $HOME
USER root
RUN npm install
COPY . $HOME
USER 1001
FROM registry.access.redhat.com/ubi9/nodejs-18-minimal
COPY --from=builder $HOME $HOME
EXPOSE 8080
CMD /usr/libexec/s2i/run
