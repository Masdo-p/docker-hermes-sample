# Prompt deploy Hermes Agent ke Handlify (copy-paste ke agent)

Default: deploy langsung dari repo public ini — tidak perlu bikin Dockerfile atau
push repo. Salin blok di bawah sebagai prompt pertama ke Claude Code / Codex.

---

Deploy Hermes Agent ke Handlify (Qiscus Builder) dari repo public yang sudah ada.
JANGAN bikin Dockerfile baru atau push repo — Dockerfile-nya sudah ada di repo ini.

Prasyarat: MCP `handlify` aktif.

Deploy Hermes Agent ke Handlify. Ikuti persis:

0) install claude code dan codex di container

1) APP_NAME = hermes- (HARUS unik — jangan "hermes-agent")

2) Deploy dari repo public ini: create_app_from_repo( name = APP_NAME, git_repository= "https://github.com/rajapulau/docker-hermes-sample.git", git_branch = "main", build_pack = "dockerfile", ports_exposes = "9119", project_uuid = , # project Handlify server_uuid = , # server handlify-node-* ) Simpan uuid app dari hasilnya.

3) Deploy pakai create_app_from_repo (public) / deploy_private_repo (private) dengan build_pack=dockerfile, ports_exposes=9119, plus project_uuid + server_uuid.

4) Set basic auth via Handlify secrets dashboard (owner isi sendiri):
   HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
   HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=<password alfanumerik>   ← plaintext, JANGAN _PASSWORD_HASH (karakter $ kepotong)
   HERMES_DASHBOARD_BASIC_AUTH_SECRET=<random hex 32 byte>       (opsional)
   Lalu Apply & redeploy.

5) Batasi akses: set_access level=team allow="ganjar@qiscus.com".

6) Verifikasi: URL balas 302 stabil, log ada HERMES_DASHBOARD_READY port=9119, login Google → admin+password.

Tiga hal yang paling menentukan sukses/gagalnya (yang tadi bikin kita muter):
1. Harus lewat git repo — deploy_project nggak bisa build Dockerfile, jadi wajib create_app_from_repo/deploy_private_repo + build_pack=dockerfile.
2. Auth pakai _PASSWORD plaintext, bukan _PASSWORD_HASH — ini yang bikin "Invalid username or password" kemarin.
3. HEALTHCHECK di Dockerfile — ini yang menghilangkan 502 tiap deploy.

---
