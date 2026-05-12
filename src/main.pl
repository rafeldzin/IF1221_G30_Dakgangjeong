:- [facts.pl].
:- [inisiasi.pl].
:- [deck.pl].
:- [ambil.pl]

% MAIN
startGame:-
    inputJumlahPemain(JumlahPemain),
    tanyaPemain(JumlahPemain, DaftarPemain),
    acakGiliran(DaftarPemain, UrutanPemain),
    printUrutan(UrutanPemain).
    