#!/bin/bash

# Function to read input from user with a prompt
function read_with_prompt {
  variable_name="$1"
  prompt="$2"
  default="${3-}"
  unset $variable_name
  while [[ ! -n ${!variable_name} ]]; do
    read -p "$prompt: " $variable_name < /dev/tty
    if [ ! -n "`which xargs`" ]; then
      declare -g $variable_name=$(echo "${!variable_name}" | xargs)
    fi
    declare -g $variable_name=$(echo "${!variable_name}" | head -n1 | awk '{print $1;}' | tr -cd '[a-zA-Z0-9]._-')
    if [[ -z ${!variable_name} ]] && [[ -n "$default" ]]; then
      declare -g $variable_name=$default
    fi
    echo -n "$prompt : ${!variable_name} -- accept (y/n)?"
    read answer < /dev/tty
    if [[ "$answer" == "${answer#[Yy]}" ]]; then
      unset $variable_name
    else
      echo "$prompt: ${!variable_name}"
    fi
  done
}

# add your wallet addres
echo "Enter wallet addres. It's highly recommended to create a new wallet for mining because wallet addresses are public on p2pool. You have to use the primary wallet address for mining. Subaddresses and integrated addresses are not supported, just like with monerod solo mining."
read_with_prompt walletAddres "wallet Addres"
echo "walletAddres=\"$walletAddres\"" > .env

# install p2pool
echo "Install P2Pool? type yes/no (default yes)"
read_with_prompt useP2Pool "use P2Pool" "yes"
echo "useP2Pool=\"$useP2Pool\"" >> .env

# install Monerod
echo "Install Monerod? type yes/no (default yes)"
read_with_prompt UseMonerod "use Monerod" "yes"
echo "UseMonerod=\"$UseMonerod\"" >> .env

# add Monerod ip addres 
echo "enter ip of Monerod. (default 127.0.0.1)"
read_with_prompt monerod_ip "Monerod ip" "127.0.0.1"
echo "monerod_ip=\"$monerod_ip\"" >> .env

# add p2pool ip addres
echo "enter ip of p2pool (default 127.0.0.1)"
read_with_prompt p2pool_ip "p2pool ip" "127.0.0.1"
echo "p2pool_ip=\"$p2pool_ip\"" >> .env


