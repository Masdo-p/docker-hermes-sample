# Prompt deploy Hermes Agent ke Handlify (copy-paste ke agent)

Default: deploy langsung dari repo public ini — tidak perlu bikin Dockerfile atau
push repo. Salin blok di bawah sebagai prompt pertama ke Claude Code / Codex.

---

Deploy Hermes Agent ke Handlify (Qiscus Builder) dari repo public yang sudah ada.
JANGAN bikin Dockerfile baru atau push repo — Dockerfile-nya sudah ada di repo ini.

Prasyarat: MCP `qiscus-builder` aktif.

GANTI placeholder ini dulu:
- APP_NAME     = hermes-<namamu>        (HARUS unik — jangan "hermes-agent")
- ALLOW_EMAILS = kamu@qiscus.com        (email yang boleh buka URL; bisa >1)

Langkah:

1) Deploy dari repo public ini:
   create_app_from_repo(
     name          = APP_NAME,
     git_repository= "https://github.com/rajapulau/docker-hermes-sample.git",
     git_branch    = "main",
     build_pack    = "dockerfile",
     ports_exposes = "9119",
     project_uuid  = <ambil dari list_projects>,   # project Handlify
     server_uuid   = <ambil dari list_servers>,    # server handlify-node-*
   )
   Simpan `uuid` app dari hasilnya.

2) Auth dashboard — WAJIB (tanpa ini container crash-loop). Panggil
   manage_secrets(uuid) untuk dapat link dashboard, lalu MINTA OWNER isi env
   berikut di sana (agent TIDAK bisa mengisinya sendiri — ini langkah manual):
     HERMES_DASHBOARD_BASIC_AUTH_USERNAME = admin
     HERMES_DASHBOARD_BASIC_AUTH_PASSWORD = <password alfanumerik — generate yang kuat>
     HERMES_DASHBOARD_BASIC_AUTH_SECRET   = <random hex 32 byte>   # opsional, sesi stabil
   PENTING: pakai `_PASSWORD` (plaintext), JANGAN `_PASSWORD_HASH` — hash punya
   karakter `$` yang kepotong saat ditempel ke env → login gagal. Hermes hash
   sendiri di memori. Setelah isi → klik Apply & redeploy.

3) Batasi akses URL (gerbang Google SSO):
   set_access(uuid, level="team", allow=ALLOW_EMAILS)

4) Verifikasi:
   - list_deployments_for_app(uuid) → finished
   - get_logs(uuid) → muncul `HERMES_DASHBOARD_READY port=9119`
   - URL balas HTTP 302 stabil (bukan 502; tunggu ~1 menit habis redeploy)
   - Login: Google (email tim) → form hermes (admin + password)

Catatan:
- Mau ubah Dockerfile? Fork repo ini dulu, lalu arahkan `git_repository` ke fork-mu.
- Dashboard jalan tanpa login model; untuk agent LLM-nya, set provider model terpisah.

---
