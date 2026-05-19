:- include('facts.pl').
:- include('inisiasi.pl').
:- include('ambil.pl').
:- include('command.pl').

% MAIN
startGame:-
    inputJumlahPemain(JumlahPemain),
    tanyaPemain(JumlahPemain, DaftarPemain),
    acakGiliran(DaftarPemain, UrutanPemain),
    printUrutan(UrutanPemain),
    asserta(urutan_pemain(UrutanPemain)),
    UrutanPemain = [PemainPertama | _], 
    asserta(giliran_sekarang(PemainPertama)),
    bagi_kartu_semua(UrutanPemain),
    write('Kartu awal telah dibagikan kepada semua pemain!'), nl,
    pullKartu(KartuAwal),
    KartuAwal = kartu(WarnaAwal, _),
    asserta(discard_pile(KartuAwal)),
    asserta(warna_aktif(WarnaAwal)),
    cekInfo.
    