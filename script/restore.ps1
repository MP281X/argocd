scp backup/backup.tar.gz mp281x@dev.mp281x.xyz:/home/mp281x/backup.tar.gz
ssh mp281x@dev.mp281x.xyz 'sudo rm -r /home/mp281x/storage/* && sudo tar -xf backup.tar.gz && sudo rm backup.tar.gz'