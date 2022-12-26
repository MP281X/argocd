velero install `
    --provider aws `
    --use-restic `
    --plugins velero/velero-plugin-for-aws:v1.5.0 `
    --secret-file ./key/velero.secret `
    --bucket backup `
    --backup-location-config region=eu,s3ForcePathStyle="true",s3Url=https://eu2.contabostorage.com --dry-run -o yaml > velero.yaml