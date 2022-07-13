## Usage - sshd_config

1. Download the file `sshd_config` from the repository
1. **Review the content of the `sshd_config` file to make sure all settings are suitable for your system**
1. Backup your current `/etc/ssh/sshd_config` file
1. Overwrite the old `sshd_config` file with the downloaded `sshd_config` file
1. Run the appropriate command to restart the SSH service (e.g., `service sshd restart`)

## Usage - journald
1. Download the file `journald.conf` from the repository
1. Backup your current `/etc/systemd/journald.conf` file
1. Overwrite the old `journald.conf` file with the downloaded `journald.conf` file
1. Restart the service `systemctl restart systemd-journald`

