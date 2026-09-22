# SSH Store Backend + VPS Agent

Kode ini menyediakan dua service Node.js:

- `src/api.js`: backend API yang dipanggil oleh website.
- `src/agent.js`: agent yang berjalan di VPS dan hanya membuka listener lokal (`127.0.0.1`).

API dan agent berkomunikasi dengan HMAC SHA-256 menggunakan header `X-Agent-Timestamp` dan `X-Agent-Signature`. Agent tidak menerima shell command bebas; endpoint hanya menerima operasi terdaftar untuk membuat, memperpanjang, menangguhkan, dan menghapus akun.

## Endpoint backend

- `POST /v1/accounts` dengan `{ "username": "member123", "days": 30 }`
- `POST /v1/accounts/extend` dengan `{ "username": "member123", "days": 30 }`
- `POST /v1/accounts/status` dengan `{ "username": "member123", "status": "suspended" }`
- `DELETE /v1/accounts/:username`
- `GET /health`

## Uji lokal

```bash
cd backend
cp .env.example .env
# Isi AGENT_SHARED_SECRET dengan nilai acak panjang yang sama di API dan agent
node src/agent.js
# terminal kedua
node src/api.js
```

Agent menjalankan `/usr/sbin/useradd`, `/usr/sbin/chpasswd`, `/usr/sbin/usermod`, dan `/usr/sbin/userdel`. Karena operasi ini membutuhkan hak istimewa, jangan menjalankan kode ini langsung di shared hosting. Gunakan VPS khusus dengan user service dan aturan `sudoers` yang sangat terbatas atau gunakan systemd service terpisah.

## Wajib ditambahkan sebelum produksi

1. Autentikasi dan otorisasi member/admin di backend.
2. Database untuk users, wallets, orders, products, servers, ssh_accounts, topups, dan audit logs.
3. Transaksi saldo atomik dan idempotency key pada pembelian.
4. Payment gateway webhook yang diverifikasi tanda tangannya.
5. HTTPS/reverse proxy untuk API publik; agent tetap bind ke localhost/private network.
6. Firewall agar port agent tidak terbuka ke internet.
7. Secret manager/environment variables; jangan commit `.env` atau private key.
8. Rate limit, CSRF jika memakai cookie session, MFA admin, backup, monitoring, dan alert.
9. Kebijakan penggunaan yang melarang DDoS, port scanning, hacking, malware, penipuan, dan akses tanpa izin.
10. Jangan mengembalikan password akun SSH ke log. Simpan detail sensitif hanya jika memang diperlukan dan lindungi database.

Kode ini adalah kerangka provisioning, bukan konfigurasi produksi siap pakai. Uji di VPS staging dengan akun uji sebelum menghubungkan pembayaran dan saldo nyata.

## Monitoring

VPS Agent menyediakan `GET /metrics` yang dilindungi HMAC dan mengembalikan status, hostname, uptime, CPU load, memory usage, load average, serta waktu pemeriksaan. Backend API mem-proxy endpoint tersebut melalui `GET /v1/monitoring/metrics`.

Dashboard admin memperbarui grafik demo setiap 60 detik dan mereset ringkasan pada pukul 00.00 waktu server. Setelah endpoint backend dan daftar server terhubung, data demo harus diganti dengan polling metrics nyata per server; status offline ditentukan ketika request agent timeout/gagal.

## Bind address

Agent default bind ke `127.0.0.1`. Jika API dan agent berbeda host, set `AGENT_BIND_HOST` pada environment agent dan batasi firewall ke IP backend. Jangan expose port agent tanpa allowlist/private network.
