# Prompt deploy Hermes Agent ke Handlify (copy-paste ke agent)

Salin blok di bawah sebagai prompt pertama:

---

Deploy Hermes Agent ke Handlify (Qiscus Builder). Ikuti persis, karena ada beberapa jebakan:

1) Buat Dockerfile ini di folder baru:
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

2) Push ke git repo dulu. Handlify build DARI repo, bukan dari file langsung.
   deploy_project TIDAK bisa build Dockerfile (cuma static/node). Pakai GitHub repo
   public, atau Forgejo internal gitlab.qiscus.io.

3) Deploy pakai create_app_from_repo (repo public) atau deploy_private_repo
   (private/Forgejo) dengan: build_pack=dockerfile, ports_exposes=9119, plus
   project_uuid + server_uuid Handlify (list_projects / list_servers).

4) AUTH (wajib, kalau tidak container crash-loop). Hermes menolak bind dashboard ke
   0.0.0.0 tanpa auth provider. Set basic auth lewat env di Handlify secrets dashboard
   (owner isi sendiri via link manage_secrets, tidak lewat chat/repo):
     HERMES_DASHBOARD_BASIC_AUTH_USERNAME=admin
     HERMES_DASHBOARD_BASIC_AUTH_PASSWORD=<password alfanumerik>
     HERMES_DASHBOARD_BASIC_AUTH_SECRET=<random hex 32 byte>   (opsional, biar sesi stabil)
   PENTING: pakai _PASSWORD (plaintext), JANGAN _PASSWORD_HASH. Hash scrypt mengandung
   karakter `$` yang kepotong saat ditempel ke env → login gagal "Invalid username or
   password". Password alfanumerik aman ditempel; hermes hash sendiri di memori.
   Lalu klik Apply & redeploy.

5) Batasi akses URL (gerbang Google SSO Handlify) ke email tim:
   set_access level=team allow="email1@qiscus.com, email2@qiscus.com"

6) Ekspektasi deploy: hermes boot lama (~1-2 menit, sync skill dll). HEALTHCHECK di
   Dockerfile bikin Coolify tunggu container sehat sebelum alihkan traffic, jadi 502
   Bad Gateway minimal/hilang. Kalau sempat 502, tunggu ~1 menit.

7) Verifikasi sukses:
   - URL balas 302 ke SSO Google secara stabil.
   - Log container: `HERMES_DASHBOARD_READY port=9119`.
   - Login: Google (email tim) → form hermes (admin + password).

Catatan: dashboard jalan tanpa login model. Kalau perlu agent-nya benar-benar jalanin
LLM/task, konfigurasi provider model terpisah (hermes model / env API key provider).

---
