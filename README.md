zeek-pdns-docker
===========================
This project uses Docker, docker-compose, and LetsEncrypt to spin up an instance of [Justin Azoff's bro-pdns](https://github.com/JustinAzoff/bro-pdns) project
 in a Docker container, and publish it with an HTTPS front-end using basic auth. No warranties expressed or implied
 , use at your own risk, PR's welcome, etc...
 
 #Setup
 
 * Set up a Linux machine with Docker and docker-compose installed
 ** This machine uses LetsEncrypt, so it should be publicly acessible (check public IP/firewalls)
 * Clone this project somewhere on the VM
 * Add a user/password to use for the basic auth
 ** `htpasswd ./auth/nginx.htpasswd pdnsuser`
 * Put the FQDN in the nginx configuration; for instance if your domain name is 'example.domain.tld'
 ** `sed -i -e 's/YOUR_FQDN_HERE/example.domain.tld/g' ./auth/nginx.conf`
 * `mkdir -p ./skipped ./ingest ./spool`
 * _Optional_: Adjust the `POSTGRES_PASSWORD` and `POSTGRES_USER` variables in `docker-conmpose.yml`. By default this
 container is never exposed to the network, but if through misconfiguration it was, the default user/password is
  terrible. You have been warned.
* `docker-compose build && docker-compose up -d`

#Operations
Assuming the above all went well, you can now move any files you want ingested into the `./spool` directory. I
 typically run this setup on a box that is NOT the zeek sensor (and suggest you do too!), so I use the `./ingest
 ` directory as a temporary location before `mv`ing files from there to the `./spool` directory. 
 
 For example, on my Zeek manager box (where the logs live) I have the following script cron'ed under the unprivileged
  user _pdns_:
 
 ```bash
 #!/bin/bash

DAY=`date --date "yesterday" +%Y-%m-%d`
cd /zeek/logs/${DAY}
for FILE in `ls dns.*`
do
  scp -i /home/pdns/.ssh/id_ed25519 ./${FILE} pdns@zeek-pdns-box:~/incoming/${DAY}-${FILE}
  if [[ $? == 0 ]]
  then
    ssh -i /home/pdns/.ssh/id_ed25519 pdns@zeek-pdns-box "mv incoming/${DAY}-${FILE} spool/"
  fi
done
echo "Finished transferring files for ${DAY}"
```
The naming matters because the postgres database will use the filename to record whether or not it needs to index a
 file. If the filename has been seen before, it won't index it.
 
Once a file is in place, the `zeek-pdns-ingest` container will wake up every 60 seconds to see if there are files to
 ingest. If so, it will attempt to ingest them. If it's successful, it deletes the file, and if not, it moves the
  file to the `./skipped` directory. 
  
You should probably consider restarting the pdns containers on at least a daily basis in order to dump the logs
. Unfortunately the bro-pdns ingest is quite noisy from a log perspective, with no easy way to quiet it down (PR's
 welcome!).
 
To query the instance, hit the front-end with a query. Let's assume your FQDN is 'example.domain.tld':

```bash
$ curl https://example.domain.tld/dns/like/tuples/google.com
$ curl https://example.domain.tld/dns/like/individual/google.com
$ curl https://example.domain.tld/dns/find/tuples/google.com
$ curl https://example.domain.tld/dns/find/individual/google.com
```
 
Feel free to open an issue if you have one!
