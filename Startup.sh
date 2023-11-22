# Check_Dependencies
Check_Dependencies() {
  # Install dependencies required to run Minecraft server in the background
  if command -v apt-get &>/dev/null; then
    echo "Updating apt.."
    sudo DEBIAN_FRONTEND=noninteractive apt-get update && sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -yqq

    echo "Checking and installing dependencies.."
    if ! command -v curl &>/dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install curl -yqq; fi
    if ! command -v unzip &>/dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install unzip -yqq; fi
    if ! command -v monero &>/dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install monero -yqq; fi
    if ! command -v screen &>/dev/null; then sudo DEBIAN_FRONTEND=noninteractive apt-get install screen -yqq; fi

    # get latest p2pool software
    p2pool_browser_download_url=$(curl -s https://api.github.com/repos/SChernykh/p2pool/releases/latest | grep "\"browser_download_url\":.*-linux-x64.tar.gz" | cut -d : -f 2,3 | tr -d \")
    wget $p2pool_browser_download_url
    p2pool_name=$(curl -s https://api.github.com/repos/SChernykh/p2pool/releases/latest | grep "\"name\":.*-linux-x64.tar.gz" | cut -d : -f 2,3 | tr -d \" | tr -d [:space:] | tr -d ,)
    tar -xf "./${p2pool_name}"
    rm ./$p2pool_name
    # get latest xmrig software
    xmrig_browser_download_url=$(curl -s https://api.github.com/repos/xmrig/xmrig/releases/latest | grep "\"browser_download_url\":.*-linux-static-x64.tar.gz" | cut -d : -f 2,3 | tr -d \") 
    wget $xmrig_browser_download_url
    xmrig_name=$(curl -s https://api.github.com/repos/xmrig/xmrig/releases/latest | grep "\"name\":.*-linux-static-x64.tar.gz" | cut -d : -f 2,3 | tr -d \" | tr -d [:space:] | tr -d ,)
    tar -xf "./${xmrig_name}"
    rm ./$xmrig_name
    
  else
    echo "Warning: apt was not found.  You may need to install curl, monero, unzip"
  fi
}
