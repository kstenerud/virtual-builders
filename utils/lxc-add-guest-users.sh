#!/bin/bash

echo "lxcnobody:x:165534:" >> /etc/group
echo "lxcnobody:x:165534:165534:Maps to user nobody inside an LXC container:/nonexistent:/usr/sbin/nologin" >> /etc/passwd

echo "lxcfirstuser:x:101000:" >> /etc/group
echo "lxcfirstuser:x:101000:101000:Maps to the first user (1000) inside an LXC container:/nonexistent:/usr/sbin/nologin" >> /etc/passwd
