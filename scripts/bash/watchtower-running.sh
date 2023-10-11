# -------
#!/bin/bash
# Checks if a container by the name of Watchtower is running on the target machine, if not it will create a container and run it.
# Currently using this script with Ansible
# -------

if [ "$(docker ps -q -f name=watchtower)" ]; then
    echo "Container is running..."
else
    echo "Container is not running, starting a container for Watchtower"
    docker run -d --name watchtower --restart always -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower
fi