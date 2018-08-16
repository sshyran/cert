# ivansible.letsencrypt_master

This role configures a dedicated host, which is requesting
certificates from letsencrypt, to automatically propagate them to a number
of replica hosts. This design allows for higher security: critical
cloudlare/letsencrypt credentials are kept on a single secure host.
Propagation is performed via _rsync_ / _ssh_. For additional security,
propagation is done by `pushing`: it is master host that initiates
accesses to replicas. This avoids keeping critical master ssh keys
on replicas.


## Requirements

None


## Variables

Available variables are listed below, along with default values.

    certbot_master_replica_hosts: []
Inventory hostnames of replicas connected to the master host.

    certbot_replica_ssh_keys: ...
Keys for ssh access from the certbot master host. One key is usually enough.
Must be the same on master and replica hosts.

    certbot_push_attempt_interval_minutes: 15


## Tags

- `le_master_install` -- install certbot and rsync packages
- `le_master_ssh` -- configure ssh keys and aliases
                     for root user to access replicas
- `le_master_service` -- create replica pushing script,
                         global pushing script, services and timers
- `le_master_cleanup` -- remove stale certbot-push service and timer units


## Dependencies

This role requires that `ivansible.letsencrypt_cloudflare` is already
installed on the host. However, since other letsencrypt challenges
may be used, there is no ansible dependency. On the other hand, since
`ivansible.letsencrypt_master` and `ivansible.letsencrypt_replica` roles
are so tightly coupled, the master role is not invoked from playbooks
directly, but rather imported by the slave role.


## Implementation details

When certbot on master host renews a certificate, it invokes a post-renewal
shell script `/etc/letsecnrypt/renewal-handlers/post/push`.
This script starts a number of timers that periodically invoke push script
`/usr/local/sbin/certbot-push-replica.sh` for each replica host.
This script performs another push attempt and stops its own timer when
the attempt is succesful. Every attempt runs `rsync` to synchronize
`archive` and `live` letsencrypt directories with renewed certificates
to a temporary non-root location on the corresponding replica machine,
then uses `ssh` to invoke a post-receive script on the replica machine
(`/usr/local/sbin/certbot-post-receive.sh`). This script is run as root.
It moves received data to the final location in `/etc/letsencrypt`, fixes
access permissions and runs local replica letsencrypt hook scripts from
`/etc/letsencrypt/renewal-hooks`. As checking remote return code via ssh
is not always possible, the post-receive script will echo a success message
if nothing has failed, and the replica push script on master will declare
an attempt succesful only when it sees this message.


## Example Playbook

    - hosts: master-host
      roles:
         - role: ivansible.letsencrypt_master
           certbot_master_replica_hosts:
             - slave-host1
             - slave-host2
            certbot_push_attempt_interval_minutes: 30


## License

MIT

## Author Information

Created in 2018 by [IvanSible](https://github.com/ivansible)
