echo """
[Unit]
Description=nanodlp service
Requires=klipper.service

[Service]
Type=simple
ExecStart=$1/nanodlp/run.sh
RemainAfterExit=yes
WorkingDirectory=$1/nanodlp
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
""" >> /etc/system/systemd/nanodlp.service
