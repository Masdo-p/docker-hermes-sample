# docker-hermes-sample

Deploy **Hermes Agent** (Nous Research) ke **Handlify** (Coolify) — dan repo ini
sudah "agent-ready": buka pakai **Claude Code** atau **Codex**, dan agent-nya sudah
tahu cara deploy (playbook di `AGENTS.md`).

## Isi
| File | Fungsi |
|------|--------|
| `Dockerfile` | Image hermes + dashboard di :9119 + HEALTHCHECK |
| `docker-compose.yml` | Build dari Dockerfile + named volume `hermes-data` di `/opt/data` (data tidak hilang saat redeploy) |
| `AGENTS.md` | Playbook deploy — dibaca Codex & Claude Code otomatis |
| `CLAUDE.md` | Pointer ke AGENTS.md untuk Claude Code |
| `DEPLOY-PROMPT.md` | Prompt pertama siap-tempel |
| `scripts/setup-agents.sh` | Install Claude Code + Codex |
| `.devcontainer/` | Buka di Codespaces/devcontainer → agent langsung terpasang |

## Cara pakai

### Opsi A — devcontainer / Codespaces (paling gampang)
Buka repo di VS Code "Reopen in Container" atau GitHub Codespaces. Claude Code +
Codex ke-install otomatis (`postCreateCommand`).

### Opsi B — mesin lokal
```
bash scripts/setup-agents.sh     # install claude + codex
claude                            # login Anthropic (sekali)
# atau
codex                             # login OpenAI / API key (sekali)
```
Install manual kalau mau:
```
npm install -g @anthropic-ai/claude-code   # -> claude
npm install -g @openai/codex               # -> codex
```

### Jalankan deploy
1. Buka folder repo ini, jalankan `claude` atau `codex`.
2. Tempel isi `DEPLOY-PROMPT.md` sebagai prompt pertama.
3. Agent akan: deploy langsung dari repo public ini (build_pack=dockercompose, port
   9119) → arahkan kamu isi env auth di dashboard Handlify → batasi akses → verifikasi.
   Kamu TIDAK perlu bikin/push repo sendiri (kecuali mau ubah Dockerfile → fork dulu).

## Yang WAJIB diingat (ringkas dari AGENTS.md)
1. **Deploy dari repo public ini** — `create_app_from_repo` diarahkan ke URL repo ini
   + `build_pack=dockercompose`, `compose=True`. `deploy_project` tak bisa build Dockerfile. Nama app
   harus unik (jangan "hermes-agent").
2. **Auth pakai `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD` (plaintext)**, JANGAN
   `_PASSWORD_HASH` (karakter `$` kepotong → gagal login).
3. **HEALTHCHECK** di Dockerfile → Coolify tahu kapan hermes siap (redeploy compose tetap sempat 502 ~1-2 menit).
4. Env secret diisi owner via link `manage_secrets` (out-of-band, bukan di repo).
5. **Volume `/opt/data`** (bukan seluruh `/opt`) → config/sesi hermes tidak hilang tiap redeploy.

## Prasyarat akses
MCP `qiscus-builder` (Handlify) aktif. Base image `nousresearch/hermes-agent:latest`
publik di Docker Hub. Dashboard butuh auth (basic auth via env di atas).
