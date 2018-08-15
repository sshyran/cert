# ivansible.letsencrypt-replica
This role configures a host for receiving new letsencrypt certificates
from certbot master host.

Certbot creates certificates and private keys with permissions 0644.
It rather prevents world access on the directory level.
Some software e.g. Postgresql server requires that private keys are not world-readable.
This role takes care of asigning appropriate group to private keys
and sets their mode to 0640. This is done by the post-receive hook script.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    certbot_replica_user: "{{ ansible_user_id }}"
Certbot master will access replica via rsync/ssh using this user

    certbot_replica_ssh_keys: "{{ query('fileglob', 'files/secret/vanko-*.key') }}"
Keys for ssh access from the certbot master host.

    certbot_master_host: None
When defined, this must be inventory hostname of the master host
for currently running `ansible_play_hosts` list of replicas.
The role `ivansible.letsencrypt_master` will be run on this host
with current play hosts in parameter `certbot_master_replica_hosts`.

    certbot_group: ssl-cert
Members of this unix group will have read access to certificates.
This group must be the same on master and replica hosts.


## Tags

- `le_replica_install` -- install certbot and rsync packages
- `le_replica_group` -- grant certbot group access to letsencrypt files
- `le_replica_sudo` -- configure sudoers
- `le_replica_ssh` -- authorize ssh keys with pull user
- `le_replica_receive` -- disable certbot certificate renewal service
- `le_replica_receive` -- create post-receive handler script
- `le_replica_master` -- configure master host in a separate role


## Dependencies

This role will invoke role `ivansible.letsencrypt-master`
on the master host if appropriate parameter is set.
This will be performed once (`run_once`) for all replica hosts.

We could probably avoid this dependency and list master actions
in a separate play in the containing playbook, additionally allowing
for multiple master hosts. However, _letsencrypt-master_ and _replica_
roles are so tightly coupled that we go for this dependency.
Moreover, with letsencrypt/cloudflare there can be only one node
requesting certificates.


## Example Playbook

    - hosts: vagrant-boxes
      roles:
         - role: ivansible.letsencrypt-replica


## License

MIT

## Author Information

Created in 2018 by [IvanSible](https://github.com/ivansible)
