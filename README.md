# SmartClinic

septian dwi saputra - 411232056

Aplikasi Flutter untuk simulasi layanan klinik dengan dua jenis akun: pasien dan admin.

## Fitur

- Pasien dapat mendaftar, masuk, mengubah profil, dan keluar dari akun.
- Pasien dapat memilih dokter, tanggal, dan jam kunjungan. Jam yang sudah dipesan atau lewat tidak dapat dipilih.
- Booking menghasilkan nomor antrean dan notifikasi. Pasien dapat melihat riwayat dan membatalkan jadwal.
- Admin dapat melihat ringkasan klinik, mencari pasien, memfilter jadwal menurut status, lalu menandai kunjungan selesai atau membatalkannya.
- Pasien mendapat notifikasi saat booking dibuat atau status kunjungan berubah.
- Navigasi menyesuaikan ukuran layar: bottom bar di ponsel dan navigation rail di tablet atau layar lebar.
- Data contoh dipisahkan dalam fixture demo agar mudah diganti ketika backend tersedia.

## Menjalankan aplikasi

```sh
flutter pub get
flutter run
```

Pemeriksaan kode dan pengujian:

```sh
flutter analyze
flutter test
```
