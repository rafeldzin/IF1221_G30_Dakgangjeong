:- include('facts.pl').
:- include('inisiasi.pl').

% MAIN
startGame:-
    inputJumlahPemain(JumlahPemain),
    tanyaPemain(JumlahPemain, DaftarPemain),
    acakGiliran(DaftarPemain, UrutanPemain),
    printUrutan(UrutanPemain).
    