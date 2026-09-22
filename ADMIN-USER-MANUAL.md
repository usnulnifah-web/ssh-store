# Manual Admin dan User SSH Store

Dokumen ini menjelaskan operasi VPS Agent untuk admin dan cara penggunaan layanan untuk user/member.

## A. Manual Admin VPS

### 1. Masuk ke VPS

```bash
ssh root@IP_VPS
```

Gunakan akses SSH yang sudah dikonfigurasi oleh pemilik VPS. Jangan membagikan password root ke member.

### 2. Cek status agent

```bash
systemctl status ssh-store-agent
```

Status normal:

```text
active (running)
enabled
```

`active` berarti agent sedang berjalan. `enabled` berarti agent akan aktif otomatis saat VPS restart.

### 3. Tes health lokal

```bash
curl http://127.0.0.1:8787/health
```

Hasil normal:

```json
{"ok":true,"service":"ssh-store-agent"}
```

### 4. Lihat log realtime

```bash
journalctl -u ssh-store-agent -f
```

Keluar dari log dengan menekan `Ctrl + C`.

Lihat 50 log terakhir:

```bash
journalctl -u ssh-store-agent -n 50 --no-pager
```

### 5. Restart agent

```bash
systemctl restart ssh-store-agent
```

Lalu cek kembali:

```bash
systemctl status ssh-store-agent --no-pager
curl http://127.0.0.1:8787/health
```

### 6. Cek port agent

```bash
ss -ltnp | grep 8787
```

Default agent hanya listen pada:

```text
127.0.0.1:8787
```

Jika Backend API berada di server lain, gunakan private network/VPN atau bind address yang dibatasi firewall. Jangan membuka port agent ke semua internet tanpa allowlist.

### 7. Cek konfigurasi agent

```bash
cat /etc/ssh-store-agent/agent.env
```

File tersebut berisi port, bind address, lokasi data, dan secret HMAC. Jangan kirimkan isi file ini ke publik dan jangan memasukkan secret ke GitHub.

### 8. Cek data akun lokal

```bash
ls -lah /var/lib/ssh-store-agent/
```

Data akun berada di:

```text
/var/lib/ssh-store-agent/accounts.json
```

Backup file tersebut secara aman dan jangan upload ke repository publik karena dapat berisi informasi akun.

### 9. Update agent dari repository installer

```bash
cd ~/ssh-store-vps-agent-installer
git pull --ff-only
bash install.sh
```

Installer terbaru mempertahankan secret agent lama saat reinstall. Setelah update:

```bash
systemctl status ssh-store-agent --no-pager
curl http://127.0.0.1:8787/health
```

### 10. Install baru tanpa pertanyaan

```bash
git clone https://github.com/usnulnifah-web/ssh-store-vps-agent-installer.git
cd ssh-store-vps-agent-installer
sudo bash install.sh
```

Default:

```text
Bind: 127.0.0.1
Port: 8787
Secret: dibuat otomatis
```

Jika backend website berada di server lain:

```bash
sudo bash install.sh --backend-ip IP_BACKEND --bind-host 0.0.0.0
```

Gunakan `0.0.0.0` hanya jika firewall membatasi port agent ke IP backend.

### 11. Menghentikan atau mengaktifkan agent

Hentikan sementara:

```bash
systemctl stop ssh-store-agent
```

Aktifkan kembali:

```bash
systemctl start ssh-store-agent
```

Matikan auto-start:

```bash
systemctl disable ssh-store-agent
```

Aktifkan auto-start:

```bash
systemctl enable ssh-store-agent
```

### 12. Hapus agent

Hapus service tetapi pertahankan data akun:

```bash
cd ~/ssh-store-vps-agent-installer
bash uninstall.sh
```

Hapus service dan data akun secara permanen:

```bash
bash uninstall.sh --purge
```

Perintah `--purge` bersifat destruktif. Pastikan backup sudah dibuat.

### 13. Troubleshooting

Jika health check gagal:

```bash
systemctl status ssh-store-agent --no-pager -l
journalctl -u ssh-store-agent -n 50 --no-pager
ss -ltnp | grep 8787
node --version
systemctl show ssh-store-agent -p ExecStart --value
```

Masalah umum:

| Gejala | Pemeriksaan |
|---|---|
| Port tidak terbuka | Cek `systemctl status` dan `journalctl` |
| Node tidak ditemukan | Jalankan `command -v node`; reinstall installer terbaru |
| Backend tidak bisa terhubung | Cek bind address, firewall, private network, dan IP backend |
| Agent restart terus | Baca log systemd; periksa Node.js dan environment file |
| Akun gagal dibuat | Periksa hak root, perintah `useradd`, username, dan masa aktif |
| Domain tidak bisa dipakai | Cek DNS, SSL, port 443, dan WebSocket path |

## B. Manual User/Member

### 1. Membuat akun

1. Buka halaman website.
2. Daftar sebagai member.
3. Login ke Member Area.
4. Buka menu **Saldo & Top Up**.
5. Isi saldo melalui gateway atau top up manual.
6. Buka menu **Produk / Beli Layanan**.
7. Pilih protocol, lokasi, dan masa aktif.
8. Klik **Beli**.

### 2. Melihat akun yang berhasil dibuat

Buka menu:

```text
Akun Saya
```

Informasi yang dapat ditampilkan:

- Username.
- Password.
- Host/domain.
- Port.
- IP VPS jika member memilih menampilkannya.
- WebSocket path.
- TLS/SNI.
- UUID atau key untuk protocol tertentu.
- Masa aktif.
- Tanggal kedaluwarsa.
- Status akun.

### 3. Download konfigurasi

Member dapat menggunakan:

- TXT untuk data akun umum.
- `.ovpn` untuk OpenVPN.
- `.conf` untuk WireGuard.
- Link VMess/VLESS/Trojan/Shadowsocks.
- QR Code jika tersedia.

Simpan file dan password dengan aman. Jangan mengunggah konfigurasi ke grup publik.

### 4. Jika akun tidak bisa digunakan

Periksa:

1. Akun belum kedaluwarsa.
2. Username dan password benar.
3. Host/domain benar.
4. Port sesuai protocol.
5. WebSocket path sesuai.
6. TLS/SSL aktif jika konfigurasi memakai SSL.
7. Aplikasi client sesuai dengan protocol.
8. Status server sedang online.

Jika tetap gagal, buat tiket di menu **Bantuan / Tiket** dan sertakan nomor pesanan, bukan password akun.

### 5. Keamanan user

- Jangan membagikan password akun.
- Jangan membagikan file `.ovpn` atau `.conf` ke publik.
- Jangan memakai akun untuk DDoS, port scanning, hacking, malware, penipuan, atau akses tanpa izin.
- Laporkan akun atau server bermasalah kepada admin.

## Repository resmi

- Website, admin, member, dan backend: [ssh-store](https://github.com/usnulnifah-web/ssh-store)
- Installer dan VPS Agent: [ssh-store-vps-agent-installer](https://github.com/usnulnifah-web/ssh-store-vps-agent-installer)

## Menu terminal Habibillah saat login VPS

Installer juga memasang menu terminal berwarna khusus admin. Menu muncul hanya pada login SSH root interaktif dan menampilkan daftar protocol bernomor. Ketik `1` untuk SSH WebSocket, kemudian pilih daftar akun, buat akun, perpanjang, suspend/aktifkan, atau hapus akun. Penghapusan meminta konfirmasi `HAPUS`. Pilih `0` untuk kembali ke menu sebelumnya atau keluar ke shell. Menu tidak mengganggu API, cron, SCP, dan perintah SSH otomatis.
