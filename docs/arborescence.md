### 🟩 📁 Arborescence
- **ThunarLE**
- *v4.0.0*

```text
ThunarLE/
├── .github/                      # Workflows CI/CD, Issue/PR templates, SECURITY.md
│
├── src/                          # ⚙️ CODE APPLICATIF (regroupé par compatibilité)
│   ├── lib/                      # Utilitaires partagés (résolution de chemins, logging)
│   │   └── paths.sh
│   ├── thunar/                   # 🧩 Couche Thunar & Extensions
│   │   ├── actions/              # scripts/*.sh + *.desktop
│   │   ├── plugins/              # loader.sh, plugins.sh, verify-plugin.sh, custom/
│   │   └── extension/            # (v5.0) Extension native thunarx
│   ├── ui/                       # 🖥️ Couche Interface (X11 / Wayland / XFCE)
│   │   ├── tui/                  # banner.txt, color.sh, menu.sh, PluginManager.sh, SystemCheck.sh
│   │   ├── gui/                  # overwatch-gui.sh, wayland-compat.sh, command-palette.sh
│   │   └── hud/                  # xfce4-panel-genmon.sh
│   ├── opsec/                    # 🛡️ Couche Sécurité & Sandboxing
│   │   ├── security/             # opsec-crypt.sh, opsec-wipe.sh
│   │   └── sandbox/              # bwrap-runner.sh
│   └── engine/                   # 📡 Couche Services & Intelligence
│       ├── daemon/               # overwatch-daemon.sh, thunar-overwatch.service
│       ├── ai/                   # smart-triage.sh
│       └── sync/                 # mesh-sync.sh
│
├── config/                       # ⚙️ Configurations (*.conf)
│   ├── action.conf
│   ├── plugins.conf
│   ├── thunar.conf
│   ├── overwatch.conf
│   └── themes.conf
│
├── var/                          # 📜 Données Runtime (hors code source)
│   └── logs/                     # thunar-xfce.log & certs/
│
├── packaging/                    # 📦 Distribution Debian & APT
│   └── debian/                   # DEBIAN/{control,postinst,postrm}, opt/
│
├── docs/                         # 📚 Documentation & Releases
│   ├── releases/                 # RELEASE_NOTES_v4.0.0.md
│   └── *.md                      # CHANGELOG.md, ROADMAP.md, architecture.md, etc.
│
├── tests/                        # 🧪 Tests automatisés (v5.0 bats-core & CI)
│
├── README.md
├── VERSION.md
├── install.sh
└── thunar-xfce.sh
```
