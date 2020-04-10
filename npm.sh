#!/usr/bin/env bash

os=$(uname)

npm=$(which npm 2> /dev/null)

if [ $? -ne 0 ]; then
  echo 'Can not find the installation location of npm.'
  exit
fi

if [ "$os" = "Darwin" ]; then
  which greadlink > /dev/null 2>&1

  if [ $? -ne 0 ]; then
    echo 'use `brew install coreutils` install `coreutils` first.'
    exit
  fi
  npm=$(greadlink -f "$npm")
  sed=gsed
else
  npm=$(readlink -f "$npm")
  sed=sed
fi

npm=$(dirname $(dirname "$npm"))

echo "[npm] $npm"

postinstall="${npm}/lib/install/action/postinstall.js"

if [ -f "$postinstall" ]; then
  echo "[postinstall] $postinstall"

  if [ -n "$RESTORE" ]; then
    $sed -iE '/core-js/d' "$postinstall"

    if [ $? -eq 0 ]; then
      echo restore success.
    else
      echo restore faile.
    fi
    exit
  fi

  patched=$(cat "$postinstall" | grep 'core-js')

  if [ -z "$patched" ]; then
    $sed -iE '/log.silly/i \ \ if(/^core-js(?:-(builder|bundle|compat|pure))?@/.test(packageId(pkg))){next();return;}' "$postinstall"
    if [ $? -eq 0 ]; then
      echo patched success.
    else
      echo patched faile.
    fi
  else
    echo already patched.
  fi
else
  echo Can not find postinstall.js file.
fi

# vim: set expandtab tabstop=2 softtabstop=2 shiftwidth=2 :
