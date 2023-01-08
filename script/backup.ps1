ssh mp281x@dev.mp281x.xyz 'sudo tar -zcf backup.tar.gz storage'
scp mp281x@dev.mp281x.xyz:backup.tar.gz backup/backup.tar.gz
ssh mp281x@dev.mp281x.xyz 'sudo rm backup.tar.gz'