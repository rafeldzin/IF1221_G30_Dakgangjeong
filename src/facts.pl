warna(merah).
warna(biru).
warna(hijau).
warna(kuning).

angka(0).
angka(1).
angka(2).
angka(3).
angka(4).
angka(5).
angka(6).
angka(7).
angka(8).
angka(9).

aksi(skip).
aksi(reverse).
aksi(drawtwo).

% memasangkan warna dan jenis kartu
kartu(X, Y):-
    warna(X),
    angka(Y) ; aksi(Y).

kartu(hitam, wild).
kartu(hitam, wildd4).


jumlah_card_awal(7).
batasPemain(2,4).