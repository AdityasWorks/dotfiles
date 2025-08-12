#!/bin/bash

# A script to automate the setup of a new Pop!_OS installation by aadi

# Exit command
set -e

echo "🚀 Starting Pop!_OS setup..."
sleep 4



# --- 1A. ADD PPAS & CUSTOM REPOSITORIES ---

echo "⚙️  Adding third-party repositories and PPAs..."

sudo add-apt-repository ppa:aslatter/ppa -y
sudo add-apt-repository ppa:teejee2008/foss -y
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-8.0.gpg
echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null



# --- 1B. SYSTEM UPDATES AND CORE APT PACKAGES ---
echo "⚙️  Updating system and installing core packages via APT..."
sudo apt-get update && sudo apt-get upgrade -y
APT_PACKAGES="git 
	stow 
	zsh 
	alacritty 
	btop 
	cava 
	cmatrix 
	code 
	conky 
	conky-manager2 
	curl 
	docker-ce 
	docker-ce-cli 
	containerd.io 
	docker-buildx-plugin 
	docker-compose-plugin 
	exa 
	fzf 
	gnome-tweaks 
	htop 
	jq 
	mongodb-org 
	neofetch 
	nginx 
	openjdk-17-jdk 
	openjdk-21-jdk 
	pavucontrol 
	ripgrep 
	spotify-client 
	tree 
	ubuntu-cleaner 
	wget 
	zoxide 
	unzip"
sudo apt install -y $APT_PACKAGES
echo "✅ APT packages installed."






# --- 2A. INSTALL LOCAL .DEB PACKAGES ---
echo "📦 Installing local .deb packages..."
wget "https://downloads.mongodb.com/compass/mongodb-compass_1.46.7_amd64.deb" -O ~/Downloads/mongodb-compass.deb
sudo apt install -y ~/Downloads/mongodb-compass.deb


# --- 2B. INSTALL FLATPAK APPS ---
echo "📦 Installing Flatpak applications..."
flatpak install flathub -y com.brave.Browser com.discordapp.Discord com.github.IsmaelMartinez.teams_for_linux com.rtosta.zapzap io.httpie.Httpie







# --- 3. FONTS AND THEMES ---
echo "🔤 Installing custom fonts..."
FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

# Create a temporary directory for downloads
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download and install fonts
wget https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
wget https://raw.githubusercontent.com/JulietaUla/Montserrat/master/fonts/ttf/Montserrat-Regular.ttf
wget https://raw.githubusercontent.com/coreyhu/Urbanist/main/fonts/ttf/Urbanist-Regular.ttf
wget https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/fonts/ttf/JetBrainsMono-Regular.ttf
wget https://font.download/dl/font/eb-garamond-2.zip
wget https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip

unzip eb-garamond-2.zip
unzip Inter-4.1.zip

# Move all .ttf files to the fonts directory
mv *.ttf "$FONT_DIR/"
mv EB\ Garamond/*.ttf "$FONT_DIR/"
mv Inter/Inter-Desktop/*.ttf "$FONT_DIR/"

# Clean up temporary directory
cd ~
rm -rf "$TEMP_DIR"

# Refresh the font cache
echo "🔄 Refreshing font cache..."
fc-cache -f
echo "✅ Fonts installed."







# --- 4. VS CODE SETUP ---
echo "💻 Setting up Visual Studio Code..."
# List of extensions to install
VSCODE_EXTENSIONS="
    be5invis.vscode-custom-css
    beigeowl.wrapped-owl
    brandonkirbyson.vscode-animations
    dbaeumer.vscode-eslint
    eamodio.gitlens
    esbenp.prettier-vscode
    github.copilot
    github.copilot-chat
    miguelsolorio.fluent-icons
    ms-azuretools.vscode-containers
    ms-azuretools.vscode-docker
    ms-python.debugpy
    ms-python.python
    ms-python.vscode-pylance
    ms-python.vscode-python-envs
    ms-vscode-remote.remote-containers
    postman.postman-for-vscode
    redhat.java
    tal7aouy.icons
    teabyii.ayu
    tomrijndorp.find-it-faster
    visualstudioexptteam.intellicode-api-usage-examples
    visualstudioexptteam.vscodeintellicode
    vscjava.vscode-gradle
    vscjava.vscode-java-debug
    vscjava.vscode-java-dependency
    vscjava.vscode-java-pack
    vscjava.vscode-java-test
    vscjava.vscode-maven
    vscjava.vscode-spring-initializr
    vscode-icons-team.vscode-icons
    william-voyek.vscode-nginx
"
# Loop through the list and install each extension
for extension in $VSCODE_EXTENSIONS; do
    code --install-extension "$extension"
done
echo "✅ VS Code extensions installed."


# --- 5. RESTORE DOTFILES ---
echo "🔗 Restoring dotfiles configuration..."
stow */


# --- 6. FINAL STEPS ---
echo "✅ Setup complete! Changing default shell to Zsh..."
chsh -s $(which zsh)
sudo usermod -aG docker $USER
echo "🎉 All done! Please LOG OUT and LOG BACK IN for all changes (like shell and Docker permissions) to take effect."
