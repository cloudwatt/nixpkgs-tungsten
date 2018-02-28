#!/usr/bin/env bash

# Usage example
# URL=http://localhost:30000 bash ci/create-project.sh

set -e

USERNAME=${USERNAME:-admin}
PASSWORD=${PASSWORD:-admin}
PROJECT_NAME="opencontrail"
JOBSET_NAME="trunk"
URL=${URL:-http://localhost:3000}

mycurl() {
  curl --referer $URL -H "Accept: application/json" -H "Content-Type: application/json" $@
}

echo "Logging to $URL with user" "'"$USERNAME"'"
cat >data.json <<EOF
{ "username": "$USERNAME", "password": "$PASSWORD" }
EOF
mycurl -X POST -d '@data.json' $URL/login -c hydra-cookie.txt

echo -e "\nCreating project:"
cat >data.json <<EOF
{
  "displayname":"OpenContrail CI",
  "enabled":"1"
}
EOF
cat data.json
mycurl --silent -X PUT $URL/project/$PROJECT_NAME -d @data.json -b hydra-cookie.txt


echo -e "\nCreating jobset testing:"
cat >data.json <<EOF
{
  "description": "Build master of nixpkgs-contrail",
  "checkinterval": "60",
  "enabled": "1",
  "visible": "1",
  "nixexprinput": "contrail",
  "nixexprpath": "jobset.nix",
  "inputs": {
    "contrail": {
      "value": "https://github.com/nlewo/nixpkgs-contrail master",
      "type": "git"
    },
    "bootstrap_pkgs": {
      "value": "https://github.com/NixOS/nixpkgs a0e6a891ee21a6dcf3da35169794cc20b110ce05",
      "type": "git"
    }
  }
}
EOF
cat data.json
mycurl --silent -X PUT $URL/jobset/$PROJECT_NAME/$JOBSET_NAME -d @data.json -b hydra-cookie.txt


JOBSET_NAME="testing"
echo -e "\nCreating jobset testing:"
cat >data.json <<EOF
{
  "description": "Build testing branch of nixpkgs-contrail",
  "checkinterval": "60",
  "enabled": "1",
  "visible": "1",
  "nixexprinput": "contrail",
  "nixexprpath": "jobset.nix",
  "inputs": {
    "contrail": {
      "value": "https://github.com/nlewo/nixpkgs-contrail testing",
      "type": "git"
    },
    "bootstrap_pkgs": {
      "value": "https://github.com/NixOS/nixpkgs a0e6a891ee21a6dcf3da35169794cc20b110ce05",
      "type": "git"
    }
  }
}
EOF
cat data.json
mycurl --silent -X PUT $URL/jobset/$PROJECT_NAME/$JOBSET_NAME -d @data.json -b hydra-cookie.txt

JOBSET_NAME="staging"
echo -e "\nCreating jobset staging:"
cat >data.json <<EOF
{
  "description": "Build master of nixpkgs-contrail and follow nixpkgs stable",
  "checkinterval": "86400",
  "enabled": "1",
  "visible": "1",
  "nixexprinput": "contrail",
  "nixexprpath": "jobset.nix",
  "inputs": {
    "contrail": {
      "value": "https://github.com/nlewo/nixpkgs-contrail master",
      "type": "git"
    },
    "nixpkgs": {
      "value": "https://github.com/NixOS/nixpkgs-channels nixos-17.09",
      "type": "git"
    },
    "bootstrap_pkgs": {
      "value": "https://github.com/NixOS/nixpkgs a0e6a891ee21a6dcf3da35169794cc20b110ce05",
      "type": "git"
    }
  }
}
EOF
cat data.json
mycurl --silent -X PUT $URL/jobset/$PROJECT_NAME/$JOBSET_NAME -d @data.json -b hydra-cookie.txt

JOBSET_NAME="unstable"
echo -e "\nCreating jobset unstable:"
cat >data.json <<EOF
{
  "description": "Build master of nixpkgs-contrail and follow nixpkgs unstable",
  "checkinterval": "86400",
  "enabled": "1",
  "visible": "1",
  "keepnr": "1",
  "nixexprinput": "contrail",
  "nixexprpath": "jobset.nix",
  "inputs": {
    "contrail": {
      "value": "https://github.com/nlewo/nixpkgs-contrail master",
      "type": "git"
    },
    "nixpkgs": {
      "value": "https://github.com/NixOS/nixpkgs-channels nixos-unstable",
      "type": "git"
    },
    "bootstrap_pkgs": {
      "value": "https://github.com/NixOS/nixpkgs a0e6a891ee21a6dcf3da35169794cc20b110ce05",
      "type": "git"
    }
  }
}
EOF
cat data.json
mycurl --silent -X PUT $URL/jobset/$PROJECT_NAME/$JOBSET_NAME -d @data.json -b hydra-cookie.txt

rm -f data.json hydra-cookie.txt
