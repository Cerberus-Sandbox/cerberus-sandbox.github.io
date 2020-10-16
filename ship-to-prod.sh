#!/bin/bash
if ! command -v mkdocs &> /dev/null; then echo "mkdocs packages missing"; exit 1; fi
if ! command -v git &> /dev/null; then echo "git packages missing"; exit 1; fi
if [[ ${PWD##*/} != "cerberus-sandbox.github.io" ]]; then exit 1; fi
git pull --quiet
git branch | grep "main" > /dev/null 2>&1
if [[ $? != 0 ]]; then exit 1; fi
git branch | grep "master" > /dev/null 2>&1
if [[ $? != 0 ]]; then exit 1; fi
git checkout main
git add docs/*
git add mkdocs.yml
if [[ $1 ]]; then desc="[$(date +%D) $(date +%T)][$(whoami)@$(hostname)][Automatic Commit] $1"
else desc="[$(date +%D) $(date +%T)][$(whoami)@$(hostname)][Automatic Commit] Docs Update" ;fi
git commit -m "$desc"
git push
mkdocs gh-deploy --force --remote-branch master
exit 0
