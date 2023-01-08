ssh mp281x@dev.mp281x.xyz 'sudo tar -zcvf /home/mp281x/backup-$(date +"%d-%m-%Y").tar.gz /home/mp281x/storage'
scp mp281x@dev.mp281x.xyz:/home/mp281x/backup-$(Get-Date -Format "dd-MM-yyyy").tar.gz backup/backup-$(Get-Date -Format "dd-MM-yyyy").tar.gz
ssh mp281x@dev.mp281x.xyz 'sudo rm /home/mp281x/backup-$(date +"%d-%m-%Y").tar.gz'