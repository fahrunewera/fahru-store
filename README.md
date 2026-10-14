# PULXIT STORE — panduan pemasangan dari HP Android

Website toko digital dengan katalog, pencarian, kategori, keranjang, daftar/login, pesanan, cek status, dan panel admin. Pembayaran sengaja manual; admin memverifikasi pembayaran di luar website lalu mengubah status pesanan.

## Yang diperlukan
- Akun GitHub
- Akun Supabase (database + autentikasi)
- Akun Vercel (hosting)
- Browser HP Android

## 1. Buat database Supabase
1. Buka https://supabase.com lalu buat project baru.
2. Masuk ke **SQL Editor → New query**.
3. Buka file `supabase/schema.sql` dari ZIP ini, salin semua isinya ke SQL Editor lalu tekan **Run**.
4. Buka **Project Settings → API** (atau Connect). Salin Project URL dan publishable/anon key. Jangan pernah menaruh `service_role` key di website.

## 2. Upload kode ke GitHub dari HP
1. Ekstrak ZIP di HP.
2. Buka https://github.com dan buat repository baru bernama `pulxit-store`.
3. Upload semua file dan folder dari ZIP dengan fitur Add file / Upload files. Pastikan `package.json`, `app/`, dan `supabase/` berada di root repository.
4. Jika upload folder sulit dari browser HP, gunakan GitHub app atau editor kode Android yang mendukung Git.

## 3. Deploy di Vercel
1. Buka https://vercel.com, masuk dengan GitHub.
2. Pilih **Add New → Project**, impor repository `pulxit-store`.
3. Framework biasanya terdeteksi sebagai Next.js.
4. Pada Environment Variables tambahkan:
   - `NEXT_PUBLIC_SUPABASE_URL` = Project URL Supabase
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY` = publishable/anon key Supabase
5. Tekan Deploy. Setelah selesai, Vercel memberi alamat website `...vercel.app`.

## 4. Aktifkan admin
1. Buka website yang sudah online dan daftar menggunakan email yang kamu kuasai.
2. Kembali ke Supabase → SQL Editor.
3. Jalankan perintah ini setelah mengganti email contoh:
   `update public.profiles set is_admin = true where email = 'emailkamu@example.com';`
4. Logout lalu login lagi. Menu **Admin** akan muncul untuk akun tersebut.

## 5. Tambah produk
Panel admin → Tambah produk. Gunakan produk digital yang legal, misalnya template buatan sendiri, aset desain berlisensi, e-book milik sendiri, atau voucher resmi yang memang boleh kamu jual. URL gambar harus berupa tautan HTTPS publik.

## 6. Alur pembayaran manual
1. Pembeli daftar/login, memilih produk, lalu membuat pesanan.
2. Website menampilkan ID pesanan.
3. Admin memberi instruksi pembayaran secara aman melalui saluran yang kamu kelola.
4. Setelah pembayaran benar-benar terverifikasi, admin mengubah status pesanan ke `diproses` lalu `selesai`.

## Catatan penting sebelum menerima uang
- Versi starter ini cocok untuk prototipe dan belajar, bukan langsung untuk transaksi bernilai tinggi.
- Total harga dihitung di browser pada versi awal; sebelum penggunaan nyata, pindahkan pembuatan order dan penghitungan total ke server/database agar pelanggan tidak bisa memanipulasi harga.
- Endpoint cek pesanan pada versi starter sebaiknya dibatasi ke akun pemilik/admin sebelum dipakai publik. Jangan bagikan ID order sebagai satu-satunya pengaman.
- Jangan simpan password pembayaran, PIN, OTP, atau data kartu.
- Untuk produk digital, pastikan punya hak jual/distribusi. Hindari akun curian, item hasil pembajakan, atau barang yang melanggar ketentuan game/platform.

## Menjalankan lokal (opsional)
1. Pasang Node.js di komputer, atau gunakan environment coding online yang mendukung Next.js.
2. Salin `.env.example` menjadi `.env.local` lalu isi kredensial Supabase.
3. Jalankan `npm install` lalu `npm run dev`.
