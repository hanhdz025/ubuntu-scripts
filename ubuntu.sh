installed() {
  return $(dpkg-query -W -f '${Status}\n' "${1}" 2>&1|awk '/ok installed/{print 0;exit}{print 1}')
}

# first install
sudo apt install -y curl git

# install tools
sudo apt install -y terminator flameshot

# install docker
if ! [[ $(which docker) && $(docker --version) ]]; then
  sudo apt update
  sudo apt install apt-transport-https ca-certificates curl software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
  apt-cache policy docker-ce
  sudo apt install docker-ce
  #sudo systemctl status docker
  sudo usermod -aG docker ${USER}
fi

# install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
source ~/.zshrc
nvm install --lts && node -v
npm install --global yarn && yarn -v

# install git-desktop
if ! installed github-desktop; then
  wget -qO - https://mirror.mwt.me/ghd/gpgkey | sudo tee /etc/apt/trusted.gpg.d/shiftkey-desktop.asc > /dev/null
  sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/shiftkey/desktop/any/ any main" > /etc/apt/sources.list.d/packagecloud-shiftkey-desktop.list'
  sudo apt update && sudo apt install github-desktop
fi

# install ibus-bamboo
if ! installed ibus-bamboo; then
  sudo add-apt-repository ppa:bamboo-engine/ibus-bamboo
  sudo apt-get update
  sudo apt-get install ibus ibus-bamboo --install-recommends
  ibus restart
  # Đặt ibus-bamboo làm bộ gõ mặc định
  env DCONF_PROFILE=ibus dconf write /desktop/ibus/general/preload-engines "['BambooUs', 'Bamboo']" && gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'Bamboo')]"
fi

# install some images
docker run -d --name mariadb -p 3306:3306 -e MARIADB_ROOT_PASSWORD=root mariadb
docker run -d --name redis -p 6379:6379 redis

# install zsh
sudo apt install zsh
# ohmyzsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
# add zsh-autosuggestions zsh-syntax-highlighting
