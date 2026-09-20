# docker-hermes-sample

Deploy **Hermes Agent** (Nous Research) ke **Handlify** (Coolify) — dan repo ini
sudah "agent-ready": buka pakai **Claude Code** atau **Codex**, dan agent-nya sudah
tahu cara deploy (playbook di `AGENTS.md`).

## Isi
| File | Fungsi |
|------|--------|
| `Dockerfile` | Image hermes + dashboard di :9119 + HEALTHCHECK (cegah 502 saat redeploy) |
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
3. Agent akan: push repo → deploy (build_pack=dockerfile, port 9119) → arahkan kamu
   isi env auth di dashboard Handlify → batasi akses → verifikasi.

## Yang WAJIB diingat (ringkas dari AGENTS.md)
1. **Harus lewat git repo** — `deploy_project` tak bisa build Dockerfile; pakai
   `create_app_from_repo` / `deploy_private_repo` + `build_pack=dockerfile`.
2. **Auth pakai `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD` (plaintext)**, JANGAN
   `_PASSWORD_HASH` (karakter `$` kepotong → gagal login).
3. **HEALTHCHECK** di Dockerfile → hilangkan 502 Bad Gateway tiap deploy.
4. Env secret diisi owner via link `manage_secrets` (out-of-band, bukan di repo).

## Prasyarat akses
MCP `qiscus-builder` (Handlify) aktif. Base image `nousresearch/hermes-agent:latest`
publik di Docker Hub. Dashboard butuh auth (basic auth via env di atas).
