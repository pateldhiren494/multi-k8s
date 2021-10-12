#!/bin/sh

host="download.clis.cloud.ibm.com"
metadata_host="$host/ibm-cloud-cli-metadata"
binary_download_host="$host/ibm-cloud-cli"
os_name=$(uname -s | tr '[:upper:]' '[:lower:]')

if [ "$os_name" = "linux" ]; then
    arch=$(uname -m | tr '[:upper:]' '[:lower:]')
    if echo "$arch" | grep -q 'x86_64'
    then
        platform="linux64"
    elif echo "$arch" | grep -q -E '(x86)|(i686)'
    then
        platform="linux32"
    elif echo "$arch" | grep -q 'ppc64le'
    then
        platform="ppc64le"
    elif echo "$arch" | grep -q 's390x'
    then
        platform="s390x"
    else
        echo "Unsupported Linux architecture: ${arch}. Quit installation."
        exit 1
    fi
else
    echo "Unsupported platform: ${os_name}. Quit installation."
    exit 1
fi

# Only use sudo if not running as root:
[ "$(id -u)" -ne 0 ] && SUDO=sudo || SUDO=""

# fetch version metadata of CLI
info_endpoint="https://$metadata_host/info.json"
info=$(curl -f -L -s --insecure "$info_endpoint")
status="$?"

if [ $status -ne 0 ];
then
    echo "Download latest CLI metadata failed. Please check your network connection. Quit installation."
    exit 1
fi

# parse latest version from metadata
latest_version=$(echo "$info" | grep -Eo '"latestVersion"[^,]*' | grep -Eo '[^:]*$' | tr -d '"' | tr -d '[:space:]')
if [ -z "$latest_version" ]
then
    echo "Unable to parse latest version number. Quit installation."
    exit 1
fi

# fetch all versions metadata of CLI
all_versions_endpoint="https://$metadata_host/all_versions.json"
all_versions=$(curl -f -L -s --insecure "$all_versions_endpoint")
status="$?"
if [ $status -ne 0 ];
then
    echo "Download latest CLI versions metadata failed. Please check your network connection. Quit installation."
    exit 1
fi

# get the section of the metadata that we need, starting from the matching version text to the text 'archives'
metadata_section=$(echo "$all_versions" | sed -ne '/'\""$latest_version"\"'/,/'"archives"'/p')
if [ -z "$metadata_section" ]
then
    echo "Unable to parse metadata for CLI version $latest_version. Quit installation."
    exit 1
fi

# get the section for the appropriate platform
platform_binaries=$(echo "$metadata_section" | sed -ne '/'"$platform"'/,/'"checksum"'/p')
# get the installer url
installer_url=$(echo "$platform_binaries" | grep -Eo '"url"[^,]*' | cut -d ":" -f2- | tr -d '"' | tr -d '[:space:]')
# get the checksum
sh1sum=$(echo "$platform_binaries" | grep -Eo '"checksum"[^,]*' | cut -d ":" -f2- | tr -d '"' | tr -d '[:space:]')
if [ -z "$installer_url" ] || [ -z "$sh1sum" ]
then
    echo "Unable to parse installer url and checksum url. Quit installation."
    exit 1
fi

file_name="IBM_Cloud_CLI.tar.gz"

echo "Current platform is ${platform}. Downloading corresponding IBM Cloud CLI..."


if curl -L --insecure $installer_url -o /tmp/${file_name}
then
    echo "Download complete. Executing installer..."
else
    echo "Download failed. Please check your network connection. Quit installation."
    exit 1
fi

calculated_sha1sum=$(sha1sum /tmp/${file_name} | awk '{print $1}')
if [ "$sh1sum" != "$calculated_sha1sum" ]; then
    echo "Downloaded file is corrupted. Quit installation."
    exit 1
fi
cd /tmp || exit
tar -xvf /tmp/${file_name}
chmod 755 /tmp/Bluemix_CLI/install
/tmp/Bluemix_CLI/install -q
install_result=$?
rm -rf /tmp/Bluemix_CLI

if [ $install_result -eq 0 ] ; then
    echo "Install complete."
else
    echo "Install failed."
fi
rm /tmp/${file_name}
