# IF1221_G30_Dakgangjeong (Tugas Besar)

## Anggota Kelompok
Ketua : Ahmad Boutros Fathir (13525002)

Anggota:
1. Muhammad Zaky Amani (13525040)
2. Mochammad Nuha Al Ghifari (13525056)
3. Rafel Dzinun Muhammad (13525062)

## Gambaran Singkat Proyek

Sebuah implementasi permainan kartu UNI yang ditulis menggunakan GNU Prolog. Proyek ini dibuat untuk Tugas Besar mata kuliah IF1221 Logika Komputasional.

Permainan ini tidak hanya memiliki fitur dan aturan seperti pencocokan warna dan angka, efek kartu (Skip, Reverse, Draw Two, Wild, Wild Draw Four), dan deklarasi "UNI", tetapi juga menghadirkan fitur-fitur lanjutan seperti save game, load game, sistem tantang dan tangkap, mode turnamen 2v2, dan God's Hand.

## Cara Menjalankan Program

Untuk menjalankan program ini, pastikan Anda telah menginstal GNU Prolog.
1. Buka terminal atau command prompt di folder ini.
2. Arahkan direktori ke dalam folder src dengan mengetik cd src
3. Buka GNU Prolog dengan mengetikkan gprolog.
4. Ketik ['main'].
5. Mulai permainan dengan mengetik startGame.

## Struktur Repository
Repository ini berisi 1 file README.md dan 2 folder, yaitu src dan doc. 
Folder src berisi beberapa file source code, yaitu:
1. main.pl: menginisialisasi alur permainan awal dan seleksi mode permainan.
2. inisiasi.pl: file yang menangani registrasi pemain, validasi input, pengacakan giliran, dan pembagian kartu.
3. command.pl: Modul interaksi utama yang memproses aksi pemain (membuang kartu, melihat kartu, memicu uni, memicu fitur bonus) dan memberikan efek kartu.
4. ambil.pl: manajemen rotasi yang menangani pengambilan kartu dari deck, perpindahan giliran antarpemain, dan mekanisme tantang.
5. deck.pl: data yang menyimpan definisi 108 kartu standar UNO beserta fungsi penarikannya.
6. endgame.pl: file yang menghitung poin akhir yang aktif ketika state kartu pemain kosong untuk menghasilkan leaderboard dan penentuan pemenang.
7. facts.pl: Berisi variabel dinamis yang menampung seluruh state permainan (daftar giliran, tumpukan buangan, warna aktif, dll).
8. file_io.pl: file untuk melakukan save dan load seluruh state dinamis dari/ke dalam file .txt.
9. helper.pl: berisi fungsi fungsi helper yang dideklarasi manual untuk memenuhi batasan praktikum.

Folder doc berisi beberapa file dokumen, yaitu:
1. Milestone1_G30.pdf: berisi dokumentasi progress kelompok pada milestone pertama.
2. Milestone2_G30.pdf: berisi dokumentasi progress kelompok pada milestone kedua.
3. Laporan_G30.pdf: berisi laporan akhir dari proyek tugas besar IF1221 Logika Komputasional.

## Fitur Utama yang Tersedia
1. Permainan dasar: seperti rotasi giliran, aturan validasi tumpukan, penarikan kartu, efek kartu, dan kalkulasi poin akhir.
2. Aturan UNI dan Tangkap: sistem keharusan pemain untuk mendeklarasikan UNI saat kartu sisa 1.
3. Mekanisme Tantang.
4. Fitur save game dan load game.
5. God's Hand: Intervensi random di awal giliran yang dapat memindahkan kartu antarpemain secara acak.
6. Mimic Card: Kartu custom wild yang menyalin efek kartu terakhir yang dilempar.
7. Hidden Card: Fitur menyembunyikan kartu di tangan untuk mengelabui lawan yang ingin menangkap.
8. Mode Turnamen: Mode khusus 4 pemain dengan sistem akumulasi poin antar tim dan fitur swapKartu dengan rekan satu tim.
