### 🚀 Création rapide

1. Test dans ton dépôt
```bash
mkdir -p config
# (colle le contenu ci-dessus dans config/theme.confs)
```

2. Puis vérifie le rendu en terminal avec src/lib/path.sh :
```bash
 bash -c '
  source src/lib/path.sh
  thunar_load_conf "theme.confs"
  printf "%b[OK] %s (%s)%b\n" "$THEME_ANSI_PRIMARY" "$THEME_LABEL" "$THEME_HEX_PRIMARY" "$THEME_ANSI_RESET"
  thunar_apply_theme "cyberpunk"
  printf "%b[OK] %s (%s)%b\n" "$THEME_ANSI_PRIMARY" "$THEME_LABEL" "$THEME_HEX_PRIMARY" "$THEME_ANSI_RESET"
```

(Note : si tes scripts utilisent aussi le nom themes.conf mentionné dans le README.md, tu peux créer un lien symbolique ln -sf theme.confs config/themes.conf pour que les deux noms fonctionnent sans duplication.)
  
