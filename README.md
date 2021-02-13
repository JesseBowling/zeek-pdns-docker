zeek-pdns-docker
===========================
This project uses Docker, docker-compose, and LetsEncrypt to spin up an instance of [Justin Azoff's bro-pdns](https://github.com/JustinAzoff/bro-pdns) project
 in a Docker container, and publish it with an HTTPS front-end using basic auth. No warranties expressed or implied
 , use at your own risk, PR's welcome, etc...
 
# Setup
 
* Set up a Linux machine with Docker and docker-compose installed
    * This machine uses LetsEncrypt, so it should be publicly accessible (check public IP/firewalls)
* Clone this project somewhere on the VM
* Add a user/password to use for the basic auth
    * `htpasswd ./auth/nginx.htpasswd pdnsuser`
* Put the FQDN in the nginx configuration; for instance if your domain name is 'example.domain.tld'
    * `sed -i -e 's/YOUR_FQDN_HERE/example.domain.tld/g' ./auth/nginx.conf`
* Modify the `zeek-pdns-ingest` `volumes` stanza to be the location of your Zeek DNS log files (`/zeek` in our 
  example config). If your log files have a non-default naming standard, you may need to adjust line 12 (find 
  statement) in the `index_pdns.bash` script.
* _Optional_: Adjust the `POSTGRES_PASSWORD` and `POSTGRES_USER` variables in `docker-compose.yml`. By default this
 container is never exposed to the network, but if through misconfiguration it was, the default user/password is
  terrible. You have been warned.
* `docker-compose build && docker-compose up -d`

## Operations

Assuming the above all went well, 

You should probably consider restarting the pdns containers on at least a daily basis in order to dump the logs
. Unfortunately the bro-pdns ingest is quite noisy from a log perspective, with no easy way to quiet it down (PR's
 welcome!).
 
## Querying

To query the instance, hit the front-end with a query. Let's assume your FQDN is 'example.domain.tld':

```bash
$ curl https://example.domain.tld/dns/like/tuples/google.com
$ curl https://example.domain.tld/dns/like/individual/google.com
$ curl https://example.domain.tld/dns/find/tuples/google.com
$ curl https://example.domain.tld/dns/find/individual/google.com
```
 
Feel free to open an issue if you have one!
