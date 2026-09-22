# SSH Store

Prototype landing page untuk toko akun SSH dengan gaya visual gelap-modern, katalog produk, login member, saldo, top up gateway/manual, dan pilihan server.

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
