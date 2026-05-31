:- dynamic(urutan_pemain/1).
:- dynamic(giliran_sekarang/1).
:- dynamic(arah_permainan/1).
:- dynamic(discard_pile/1).
:- dynamic(kartu_pemain/2).
:- dynamic(warna_aktif/1).
:- dynamic(pemain_sebelumnya/1).
:- dynamic(warna_sebelumnya/1).
:- dynamic(deck_utama/1).
:- dynamic(status_uni/1).
:- dynamic(jenis_sebelumnya/1).
:- dynamic(status_plus4/1).

:- dynamic(kartu_aksi_terakhir/1).
:- dynamic(kartu_tersembunyi/2).
:- dynamic(game_mode/1).
:- dynamic(tim_sukses/2).
:- dynamic(status_swap/1).

jumlah_card_awal(7).
batasPemain(2,4).