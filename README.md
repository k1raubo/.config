# AwesomeWM
My dotfiles for Linux and some tools.

## 1. Installation

### 1.1. Packages

#### Debian
```bash
sudo apt update
sudo apt install rofi picom awesome firefox-esr git nodejs npm alacritty tmux zsh curl ksnip
```

#### Arch
```bash
sudo pacman -Syu rofi picom awesome firefox git nodejs npm alacritty tmux zsh curl ksnip
```

### 1.2. Oh-my-zsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

mkdir -p ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autocomplete
```

### 1.3. UV
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 1.4. Neovim
```bash
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz

sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz

rm nvim-linux-x86_64.tar.gz

sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
```

### 1.5. Fonts

#### Debian
```bash
sudo apt update
sudo apt install -y fonts-montserrat xz-utils

mkdir -p ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar -xf JetBrainsMono.tar.xz -C ~/.local/share/fonts/
rm JetBrainsMono.tar.xz

fc-cache -fv
```

#### Arch
```bash
sudo pacman -S ttf-montserrat ttf-jetbrains-mono-nerd
fc-cache -fv
```

### 1.6 Config
```bash
chmod +x
./install.sh

source ~/.zshrc
```

