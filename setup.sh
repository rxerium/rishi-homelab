#!/bin/bash

docker-compose -f grafana.yaml -f homepage.yaml -f pi-hole.yaml -f plex.yaml -f portainer.yaml -f tautulli.yaml -f uptime-kuma.yaml up -d