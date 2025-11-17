log "Installing ClamAV"
install_pkgs clamav

log "Updating virus database"
sudo freshclam

log "Ensuring required clamd.conf options"
CLAMD_CONF="/etc/clamav/clamd.conf"
append_config "LogTime yes" "$CLAMD_CONF"
append_config "ExtendedDetectionInfo yes" "$CLAMD_CONF"
append_config "User clamav" "$CLAMD_CONF"
append_config "MaxDirectoryRecursion 20" "$CLAMD_CONF"
append_config "DetectPUA yes" "$CLAMD_CONF"
append_config "HeuristicAlerts yes" "$CLAMD_CONF"
append_config "ScanPE yes" "$CLAMD_CONF"
append_config "ScanELF yes" "$CLAMD_CONF"
append_config "ScanOLE2 yes" "$CLAMD_CONF"
append_config "ScanPDF yes" "$CLAMD_CONF"
append_config "ScanSWF yes" "$CLAMD_CONF"
append_config "ScanXMLDOCS yes" "$CLAMD_CONF"
append_config "ScanHWP3 yes" "$CLAMD_CONF"
append_config "ScanOneNote yes" "$CLAMD_CONF"
append_config "ScanMail yes" "$CLAMD_CONF"
append_config "ScanHTML yes" "$CLAMD_CONF"
append_config "ScanArchive yes" "$CLAMD_CONF"
append_config "Bytecode yes" "$CLAMD_CONF"
append_config "OnAccessExcludeUname clamav" "$CLAMD_CONF"
append_config "OnAccessMountPath /" "$CLAMD_CONF"
append_config "OnAccessPrevention no" "$CLAMD_CONF"
append_config "OnAccessExtraScanning yes" "$CLAMD_CONF"
append_config "VirusEvent /etc/clamav/virus-event.bash" "$CLAMD_CONF"

log "Creating virus-event.bash"
sudo tee /etc/clamav/virus-event.bash > /dev/null <<'EOF'
#!/bin/bash
PATH=/usr/bin
ALERT="Signature detected by clamav: $CLAM_VIRUSEVENT_VIRUSNAME in $CLAM_VIRUSEVENT_FILENAME"
for ADDRESS in /run/user/*; do
    USERID=${ADDRESS#/run/user/}
    /usr/bin/sudo -u "#$USERID" DBUS_SESSION_BUS_ADDRESS="unix:path=$ADDRESS/bus" PATH=${PATH} \
        /usr/bin/notify-send -u critical -i dialog-warning "Virus found!" "$ALERT"
done
EOF
sudo chmod +x /etc/clamav/virus-event.bash

log "Configuring sudoers for clamav notifications"
append_config "clamav ALL = (ALL) NOPASSWD: SETENV: /usr/bin/notify-send" "/etc/sudoers.d/clamav"

log "Configuring clamonacc systemd override"
sudo mkdir -p /etc/systemd/system/clamav-clamonacc.service.d
sudo tee /etc/systemd/system/clamav-clamonacc.service.d/override.conf >/dev/null <<EOF
[Service]
ExecStart=
ExecStart=/usr/sbin/clamonacc -F --fdpass --log=/var/log/clamav/clamonacc.log
EOF

log "Enabling and starting ClamAV services"
enable_services clamav-daemon clamav-clamonacc

log "ClamAV setup complete."
