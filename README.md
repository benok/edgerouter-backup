# edgerouter-backup

These are my backup scripts for pushing EdgeRouter configurations to a remote host and remotely executing a `git commit` and `git push`. 

### Installation

Copy contents of `config` directory to `/config` on EdgeRouter.

### Configuration

Edit `/config/user-data/edgerouter-backup.conf` with your information:

     #!/bin/bash

     # Path to private key for SSH / SCP
     SSH_KEYFILE=/config/user-data/backup_user_private.key
     SSH_USER=username
     SSH_HOST=host
     
     # Path to git repo on SSH_HOST
     REPO_PATH=\~/edgerouter-backup

### Remote Host Setup

* Make sure your SSH key works.

* Create git repo in `REPO_PATH`.

* Configure repo as desired.

* Verify that `git commit -m "Commit Message"` and `git push` execute without interaction.
