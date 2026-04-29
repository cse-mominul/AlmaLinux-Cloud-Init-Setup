#!/bin/bash

# Title: AlmaLinux Cloud-Init Auto-Reset Setup
# Description: Automates cloud-init reset for AlmaLinux (RHEL-based) systems

echo "----------------------------------------------------"
echo "   AlmaLinux Cloud-Init Auto-Reset Setup Starting   "
echo "----------------------------------------------------"

# --- STEP 1: Create the Reset Script ---
echo "[>] Creating reset script in /usr/local/bin/..."
cat << 'EOF' | sudo tee /usr/local/bin/reset-cloud-init.sh > /dev/null
#!/bin/bash
# Remove Cloud-Init cached data
rm -rf /var/lib/cloud/instance
rm -rf /var/lib/cloud/instances/*

# Clear SSH keys for the AlmaLinux user
# Note: Path is specific to AlmaLinux default user
if [ -f /home/almalinux/.ssh/authorized_keys ]; then
    truncate -s 0 /home/almalinux/.ssh/authorized_keys
fi

# Deep clean cloud-init
cloud-init clean --logs
EOF

# Apply Permissions
sudo chmod +x /usr/local/bin/reset-cloud-init.sh
echo "[✔] Reset script created and permissions set."

# --- STEP 2: Create the Systemd Unit ---
echo "[>] Configuring systemd service..."
cat << 'EOF' | sudo tee /etc/systemd/system/cloud-init-reset.service > /dev/null
[Unit]
Description=Reset Cloud-Init on AlmaLinux Boot
Before=cloud-init-local.service
DefaultDependencies=no

[Service]
Type=oneshot
ExecStart=/usr/local/bin/reset-cloud-init.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# --- STEP 3: Enable Automation ---
sudo systemctl daemon-reload
sudo systemctl enable cloud-init-reset.service
echo "[✔] Systemd service enabled."

# --- STEP 4: SELinux Adjustment ---
# RHEL systems like AlmaLinux need SELinux context adjustment
if command -v restorecon > /dev/null; then
    sudo restorecon -v /usr/local/bin/reset-cloud-init.sh
    echo "[✔] SELinux context updated."
fi

echo "----------------------------------------------------"
echo "Setup Complete! AlmaLinux Golden Image is ready."
echo "----------------------------------------------------"
