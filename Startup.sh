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
    
  else
    echo "Warning: apt was not found.  You may need to install curl, monero, unzip"
  fi
}

# fetch variables from .env file
if [ ! -f .env ]
then
  echo "Error: .env was not found. Run setup.sh first." 
  exit 1
else
  export $(cat .env | xargs)
fi

if [ "$UseMonerod" = "yes" ]
then
# start monerod
screen -dmS monero /bin/bash -c "sudo monerod --zmq-pub tcp://127.0.0.1:18083 --out-peers 8 --in-peers 16 --add-priority-node=p2pmd.xmrvsbeast.com:18080 --add-priority-node=nodes.hashvault.pro:18080 --disable-dns-checkpoints --enable-dns-blocklist"
fi

if [ "$useP2Pool" = "yes" ]
then
  # get latest p2pool software
  p2pool_folder="p2pool"
  p2pool_browser_download_url=$(curl -s https://api.github.com/repos/SChernykh/p2pool/releases/latest | grep "\"browser_download_url\":.*-linux-x64.tar.gz" | cut -d : -f 2,3 | tr -d \")
  wget $p2pool_browser_download_url
  p2pool_name=$(curl -s https://api.github.com/repos/SChernykh/p2pool/releases/latest | grep "\"name\":.*-linux-x64.tar.gz" | cut -d : -f 2,3 | tr -d \" | tr -d [:space:] | tr -d ,)
  tar -xzf "./${p2pool_name}" -C "${p2pool_folder}" --strip-components=1
  rm ./$p2pool_name
   
  # start p2pool
  screen -dmS p2pool /bin/bash -c "sudo ./$p2pool_folder/p2pool --host $monerod_ip --wallet $walletAddres"
fi


# get latest xmrig software
xmrig_folder="xmrig"
xmrig_browser_download_url=$(curl -s https://api.github.com/repos/xmrig/xmrig/releases/latest | grep "\"browser_download_url\":.*-linux-static-x64.tar.gz" | cut -d : -f 2,3 | tr -d \") 
wget $xmrig_browser_download_url
xmrig_name=$(curl -s https://api.github.com/repos/xmrig/xmrig/releases/latest | grep "\"name\":.*-linux-static-x64.tar.gz" | cut -d : -f 2,3 | tr -d \" | tr -d [:space:] | tr -d ,)
tar -xzf "./${xmrig_name}" -C "${xmrig_folder}" --strip-components=1
rm ./$xmrig_name

# start xmrig
screen -dmS xmrig /bin/bash -c "sudo ./$xmrig_folder/xmrig -o $p2pool_ip:3333"