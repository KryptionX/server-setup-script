#!/bin/bash

set -e

check_exit_status() {

  if [ $? -eq 0 ]; then
    echo
    echo "Success"
    echo
  else
    echo
    echo "[ERROR] Process Failed!"
    echo

    read -p "The last command exited with an error. Exit script? (yes/no) " answer

    if [ "$answer" == "yes" ]; then
      exit 1
    fi
  fi
}

greeting() {

  echo
  echo "Hello, $USER. Let's do this shit."
  echo
}

update() {

  echo
  echo "Updates"
  echo

  sudo apt update
  check_exit_status

  sudo apt upgrade -y
  check_exit_status

  sudo apt dist-upgrade -y
  check_exit_status

  sudo apt install curl software-properties-common apt-transport-https ca-certificates -y

  check_exit_status

}

keys() {

  echo
  echo "Keys"
  echo

  sudo curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
  check_exit_status

  sudo wget -nv https://download.opensuse.org/repositories/shells:fish:release:3/Debian_10/Release.key -O Release.key
  check_exit_status

  sudo apt-key add - < Release.key
  check_exit_status

  sudo rm Release.key
  check_exit_status

}

repo() {

  echo
  echo "Repo"
  echo

  sudo sh -c 'echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list'
  check_exit_status

  echo 'deb http://download.opensuse.org/repositories/shells:/fish:/release:/3/Debian_10/ /' | sudo tee /etc/apt/sources.list.d/shells:fish:release:3.list
  check_exit_status

  sudo apt update
  check_exit_status

}

install_stuff() {

  echo
  echo "Install"
  echo

  sudo apt install fish tree htop screen git qemu-guest-agent gnupg2 docker-ce docker-ce-cli containerd.io libncurses5-dev pkg-config -y
  check_exit_status

  sudo curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
  check_exit_status

  sudo apt update
  check_exit_status

}

user() {

  echo
  echo "User"
  echo

  sudo usermod -aG docker $USER
  check_exit_status

  sudo sed s/required/sufficient/g -i /etc/pam.d/chsh
  check_exit_status

}

boot() {

  echo
  echo "Boot"
  echo

  sudo systemctl enable docker
  check_exit_status

}

ssh() {

  echo
  echo "SSH"
  echo

  sudo cp --preserve /etc/ssh/sshd_config /etc/ssh/sshd_config.$(date +"%Y.%m.%d")
  check_exit_status

  sudo sed -i -r -e '/^#|^$/ d' /etc/ssh/sshd_config
  check_exit_status

}

progress() {

  echo
  echo "progress"
  echo

  git clone https://github.com/Xfennec/progress.git
  check_exit_status

  cd progress
  sudo make && sudo make install
  check_exit_status

}

setup() {

  echo
  echo "setup"
  echo

  echo /usr/bin/fish | sudo tee -a /etc/shells
  check_exit_status

  sudo chsh -s /usr/bin/fish johnny
  check_exit_status

  fish
  check_exit_status

  abbr -a -U -- .list 'apt list --upgradable'
  abbr -a -U -- .pull 'docker-compose pull'
  abbr -a -U -- .stop 'docker stop (docker ps -a -q)'
  abbr -a -U -- .up 'docker-compose up -d'
  abbr -a -U -- .update 'sudo apt update'
  abbr -a -U -- .upgrade 'sudo apt upgrade -y'
  abbr -a -U -- dprune 'docker image prune -a'
  abbr -a -U -- dps 'docker ps -a'
  abbr -a -U -- drm 'docker rm'
  abbr -a -U -- gp 'git pull'
  abbr -a -U -- gP 'git push'
  abbr -a -U -- gPt 'git push --tags'
  abbr -a -U -- gc 'git clone'
  abbr -a -U -- gcom 'git commit -m'
  abbr -a -U -- gp 'git pull'
  abbr -a -U -- l 'ls -lah'
  check_exit_status

}

starship() {
  echo
  echo "starship"
  echo

  sudo apt install fonts-firacode
  check_exit_status

  wget -q --show-progress https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz
  check_exit_status

  tar xvf starship-x86_64-unknown-linux-gnu.tar.gz
  check_exit_status
  
  sudo mv starship /usr/local/bin/
  check_exit_status

  echo "starship init fish | source" | sudo tee ~/.config/fish/config.fish
  check_exit_status
}

leave() {

  echo
  echo "--------------------"
  echo "- Update Complete! -"
  echo "--------------------"
  echo
  exit
}

greeting
update
keys
repo
install_stuff
user
boot
ssh
progress
setup
starship
leave
