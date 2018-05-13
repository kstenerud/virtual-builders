#!/bin/bash

echo "lxcnobody:x:165534:" >> /etc/group
echo "lxcnobody:x:165534:165534:Mapped user for file sharing:/nonexistent:/usr/sbin/nologin" >> /etc/passwd

echo "lxcfirstuser:x:101000:" >> /etc/group
echo "lxcfirstuser:x:101000:101000:Mapped user for file sharing:/nonexistent:/usr/sbin/nologin" >> /etc/passwd
