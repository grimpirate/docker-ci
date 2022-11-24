#!/bin/sh

postfix start &
httpd -k start &

exec sh