local createApp(name, image, port, data) = [
  {
    apiVersion: 'v1',
    kind: 'Namespace',
    metadata: { name: name + '-ns' },
  },
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: name,
      namespace: name + '-ns',
      labels: { app: name },
    },
    spec: {
      replicas: 1,
      selector: { matchLabels: { app: name } },
      template: {
        metadata: { labels: { app: name } },
        spec: {
          containers: [
            {
              name: name,
              image: image,
              ports: [{ containerPort: port }],
              volumeMounts: [{ name: name + '-pvc', mountPath: data }],
            },
          ],
          volumes: [{
            name: name + '-pvc',
            persistentVolumeClaim: { claimName: name + '-pvc' },
          }],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'PersistentVolumeClaim',
    metadata: {
      name: name + '-pvc',
      namespace: name + '-ns',
    },
    spec: {
      accessModes: ['ReadWriteOnce'],
      storageClassName: 'longhorn',
      resources: { requests: { storage: '1Gi' } },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: name + '-svc',
      namespace: name + '-ns',
    },
    spec: {
      selector: { app: name },
      ports: [{ port: port, name: name, targetPort: port }],
    },
  },

];


createApp('vaultwarden', 'vaultwarden/server:latest', 80, '/data')