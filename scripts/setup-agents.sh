#!/usr/bin/env bash
# Install Claude Code + Codex CLIs untuk mengerjakan repo ini.
set -euo pipefail

if ! command -v node >/dev/null 2>&1; then
  echo "Node.js belum ada. Install Node 18+ dulu (https://nodejs.org), lalu jalankan lagi."
  exit 1
fi
echo "node $(node -v) / npm $(npm -v)"

echo "==> Install Claude Code (perintah: claude)"
npm install -g @anthropic-ai/claude-code

echo "==> Install Codex (perintah: codex)"
npm install -g @openai/codex

echo
echo "Selesai. Cek:"
command -v claude && claude --version || echo "  (claude belum ke-PATH? buka terminal baru)"
command -v codex  && codex --version  || echo "  (codex belum ke-PATH? buka terminal baru)"
echo
echo "Login sekali:"
echo "  claude    # ikuti login Anthropic"
echo "  codex     # login OpenAI / set API key"
echo
echo "Lalu buka repo ini, jalankan 'claude' atau 'codex', dan tempel prompt dari DEPLOY-PROMPT.md"
