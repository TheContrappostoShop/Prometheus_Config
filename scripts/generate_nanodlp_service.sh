echo """
[Unit]
Description=nanodlp service
Requires=klipper.service

[Service]
Type=simple
ExecStart=${INSTALL_DIR}/nanodlp/run.sh
RemainAfterExit=yes
WorkingDirectory=${INSTALL_DIR}/nanodlp
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
""" >> /etc/system/systemd/nanodlp.service