# SSH Store
Prototype landing page untuk toko akun SSH dengan gaya visual gelap-modern, katalog produk, login member, saldo, top up gateway/manual, dan pilihan server.

## Auto-install website

Repository ini menyediakan `install.sh` untuk memasang website publik, backend API, service systemd, dan Nginx pada Ubuntu/Debian. Script ini berbeda dari installer VPS Agent pada repository `ssh-store-vps-agent-installer`.

```bash
git clone https://github.com/usnulnifah-web/ssh-store-website.git
cd ssh-store
sudo DOMAIN=www.domain-anda.com bash install.sh
```

Jika VPS Agent berada pada mesin lain, isi URL dan secret HMAC yang sama:

```bash
sudo DOMAIN=www.domain-anda.com \
  AGENT_URL=http://10.0.0.20:8787 \
  AGENT_SHARED_SECRET='secret-HMAC-yang-sama' \
  bash install.sh
```

Setelah instalasi, website dibuka melalui `http://www.domain-anda.com` dan panel admin melalui `http://www.domain-anda.com/admin`. DNS domain harus diarahkan ke IP server website. HTTPS/SSL dapat dipasang setelah DNS aktif dengan Certbot. Installer ini menyiapkan deployment prototype; autentikasi produksi, database, saldo atomik, dan payment gateway tetap harus diaktifkan sebelum menerima transaksi nyata.

## Status

Versi ini adalah **frontend prototype**. Interaksi login, top up, dan pembelian masih menggunakan simulasi browser/localStorage. Belum ada kredensial server, payment gateway, database, atau provisioning akun SSH yang aktif.

## Fitur prototype

- Landing page responsif bergaya SSH/VPN store.
- Tombol Login Member.
- Katalog paket SSH 7, 30, dan 90 hari.
- Daftar lokasi server dan status.
- Simulasi saldo member.
- Modal top up untuk gateway atau manual.
- Simulasi pembelian dengan saldo.
- FAQ dan alur tiga langkah.

## Menjalankan lokal

Buka `index.html` langsung di browser atau jalankan server statis:

```bash
python3 -m http.server 8080
```

## Roadmap produksi

1. Backend autentikasi member dan admin.
2. Database users, wallets, wallet_transactions, products, servers, orders, ssh_accounts, topups, dan audit_logs.
3. Payment gateway dengan webhook idempotent.
4. Top up manual dengan unggah bukti dan verifikasi admin.
5. Provisioning akun SSH melalui API/provider atau server terkelola.
6. Dashboard member berisi saldo, pembelian, akun aktif, dan detail konfigurasi.
7. Panel admin untuk produk, server, member, transaksi, saldo, tombol publik, dan log audit.
8. Keamanan: CSRF, rate limit, 2FA admin, secret management, backup, dan validasi transaksi atomik.

## Catatan keamanan

Jangan memasukkan API key payment gateway, password server, private key, atau kredensial admin ke repository. Gunakan environment variables dan secret manager.

## Detail akun setelah berhasil dibuat

Prototype sekarang menampilkan notifikasi sukses berisi username, password, host, port, lokasi, masa aktif, tanggal kedaluwarsa, dan status secara lengkap tanpa sensor. Tersedia tombol **Unduh Detail .TXT**. Pada implementasi produksi, data ini wajib hanya dikirim ke member yang sudah login dan berwenang; jangan pernah menaruhnya di halaman publik, URL, log server, atau repository.

## Notifikasi akun dan informasi member

Setelah pembelian/provisioning berhasil, UI menampilkan notifikasi mengambang di kanan bawah. Notifikasi dapat diklik untuk membuka detail lengkap dan memiliki tombol **X** untuk menutup. Detail akun disimpan ke daftar **Akun Saya** pada prototype dan dapat dibuka kembali atau diunduh sebagai TXT. Untuk produksi, daftar ini harus dipindahkan dari localStorage ke database yang terikat pada `user_id`, dengan otorisasi server-side sehingga member tidak dapat melihat akun milik member lain.

## Dashboard admin dan SEO

`admin.html` menyediakan prototype dashboard admin dengan tampilan minimal. Dashboard utama sengaja kosong, sedangkan seluruh menu dipindahkan ke drawer hamburger: SEO Website, Produk & Harga, Server & Protocol, Member, Saldo & Top Up, Pesanan, Tombol Publik, dan Pengaturan Sistem.

Panel SEO menyediakan SEO title, meta description, keywords, canonical URL, Open Graph image, robots, serta preview hasil pencarian. Prototype menyimpan pengaturan di localStorage; versi produksi harus menyimpannya di backend/database lalu layout publik membaca nilai tersebut secara server-side.

## Konfigurasi VPS di panel admin

Panel **Server & Protocol** sekarang menyediakan konfigurasi VPS: nama server, IP VPS wajib, port SSH wajib, username SSH wajib, domain publik opsional, protocol yang tersedia, serta pilihan autentikasi **Password** atau **SSH Key**. Jika memilih password, field password tampil; jika memilih SSH key, field private key tampil. Pada prototype data tersimpan di localStorage hanya untuk simulasi. Implementasi produksi wajib memindahkan credential ke backend/secret manager terenkripsi dan tidak menyimpannya di browser atau repository publik.

## Menu Member dan Admin

`member.html` sekarang menyediakan struktur menu member lengkap melalui hamburger: Dashboard, Produk/Beli Layanan, Akun Saya, Pesanan Saya, Saldo & Top Up, Voucher/Promo, Referral, Notifikasi, Panduan Koneksi, Bantuan/Tiket, dan Profil & Keamanan.

Menu admin juga dilengkapi placeholder terstruktur untuk Provisioning, Akun Digital, Voucher & Promo, Notifikasi, Support/Tiket, Laporan, dan Audit Log. Semua panel masih berupa kerangka UI sampai backend database, autentikasi, wallet, payment gateway, dan provisioning multi-protocol dihubungkan.

## Audit interaksi tombol

Semua tombol navigasi yang ada pada prototype sekarang memiliki aksi: menu hamburger membuka drawer, menu berpindah panel, menu publik mobile terbuka, form SEO/VPS menyimpan data simulasi, produk mengarahkan ke katalog, top up/voucher/support/profile memberi status yang jelas, dan referral memiliki aksi salin. Fitur yang membutuhkan backend—login, payment gateway, tiket, profil, dan provisioning nyata—tidak dibuat seolah-olah aktif; tombolnya memberi keterangan bahwa integrasi backend belum dikonfigurasi.

## Monitoring VPS

Dashboard admin memiliki grafik garis CPU/RAM, kartu total VPS/online, resource tertinggi, kartu kesehatan per server, dan alert untuk kondisi **OVERLOAD** atau **OFFLINE**. Prototype menampilkan demo data agar UI dapat diuji. Pada integrasi produksi, dashboard mengambil metrics dari Backend API/VPS Agent setiap 60 detik; ringkasan harian di-reset pukul 00.00, tetapi deteksi overload/offline tetap berjalan sepanjang hari.

## Repository installer VPS

Installer dipisahkan ke repository [ssh-store-vps-agent-installer](https://github.com/usnulnifah-web/ssh-store-website-ssh-tunneling). Gunakan repository website ini untuk aplikasi publik/admin/backend, dan repository installer tersebut hanya pada VPS yang akan menjalankan agent provisioning.

## Config Builder dan Panduan Setup

Panel admin sekarang memiliki menu **Konfigurasi Protocol** dan **Panduan Setup**. Config Builder mencakup SSH WebSocket/SSL dan OpenVPN WebSocket dengan SSL port default `443`, WebSocket path, host/domain, format TXT/OVPN/link/QR, preview, salin, dan unduh TXT. Port 443 dapat diganti manual jika server/provider memakai port lain. Panduan setup menjelaskan VPS, installer agent, Server & Protocol, konfigurasi protocol, pengujian, dan troubleshooting.

### Installer tanpa prompt

Installer VPS Agent berjalan tanpa pertanyaan interaktif: default-nya bind `127.0.0.1`, port `8787`, dan secret HMAC dibuat otomatis. Jika backend berbeda server, pelanggan dapat memakai parameter opsional `--backend-ip` dan `--bind-host`. Secret HMAC berbeda dari password SSH VPS dan dipakai khusus untuk autentikasi API Agent.

## First-run setup admin

`admin.html` memakai guard first-run. Jika flag admin belum dibuat, akses langsung ke dashboard admin dialihkan ke `admin-setup.html`. Pengguna wajib mengisi nama, email, password minimal 12 karakter, dan konfirmasi password sebelum dashboard dapat dibuka. Pada prototype flag/profile disimpan di localStorage; produksi wajib menggunakan tabel admin di database, password hash, session server-side, dan endpoint setup yang hanya dapat dipakai sekali.

## Dokumentasi operasi

Manual lengkap admin VPS dan user/member tersedia di [ADMIN-USER-MANUAL.md](./ADMIN-USER-MANUAL.md). Isinya mencakup perintah `systemctl`, health check, log, metrics, update, uninstall, troubleshooting, serta cara member membeli dan memakai konfigurasi.
