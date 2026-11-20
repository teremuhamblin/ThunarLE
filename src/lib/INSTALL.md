### 🚀 Comment l’utiliser dans tes scripts

1. Créer et tester le fichier :
```bash
mkdir -p src/lib
# (colle le contenu ci-dessus dans src/lib/path.sh)
chmod +x src/lib/path.sh
bash src/lib/path.sh
```

2. Dans n’importe quel script (même à 3 niveaux de profondeur) :
```bash
# Exemple depuis src/ui/tui/menu.sh ou src/opsec/security/opsec-wipe.sh
# shellcheck disable=SC1091
source "$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../../lib/path.sh"

thunar_init_runtime_dirs
thunar_load_conf "overwatch.conf" || true

# Tu as maintenant accès directement à :
# "$THUNAR_LOGS_DIR", "$THUNAR_CERTS_DIR", "$THUNAR_PLUGINS_DIR", "$THUNAR_TUI_DIR", etc.
```

3. Depuis install.sh ou thunar-xfce.sh à la racine :
```bash
source "$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)/src/lib/path.sh"
```

Une fois sourcé dans thunar-xfce.sh, toutes les variables THUNAR_* sont exportées automatiquement vers les sous-scripts lancés.

