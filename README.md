# eformat.me

A minimal home page

```bash
cat <<EOF > index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <link rel="stylesheet" type="text/css" href="/node_modules/patternfly/dist/css/patternfly.css">
  <link rel="stylesheet" type="text/css" href="/node_modules/patternfly/dist/css/patternfly-additions.css">
</head>
<body>
  <div class="container">
    <!-- Just enjoy various PatternFly components -->
    <div class="alert alert-success">
      <span class="pficon pficon-ok"></span>
      <strong>eformat</strong> This is really working out <a href="#" class="alert-link">great</a>.
    </div>
    <img style="height:auto;" alt="" width="260" height="260" class="avatar avatar-user width-full border color-bg-default" src="https://avatars.githubusercontent.com/u/712608?v=4">    
  </div>
  <script src="/node_modules/jquery/dist/jquery.js"></script>
  <script src="/node_modules/bootstrap/dist/js/bootstrap.js"></script>
</body>
</html>
EOF
```

Minimal NodeJS express server

```bash
cat <<EOF > server.js
const port = 8080
const express = require('express')
const path = require('path')
const app = express()
app.use(
  express.static(__dirname)
);
app.get('*/', function(req, res) {
  console.log('OK')
  res.sendFile(__dirname + '/index.html');
});
app.listen(port)
EOF
```

Build locally

```bash
npm init -f
npm i express patternfly --save
```

Dont put these in the image

```bash
cat <<EOF > .dockerignore
node_modules
npm-debug.log
EOF
```

Create the Dockerfile

```bash
cat <<'EOF' > Dockerfile
FROM registry.access.redhat.com/ubi8/nodejs-16 as builder
COPY package*.json $HOME
USER root
RUN npm install
COPY . $HOME
USER 1001
FROM registry.access.redhat.com/ubi8/nodejs-16-minimal
COPY --from=builder $HOME $HOME
EXPOSE 8080
CMD /usr/libexec/s2i/run
EOF
```

Create container image and push to quay

```bash
podman build -t quay.io/eformat/eformat-me .
podman push quay.io/eformat/eformat-me
```

Deploy Application to OpenShift

```bash
oc new-project eformat
oc new-app quay.io/eformat/eformat-me
oc expose svc eformat-me --hostname eformat.me --port 8080
oc patch route/eformat-me --type=json -p '[{"op":"add", "path":"/spec/tls", "value":{"termination":"passthrough","insecureEdgeTerminationPolicy":"Redirect"}}]'
```

Get a LetsEncrypt cert

```bash
acme.sh --issue -d eformat.me --dns --yes-I-know-dns-manual-mode-enough-go-ahead-please
dig TXT _acme-challenge.eformat.me
acme.sh --force --renew -d eformat.me --yes-I-know-dns-manual-mode-enough-go-ahead-please
```

Create Route with cert

```bash
export API=eformat.me

oc apply -f - <<EOF
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  labels:
    app: eformat-me
    app.kubernetes.io/component: eformat-me
    app.kubernetes.io/instance: eformat-me
  name: eformat-me
  namespace: eformat
spec:
  host: eformat.me
  port:
    targetPort: 8080
  to:
    kind: Service
    name: eformat-me
    weight: 100
  wildcardPolicy: None
  tls:
    insecureEdgeTerminationPolicy: Redirect
    termination: edge
    key: |-
$(sed 's/^/      /' /home/mike/.acme.sh/${API}/${API}.key)
    certificate: |-
$(sed 's/^/      /' /home/mike/.acme.sh/${API}/${API}.cer)
    caCertificate: |-
$(sed 's/^/      /' /home/mike/.acme.sh/${API}/fullchain.cer)
EOF
```
