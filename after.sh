#!/bin/bash
cp /root/www/Caddyfile /root/caddy/;
docker exec -w /etc/caddy caddy caddy reload
cd /root/code/cavemancave.github.io;
git fetch --recurse-submodules;
git reset origin/main --hard --recurse-submodules;