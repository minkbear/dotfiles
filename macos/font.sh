#!/usr/bin/env bash

brew search '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs brew install --cask