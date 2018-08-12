# ivansible.letsencrypt-replica
This role configures a host for receiving letsencrypt certificates from certbot master host.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    certbot_replica_user: "{{ ansible_user_id }}"
Certbot master will access replica via rsync/ssh using this user

    certbot_replica_ssh_keys: "{{ query('fileglob', 'files/secret/vanko-*.key') }}"
Keys for ssh access from the certbot master host.

## Tags

- `le_replica_install` -- install certbot and rsync packages
- `le_replica_group` -- grant certbot group access to letsencrypt files
- `le_replica_sudo` -- configure sudoers
- `le_replica_ssh` -- authorize ssh keys with pull user
- `le_replica_receive` -- disable certbot certificate renewal service
- `le_replica_receive` -- create post-receive handler script


## Dependencies

None


## Example Playbook

    - hosts: vagrant-boxes
      roles:
         - role: ivansible.letsencrypt-replica


## License

MIT

## Author Information

Created in 2018 by [IvanSible](https://github.com/ivansible)
