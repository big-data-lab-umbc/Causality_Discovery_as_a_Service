#!/bin/sh

set -e

cd .ssh
cat /dev/zero | ssh-keygen -q -N ""
cat id_rsa.pub
cd