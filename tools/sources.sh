# A script that creates a sources.nix skeleton by looking for the latest
# commit in the specified branch.

# Usage: TOKEN=GITHUB_TOKEN bash sources.sh
# Note the token is used since there is rate limitation on the API.

cat >/tmp/tmp.lst <<EOF
build Juniper contrail-build R3.2
controller Juniper contrail-controller R3.2
generateds Juniper contrail-generateds R3.2
neutronPlugin Juniper contrail-neutron-plugin R3.2
sandesh Juniper contrail-sandesh R3.2
thirdParty Juniper contrail-third-party R3.2
vrouter Juniper contrail-vrouter R3.2
webController Juniper contrail-web-controller R3.2
webCore Juniper contrail-web-core R3.2
webuiThirdParty Juniper contrail-webui-third-party R3.2
EOF

while read -r ATTRIBUTE OWNER REPOS BRANCH; do
    COMMITID=$(curl -H "Authorization: token ${TOKEN}" --silent https://api.github.com/repos/$OWNER/$REPOS/branches/$BRANCH | jq -r '.commit.sha')
    curl --silent -L https://github.com/$OWNER/$REPOS/archive/$COMMITID.tar.gz > /tmp/tmp.tgz

    rm -rf /tmp/untar.tmp/
    mkdir /tmp/untar.tmp
    tar -C /tmp/untar.tmp/ -xf /tmp/tmp.tgz
    SHA256=$(find /tmp/untar.tmp/ -maxdepth 1 -mindepth 1 -exec nix-hash --type sha256 --base32 '{}' \;)

    echo "$ATTRIBUTE = pkgs.fetchFromGitHub {"
    echo "  owner = \"$OWNER\";";
    echo "  repo = \"$REPOS\";"
    echo "  rev = \"$COMMITID\";"
    echo "  sha256 = \"$SHA256\";"
    echo "};"
done < /tmp/tmp.lst

rm -f /tmp/tmp.lst
rm -f /tmp/tmp.tgz
rm -rf /tmp/untar.tmp
