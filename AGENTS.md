# AGENTS.md — Deploy Hermes Agent ke Handlify

Repo ini untuk men-deploy **Hermes Agent** (Nous Research) ke **Handlify**
(platform deploy internal Qiscus, berbasis Coolify) lewat MCP `qiscus-builder`.
Kamu (agent: Claude Code / Codex) mengeksekusi langkah di bawah. Ada beberapa
jebakan yang WAJIB dihindari — sudah ditandai.

## Tujuan
Container hermes hidup di `https://<id>.handlify.qiscus.io`, dashboard di port 9119,
dijaga basic auth, akses URL dibatasi ke email tim.

## Prasyarat
- MCP `qiscus-builder` tersedia (tools: list_projects, list_servers,
  create_app_from_repo / deploy_private_repo, deploy_app, manage_secrets,
  set_access, get_logs, list_deployments_for_app).
- Dockerfile ada di repo git yang bisa ditarik Coolify (repo INI).

## Dockerfile (sudah ada di repo — jangan diubah tanpa alasan)
```
FROM nousresearch/hermes-agent:latest
ENV HERMES_DASHBOARD=1 \
    HERMES_DASHBOARD_HOST=0.0.0.0 \
    HERMES_DASHBOARD_PORT=9119
EXPOSE 9119
HEALTHCHECK --interval=15s --timeout=5s --start-period=150s --retries=6 \
  CMD curl -fsS -o /dev/null http://127.0.0.1:9119/login || exit 1
CMD ["gateway", "run"]
```
- `CMD ["gateway","run"]` BENAR untuk image ini (entrypoint dispatch-nya menerima
  arg itu; default CMD kosong). Jangan dihapus.
- `HEALTHCHECK` WAJIB: hermes boot ~1-2 menit; ini bikin Coolify tahan container
  lama tetap serve sampai yang baru sehat → hilangkan 502 Bad Gateway saat redeploy.

## Langkah deploy

### 1. Pastikan Dockerfile ada di git repo
Handlify build DARI repo, bukan file upload. `deploy_project` TIDAK bisa build
Dockerfile (cuma static/node). Repo ini sudah berisi Dockerfile — cukup pastikan
sudah ke-push ke remote (GitHub public atau Forgejo internal gitlab.qiscus.io).

### 2. Deploy
- Repo public (GitHub): `create_app_from_repo`
- Repo private / Forgejo: `deploy_private_repo`

Parameter penting (dua-duanya):
- `build_pack = "dockerfile"`
- `ports_exposes = "9119"`
- `git_branch = "main"`
- `project_uuid` + `server_uuid` (ambil dari list_projects / list_servers)

### 3. Auth dashboard  ← JEBAKAN UTAMA
Hermes MENOLAK bind dashboard ke 0.0.0.0 tanpa auth provider → container crash-loop.
Set basic auth lewat ENV. Owner mengisi lewat link dari `manage_secrets(uuid)`
(write-only, out-of-band — JANGAN taruh secret di repo / chat):

```
HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=<password alfanumerik>
HERMES_DASHBOARD_BASIC_AUTH_SECRET=<random hex 32 byte>   # opsional, sesi stabil
```

PENTING: pakai `_PASSWORD` (plaintext), **JANGAN** `_PASSWORD_HASH`.
Hash scrypt mengandung karakter `$` yang kepotong saat ditempel ke env → login
gagal "Invalid username or password". Password alfanumerik aman; hermes hash
sendiri di memori (log: `hashed env-supplied password in-memory`).
Setelah isi env → Apply & redeploy.

### 4. Batasi akses URL (gerbang Google SSO Handlify)
```
set_access(uuid, level="team", allow="email1@qiscus.com, email2@qiscus.com")
```
Level lain: `company` (semua @qiscus.com), `public`, `password`.

### 5. Verifikasi
- `list_deployments_for_app(uuid)` → status finished.
- `get_logs(uuid)` → muncul `HERMES_DASHBOARD_READY port=9119` (bukan
  "Refusing to bind dashboard").
- URL balas HTTP 302 ke SSO Google secara stabil (bukan 502).
- Login: Google (email tim) → form hermes (admin + password).

## Catatan
- Saat redeploy, tunggu ~1 menit; berkat HEALTHCHECK 502 minimal/hilang.
- Dashboard jalan tanpa login model. Kalau perlu agent-nya benar-benar jalanin
  LLM/task, konfigurasi provider model terpisah (`hermes model` / env API key provider).
- Bersihkan bila perlu: `delete_project` / hapus app dari dashboard.
