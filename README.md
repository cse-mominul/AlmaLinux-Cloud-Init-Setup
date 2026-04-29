# 🚀 AlmaLinux Cloud-Init Auto-Reset Setup

This repository provides an automated script to reset **cloud-init** data and system identity on every boot specifically for **AlmaLinux (RHEL-based)** systems. It is an essential tool for creating **Golden Images** or VM templates in environments like Proxmox, XCP-ng, or Apache CloudStack.

---

## 🛠️ What This Script Does

The script automates the cleanup process to ensure that every VM cloned from your template starts as a fresh instance:

*   **Clears Cloud-Init Cache**: Removes all previous instance data from `/var/lib/cloud/instance` and `/var/lib/cloud/instances/*`.
*   **Wipes SSH Keys**: Truncates the `authorized_keys` file for the default `almalinux` user to prevent old keys from persisting.
*   **Deep Logs Cleanup**: Runs `cloud-init clean --logs` to ensure no old logs remain in the system.
*   **Systemd Automation**: Sets up a `oneshot` service that triggers this cleanup automatically before the cloud-init local service starts during boot.
*   **SELinux Compatibility**: Automatically adjusts the security context of the script using `restorecon` to ensure it runs without being blocked by SELinux.

---

## 💻 How to Run

You can set up the automation by running this single command in your terminal:
```bash
git clone https://github.com/cse-mominul/AlmaLinux-Cloud-Init-Setup.git
cd AlmaLinux-Cloud-Init-Setup
chmod +x AlmaLinux-Cloud-Init-Auto-Reset.sh
sudo ./AlmaLinux-Cloud-Init-Auto-Reset.sh
sudo systemctl start cloud-init-reset.service
sudo systemctl enable cloud-init-reset.service
systemctl status cloud-init-reset.service
