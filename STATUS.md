# Status do Repositório (2026-07-08)

Visão geral de uma revisão feita em 2026-07-08. Não é um documento vivo — é um snapshot; conferir o estado atual antes de confiar nele.

## Pendências no working tree

- **`.config/ghostty/config`** tinha mudanças não commitadas que revertiam os keybinds
  adicionados pelos commits `fdd1945` e `9dab3a1` (cmd+arrows, ctrl+shift+p, etc).
  Confirmar se isso foi intencional antes de descartar ou commitar.
- **`.claude/settings.local.json`** ganhou permissões para baixar `zjstatus.wasm` e
  linkar `.config/zellij/layouts/default.kdl`, mas esse arquivo não existe no repo
  (só existe `.config/zellij/config.kdl`) e `load_plugins {}` está vazio — o plugin
  zjstatus nunca é carregado. Parece trabalho de layout/zjstatus inacabado.

## Observações menores (não urgentes)

- `install.zsh:127` faz `source "$ZSHRC_PATH"` no fim do script, mas isso roda num
  subprocesso e não afeta o shell interativo — a mensagem "Configuration applied!"
  é enganosa. Seria melhor instruir o usuário a abrir um novo terminal.
- `uninstall.zsh` usa uma variável local `backup_file` com o mesmo nome da função
  `backup_file()` — funciona (namespaces diferentes em zsh), mas confunde na leitura.
- `SYMLINK_FILES` em `config.zsh` não tem entrada para `zellij/layouts` — se a ideia
  é versionar layouts do zellij, falta adicionar ao array.

## Pontos positivos

- Estrutura modular clara: `config.zsh` centraliza paths, aliases/functions separados.
- `install.zsh`/`uninstall.zsh` fazem backup automático do `.zshrc` antes de mexer,
  com suporte a restore.
- Tratamento correto de Apple Silicon vs Intel para Homebrew.
- `aliases()` (fzf browser) e `bin/compress_screencaps.sh` testados manualmente
  (diretório vazio, diretório inexistente) — comportam-se corretamente.
- Configs de Helix/Zellij/Starship bem comentadas e coerentes com o tema Dracula.
