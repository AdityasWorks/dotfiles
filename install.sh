#!/bin/bash

# A script to automate the setup of a new Pop!_OS installation by aadi


# Exit immediately if a command exits with a non-zero status.
set -e


echo "🚀 Starting Pop!_OS setup..."
echo "This script will configure your system. You will be prompted for your password for 'sudo' commands."
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
APT_PACKAGES="git stow zsh alacritty btop cava cmatrix code conky conky-manager2 curl docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin exa fzf gnome-tweaks htop jq mongodb-org neofetch nginx openjdk-17-jdk openjdk-21-jdk pavucontrol pipx ripgrep spotify-client tree ubuntu-cleaner wget zoxide unzip tar dconf-cli"
sudo apt install -y $APT_PACKAGES
echo "✅ APT packages installed."




# --- 2A. INSTALL LOCAL .DEB PACKAGES ---
echo "📦 Installing local .deb packages..."
wget "https://downloads.mongodb.com/compass/mongodb-compass_1.46.7_amd64.deb" -O ~/Downloads/mongodb-compass.deb
sudo apt install -y ~/Downloads/mongodb-compass.deb


# --- 2B. INSTALL FLATPAK APPS ---
echo "📦 Installing Flatpak applications..."
flatpak install flathub -y com.brave.Browser com.discordapp.Discord com.github.IsmaelMartinez.teams_for_linux com.rtosta.zapzap io.httpie.Httpie




# --- 3. SHELL SETUP (ZSH, OH MY ZSH, POWERLEVEL10K) ---
echo "🐚 Setting up Zsh, Oh My Zsh, and Powerlevel10k..."
# Install Oh My Zsh non-interactively
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# Install the Powerlevel10k theme for Oh My Zsh
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
echo "✅ Shell environment ready."




# --- 4. DEVELOPER TOOLCHAIN (NVM & SPICETIFY) ---
echo "🛠️  Setting up developer toolchain..."
# Install NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
# Source nvm to use it in the current script session
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# Install latest LTS Node.js version
nvm install --lts
echo "✅ NVM and Node.js LTS installed."
# Install Spicetify and configure it
curl -fsSL https://raw.githubusercontent.com/spicetify/cli/main/install.sh | sh
sudo chmod a+wr /usr/share/spotify
sudo chmod a+wr /usr/share/spotify/Apps -R
spicetify backup apply
echo "✅ Spicetify installed and applied."




# --- 5. FONTS, THEMES, ICONS, CURSORS, AND WALLPAPER ---
echo "🎨 Installing and applying visual assets..."
# Create directories if they don't exist
mkdir -p ~/.local/share/fonts ~/.themes ~/.icons ~/Pictures/Wallpapers
# Create a temporary directory for downloads
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
# Download and install fonts
echo "🔤 Installing fonts..."
wget https://raw.githubusercontent.com/ryanoasis/nerd-fonts/master/patched-fonts/FiraCode/Regular/FiraCodeNerdFont-Regular.ttf
wget https://raw.githubusercontent.com/JulietaUla/Montserrat/master/fonts/ttf/Montserrat-Regular.ttf
wget https://raw.githubusercontent.com/coreyhu/Urbanist/main/fonts/ttf/Urbanist-Regular.ttf
wget https://raw.githubusercontent.com/JetBrains/JetBrainsMono/master/fonts/ttf/JetBrainsMono-Regular.ttf
wget https://font.download/dl/font/eb-garamond-2.zip
wget https://github.com/rsms/inter/releases/download/v4.1/Inter-4.1.zip
unzip eb-garamond-2.zip
unzip Inter-4.1.zip
mv *.ttf ~/.local/share/fonts/
mv EB\ Garamond/*.ttf ~/.local/share/fonts/
mv Inter/Inter-Desktop/*.ttf ~/.local/share/fonts/
fc-cache -f
echo "✅ Fonts installed."



# Download and install GTK, Icon, and Cursor Themes
echo "🎨 Installing themes..."
wget https://github.com/EliverLara/Nordic/releases/download/v2.2.0/Nordic-darker-v40.tar.xz
wget https://github.com/vinceliuice/Tela-icon-theme/archive/refs/tags/2025-02-10.tar.gz -O Tela.tar.gz
wget https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Original-Ice.tar.xz
tar -xf Nordic-darker-v40.tar.xz
tar -xf Tela.tar.gz
tar -xf Bibata-Original-Ice.tar.xz
mv Nordic-darker-v40 ~/.themes/
./Tela-icon-theme-*/install.sh -a # Use the theme's own install script
mv Bibata-Original-Ice ~/.icons/
echo "✅ Themes installed."


# Clean up temporary directory
cd ~
rm -rf "$TEMP_DIR"

# Apply Themes and Wallpaper
echo "🎨 Applying themes and setting wallpaper..."
gsettings set org.gnome.desktop.interface gtk-theme 'Nordic-darker-v40'
gsettings set org.gnome.desktop.interface icon-theme 'Tela-dark'
gsettings set org.gnome.desktop.interface cursor-theme 'Bibata-Original-Ice'

WALLPAPER_PATH="$HOME/dotfiles/wallpapers/wallpaper.jpg" 
if [ -f "$WALLPAPER_PATH" ]; then
    cp "$WALLPAPER_PATH" ~/Pictures/Wallpapers/
    WALLPAPER_FILENAME=$(basename "$WALLPAPER_PATH")
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Pictures/Wallpapers/$WALLPAPER_FILENAME"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Pictures/Wallpapers/$WALLPAPER_FILENAME"
    echo "✅ Wallpaper set."
else
    echo "⚠️ Wallpaper not found at $WALLPAPER_PATH. Please add it to your dotfiles repo and update the script."
fi

# --- 6. VS CODE SETUP ---
echo "💻 Setting up Visual Studio Code..."
VSCODE_EXTENSIONS="be5invis.vscode-custom-css beigeowl.wrapped-owl brandonkirbyson.vscode-animations dbaeumer.vscode-eslint eamodio.gitlens esbenp.prettier-vscode github.copilot github.copilot-chat miguelsolorio.fluent-icons ms-azuretools.vscode-containers ms-azuretools.vscode-docker ms-python.debugpy ms-python.python ms-python.vscode-pylance ms-python.vscode-python-envs ms-vscode-remote.remote-containers postman.postman-for-vscode redhat.java tal7aouy.icons teabyii.ayu tomrijndorp.find-it-faster visualstudioexptteam.intellicode-api-usage-examples visualstudioexptteam.vscodeintellicode vscjava.vscode-gradle vscjava.vscode-java-debug vscjava.vscode-java-dependency vscjava.vscode-java-pack vscjava.vscode-java-test vscjava.vscode-maven vscjava.vscode-spring-initializr vscode-icons-team.vscode-icons william-voyek.vscode-nginx"
for extension in $VSCODE_EXTENSIONS; do
    echo "Installing VS Code extension: $extension"
    code --install-extension "$extension" --force
done
echo "✅ VS Code extensions installed."

# --- 7. GNOME EXTENSION MANAGEMENT ---
echo "🧩 Installing and enabling GNOME extensions..."

pipx install gnome-extensions-cli --system-site-packages
GNOME_EXTENSIONS="blur-my-shell@aunetx clipboard-indicator@tudmotu.com hidetopbar@mathieu.bidon.ca logomenu@aryan_k openbar@neuromorph Rounded_Corners@lennart-k rounded-window-corners@yilozt user-theme@gnome-shell-extensions.gcampax.github.com"
for extension in $GNOME_EXTENSIONS; do
    echo "Installing GNOME extension: $extension"
    gnome-extensions-cli install "$extension" || true # Use '|| true' to continue even if one fails
done

for extension in $GNOME_EXTENSIONS; do
    echo "Enabling GNOME extension: $extension"
    gnome-extensions-cli enable "$extension" || true
done
echo "✅ GNOME extensions installed and enabled."

# --- 8. RESTORE DOTFILES AND SETTINGS ---
echo "🔗 Restoring all configurations..."
# Restore extension settings from backup file
DCONF_FILE="$HOME/dotfiles/gnome-extensions-settings.dconf"
if [ -f "$DCONF_FILE" ]; then
    dconf load /org/gnome/shell/extensions/ < "$DCONF_FILE"
    echo "✅ GNOME extension settings restored."
fi
# Restore all other application settings via stow
cd "$HOME/dotfiles"
stow */
echo "✅ Dotfiles configuration restored."

# --- 9. FINAL STEPS ---
echo "✅ Setup complete! Changing default shell to Zsh..."
chsh -s $(which zsh)
sudo usermod -aG docker $USER
echo "🎉 All done! Please LOG OUT and LOG BACK IN for all changes to take effect."


