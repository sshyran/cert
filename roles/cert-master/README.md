# ivansible.cert_master

[![Github Test Status](https://github.com/ivansible/cert-master/workflows/Molecule%20test/badge.svg?branch=master)](https://github.com/ivansible/cert-master/actions)
[![Ansible Galaxy](https://img.shields.io/badge/galaxy-ivansible.cert__master-68a.svg?style=flat)](https://galaxy.ansible.com/ivansible/cert_master/)

This role configures a dedicated host, which is requesting
certificates from letsencrypt, to automatically propagate them to a number
of replica hosts. This design allows for higher security: critical
cloudlare/letsencrypt credentials are kept on a single secure host.
Propagation is performed via _rsync_ / _ssh_. For additional security,
propagation is done by `pushing`: it is master host that initiates
accesses to replicas. This avoids keeping critical master ssh keys
on replicas.

This role assumes that certbot package has been already installed.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    certbot_master_replica_hosts: []
Inventory hostnames of replicas connected to the master host.

    certbot_master_replica_hosts_arg: null
This comma separated string allows to override list of replicas
from ansible command line.

    certbot_replica_ssh_keys: ...
Keys for ssh access from the certbot master host. One key is usually enough.
Must be the same on master and replica hosts.

    certbot_push_attempt_interval_minutes: 15


## Tags

- `cert_master_install` -- install certbot and rsync packages
- `cert_master_ssh` -- configure ssh keys and aliases
                       for root user to access replicas
- `cert_master_service` -- create replica pushing script,
                           global pushing script, services and timers
- `cert_master_cleanup` -- remove stale certbot-push service and timer units
- `cert_master_all` -- all tasks


## Dependencies

This role requires that `ivansible.cert_cloudflare` is already
installed on the host. However, since other letsencrypt challenges
may be used, there is no ansible dependency. On the other hand, since
`ivansible.cert_master` and `ivansible.cert_replica` roles
are so tightly coupled, the master role is not invoked from playbooks
directly, but rather imported by the slave role.

Also depends on:
  - `ivansible.lin_base` for `lin_ssh_keys_files`
  - `ivansible.cert_base` got common certbot settings and tasks


## Implementation details

When certbot on master host renews a certificate, it invokes a post-renewal
shell script `/etc/letsecnrypt/renewal-handlers/post/push`.
This script starts a number of timers that periodically invoke push script
`/usr/local/sbin/certbot-push-replica.sh` for each replica host.
This script performs another push attempt and stops its own timer when
the attempt is succesful. Every attempt runs `rsync` to synchronize
`archive` and `live` letsencrypt directories with renewed certificates
to a temporary non-root location on the corresponding
[replica machine](https://github.com/ivansible/cert-replica#ivansiblecert_replica).

Then master uses `ssh` to invoke a post-receive script on the replica machine
(`/usr/local/sbin/certbot-post-receive.sh`) under root user.
It moves received data to the final location in `/etc/letsencrypt`, fixes
access permissions and runs local replica letsencrypt hook scripts from
`/etc/letsencrypt/renewal-hooks`. As checking remote return code via ssh
is not always possible, the post-receive script will echo a success message
if nothing has failed, and the replica push script on master will declare
an attempt succesful only when it sees this message.


## Example Playbook

    - hosts: master-host
      roles:
         - role: ivansible.cert_master
           certbot_master_replica_hosts:
             - slave-host1
             - slave-host2
            certbot_push_attempt_interval_minutes: 30


## License

MIT

## Author Information

Created in 2018-2021 by [IvanSible](https://github.com/ivansible)
