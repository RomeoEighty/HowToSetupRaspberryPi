# Format SD card
unmount then,
```
 $ sudo diskutil eraseDisk FAT32 RASPBIAN MBRFormat /dev/disk
```
unmount

# Write OS image
```
 $ sudo dd bs=1m if=/Users/RomeoEighty/Downloads/2018-06-27-raspbian-stretch-lite.img of=/dev/rdisk2 conv=sync
```

# setup
```
 $ passwd
 $ sudo sh -c "apt-get update; apt-get -y update; apt-get dist-upgrade"
 $ sudo apt-get -y install git openssh-server zsh
 $ sudo update-alternatives --config editor
```
set vim
```
 $ sudo raspi-config
 $ sudo adduser [new user]
 $ sudo adduser [new user] sudo
 $ exit
```
login as [new user]
```
 $ sudo deluser --remove-home pi
 $ sudoedit /etc/sudoers.d/010_pi-nopasswd
```
comment out

# setup ssh
on client
```
 $ ssh-keygen -t ed25519
 $ scp .ssh/id_Raspi_ed25519.pub [new user]@192.168.2.2:
```
on raspi
```
 $ mkdir .ssh
 $ cat id_Raspi_ed25519.pub >> .ssh/authorized_keys
 $ chmod 700 .ssh
 $ chmod 600 .ssh/authorized_keys
 $ rm -rf id_Raspi_ed25519.pub
```
change port
```
 $ sudoedit /etc/ssh/sshd_config
#Port 22
Port [new port]
===
#PermitRootLogin prohibit-password
PermitRootLogin no
===
```

vim

https://github.com/Valloric/YouCompleteMe/wiki/Building-Vim-from-source
```
$ sudo apt -y remove vim vim-runtime gvim vim-tiny vim-common vim-gui-common vim-nox
$ sudo apt-get -y install \
    lua5.2 liblua5.2-dev \
    libperl-dev \
    python-dev python3-dev \
    ruby-dev \
    build-essential
$ mkdir -p ~/.vim/dein/repos/github.com/Shougo/dein.vim
$ git clone https://github.com/Shougo/dein.vim.git \
    ~/.vim/dein/repos/github.com/Shougo/dein.vim
# pay attention here check directory correct
$ ./configure --with-features=huge \
    --enable-multibyte \
    --enable-rubyinterp=yes \
    --enable-pythoninterp=yes \
    --with-python-config-dir=/usr/lib/python2.7/config \
    --enable-python3interp=yes \
    --with-python3-config-dir=/usr/lib/python3.5/config \
    --enable-perlinterp=yes \
    --enable-luainterp=yes \
    --enable-cscope \
    --prefix=/usr/local
$ sudo make install
$ sudo update-alternatives --install /usr/bin/editor editor /usr/local/bin/vim 1
$ sudo update-alternatives --set editor /usr/local/bin/vim
$ sudo update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 1
$ sudo update-alternatives --set vi /usr/local/bin/vim
```

neovim
```
$ git clone https://github.com/neovim/neovim
$ sudo apt-get -y install ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip
$ cd neovim
$ make -j4 CMAKE_BUILD_TYPE=RelWithDebInfo
$ sudo make install
$ curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
$ sudo apt-get -y install python-dev python3-pip
$ curl -O https://bootstrap.pypa.io/get-pip.py
$ python get-pip.py
$ pip2 install neovim --user
$ pip3 install neovim --user
$ sudo apt-get -y install rubygems
$ git clone git://github.com/sstephenson/rbenv.git .rbenv
$ cd .rbenv
$ mkdir plugins
# make sure eval $(rbenv init) is called in bash_profile
$ cd
$ sudo apt-get install -y libssl-dev libreadline-dev
$ rbenv install -l
$ rbenv install 2.5.1
$ rbenv rehash
$ rbenv global 2.5.1
```

tmux
```
$ mkdir build
$ cd build
$ sudo apt-get -y install libevent-dev libncurses5-dev autoconf automake pkg-config bc
$ git clone https://github.com/tmux/tmux.git
$ cd tmux
$ git checkout [version]
$ sh autogen.sh
$ ./configure $$ make -j4
$ cd ~/build
$ git clone https://github.com/thewtex/tmux-mem-cpu-load.git
$ cd tmux-mem-cpu-load
$ cmake . 
$ make -j4
$ sudo make install
```

# security
```
$ sudo apt-get -y install fail2ban ufw
$ sudo systemctl status fail2ban
# kernel upgrade might be needed
$ sudo rpi-update
$ sudo ufw default deny
$ sudo ufw allow from 192.168.3.0/24
$ sudo ufw allow proto tcp from 192.168.3.0/24 to any port [port]
$ sudo ufw enable
```
if you want to delete some of rules
```
$ sudo ufw status numbered
$ sudo ufw delete [num]
```

ffmpeg
```
```

# TODO
- static IP config
- ffmpeg
