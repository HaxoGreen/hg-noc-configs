#!/bin/sh

# add IP to DSL interface
ip a add 2a02:6f00:1337:2::2/64 dev $dev
