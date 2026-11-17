#!/bin/bash

# ============================================================
#       INCUS / LXD / LXC VPS BOT V8 INSTALLER
#                    MADE BY EVILSAAD
# ============================================================

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${CYAN}"
cat << "EOF"

███████╗██╗   ██╗██╗██╗     ███████╗ █████╗  █████╗ ██████╗
██╔════╝██║   ██║██║██║     ██╔════╝██╔══██╗██╔══██╗██╔══██╗
█████╗  ██║   ██║██║██║     ███████╗███████║███████║██║  ██║
██╔══╝  ╚██╗ ██╔╝██║██║     ╚════██║██╔══██║██╔══██║██║  ██║
███████╗ ╚████╔╝ ██║███████╗███████║██║  ██║██║  ██║██████╔╝
╚══════╝  ╚═══╝  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝

          VPS HOSTING BOT V8 INSTALLER

             INCUS | LXD | LXC SUPPORTED

                  MADE BY EVILSAAD

EOF
echo -e "${NC}"

echo -e "${PURPLE}============================================${NC}"
echo -e "${GREEN}       VPS BOT AUTOMATIC INSTALLER${NC}"
echo -e "${PURPLE}============================================${NC}"

# ROOT CHECK
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run this installer as root!${NC}"
    exit 1
fi

# UPDATE SYSTEM
echo -e "${YELLOW}[1/7] Updating system...${NC}"
apt update && apt upgrade -y || exit 1

# INSTALL PYTHON AND GIT
echo -e "${YELLOW}[2/7] Installing Python and Git...${NC}"
apt install -y python3 python3-pip python3-venv git nano curl || exit 1

# INSTALL PYTHON ENVIRONMENT
echo -e "${YELLOW}[3/7] Installing Python dependencies...${NC}"

mkdir -p /root/test
cd /root/test || exit 1

python3 -m venv /root/test/venv || exit 1
/root/test/venv/bin/pip install --upgrade pip || exit 1
/root/test/venv/bin/pip install discord.py python-dotenv PyNaCl davey || exit 1

# CHOOSE CONTAINER ENGINE
echo -e "${YELLOW}[4/7] Select container engine...${NC}"
echo -e "${CYAN}"
echo "1. Incus"
echo "2. LXD (Snap)"
echo "3. Skip"
echo -e "${NC}"

read -rp "Enter choice [1-3]: " ENGINE

case "$ENGINE" in
    1)
        echo -e "${YELLOW}Installing Incus...${NC}"
        apt install -y incus || exit 1
        systemctl enable --now incus
        ;;
    2)
        echo -e "${YELLOW}Installing LXD...${NC}"
        apt install -y snapd || exit 1
        snap install lxd || exit 1
        echo -e "${YELLOW}Run 'lxd init' to configure LXD storage and networking.${NC}"
        ;;
    3)
        echo "Skipping container engine."
        ;;
    *)
        echo -e "${RED}Invalid choice.${NC}"
        exit 1
        ;;
esac

# BOT FILE CHECK
echo -e "${YELLOW}[5/7] Checking bot files...${NC}"

if [ ! -f /root/test/bot.py ]; then
    echo -e "${RED}bot.py not found in /root/test/${NC}"
    echo "Upload your bot.py to /root/test/ and run this installer again."
    exit 1
fi

# ENV FILE
echo -e "${YELLOW}[6/7] Configuring .env...${NC}"

if [ ! -f /root/test/.env ]; then
    touch /root/test/.env
    echo -e "${YELLOW}Edit /root/test/.env now. Add your bot configuration.${NC}"
    nano /root/test/.env
fi

# SYSTEMD SERVICE
echo -e "${YELLOW}[7/7] Creating systemd service...${NC}"

cat > /etc/systemd/system/bot.service <<'EOF'
[Unit]
Description=EVILSAAD VPS Discord Bot V8
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/test
ExecStart=/root/test/venv/bin/python /root/test/bot.py
Restart=always
RestartSec=5
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
EOF

# ENABLE BOT
systemctl daemon-reload
systemctl enable bot
systemctl restart bot

echo -e "${GREEN}"
echo "============================================"
echo "       INSTALLATION COMPLETED!"
echo "============================================"
echo -e "${NC}"

echo -e "${CYAN}Bot Commands:${NC}"
echo "Start   : systemctl start bot"
echo "Stop    : systemctl stop bot"
echo "Restart : systemctl restart bot"
echo "Status  : systemctl status bot"
echo "Logs    : journalctl -u bot -f"

echo ""
echo -e "${GREEN}MADE BY EVILSAAD${NC}"
