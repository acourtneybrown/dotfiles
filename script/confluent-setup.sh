#!/usr/bin/env bash

pip3 install -U autopip

# Keep autopip updated automatically by installing itself
app install autopip==1.* --update monthly

# Install app that contains pint command and optionally keep it updated daily so you don't have to
app install release-tools --update daily
