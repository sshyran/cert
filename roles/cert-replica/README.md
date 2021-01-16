# ivansible.cert_replica

[![Github Test Status](https://github.com/ivansible/cert-replica/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/cert-replica/actions)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.cert__replica-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/cert_replica/)

This role configures a host for receiving new letsencrypt certificates
from certbot master host. Please refer to `cert_master`
[implementation details](https://github.com/ivansible/cert-master#implementation-details).

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

    certbot_replica_ssh_keys: "{{ lin_ssh_keys_files }}"
Keys for ssh access from the certbot master host.

    certbot_replica_user_interactive: false
    certbot_replica_ssh_keys_interactive: none
Subset of accepted ssh keys with interactive features enabled.
Disabled by default as unused in this role,
but the settings exist for cross-idempotence with
role [ivansible.dev-user](https://github.com/ivansible/dev-user/#variables).
See there for details.

    certbot_master_host: None
When defined, this must be inventory hostname of the master host
for currently running `ansible_play_hosts` list of replicas.
The role `ivansible.cert_master` will be run on this host
with current play hosts in parameter `certbot_master_replica_hosts`.

    certbot_group: ssl-cert
Members of this unix group will have read access to certificates.
This group must be the same on master and replica hosts.


## Tags

- `cert_replica_install` -- install certbot and rsync packages
- `cert_replica_group` -- grant certbot group access to letsencrypt files
                          (deliberately overlaps with role
                          [cert_cloudflare](https://github.com/ivansible/cert-cloudflare))
- `cert_replica_sudo` -- configure sudoers
- `cert_replica_ssh` -- authorize ssh keys with pull user
- `cert_replica_receive` -- disable certbot certificate renewal service
                            and create post-receive handler script
- `cert_replica_master` -- configure master host in a separate role
- `cert_replica_all` -- all tasks


## Dependencies

This role will invoke sub-role [cert_master](https://github.com/ivansible/cert-master)
on the master host if appropriate parameter is set.
This will be performed once (`run_once`) for all replica hosts.

We could probably avoid this dependency and list master actions
in a separate play in the containing playbook, additionally allowing
for multiple master hosts. However, _cert_master_ and _replica_
roles are so tightly coupled that we go for this dependency.
Moreover, with `letsencrypt/cloudflare` there can be only one host node
requesting certificates.

Also depends on:
  - `ivansible.lin_base` for `lin_ssh_keys_files`
  - `ivansible.cert_base` got common certbot settings and tasks


## Example Playbook

    - hosts: vagrant-boxes
      roles:
         - role: ivansible.cert_replica


## License

MIT

## Author Information

Created in 2018-2021 by [IvanSible](https://github.com/ivansible)
