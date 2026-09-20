# CLAUDE.md

Instruksi lengkap untuk agent ada di **`AGENTS.md`** di root repo ini — baca file itu
dulu sebelum melakukan apa pun. Isinya playbook deploy Hermes Agent ke Handlify,
termasuk jebakan yang harus dihindari:
- deploy default LANGSUNG dari repo public ini (tidak perlu bikin/push repo),
- auth pakai `HERMES_DASHBOARD_BASIC_AUTH_PASSWORD` (plaintext), BUKAN `_PASSWORD_HASH`,
- `HEALTHCHECK` di Dockerfile untuk cegah 502 saat redeploy,
- nama app harus unik (jangan "hermes-agent").

Prompt siap-pakai ada di `DEPLOY-PROMPT.md`.
