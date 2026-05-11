%Buat minta jumlah pemain
inputJumlahPemain(X):-
    write('Masukkan jumlah pemain: '),
    read(Input),
    validasiJumlahPemain(X, Input).

%Validasi agar jumlah pemainnya sesuai aturan (2 ampe 4)
validasiJumlahPemain(X, Input):-
    Input >= 2,
    Input =< 4,
    !,
    X = Input.


validasiJumlahPemain(X, Input):-
    Input < 2,
    write('Mohon masukkan angka antara 2 - 4.'), nl,
    inputJumlahPemain(X).
    

validasiJumlahPemain(X, Input):-
    Input > 4,
    write('Mohon masukkan angka antara 2 - 4.'), nl,
    inputJumlahPemain(X).


% Buat mastiin nama yang diinput berbeda
cekPemainUnik(Pemain, 1, [DaftarH]):-
    Pemain \= DaftarH.

cekPemainUnik(Pemain, X, [DaftarH|DaftarT]):-
    X > 1,
    Pemain \= DaftarH,
    X1 is X - 1,
    cekPemainUnik(Pemain, X1, DaftarT).

% Buat nanya nama pemain
tanyaPemain(1, [Pemain1]):-
    write('Masukkan nama pemain 1: '),
    read(Pemain1).

tanyaPemain(X, [PemainH|PemainT]):-
    X > 1,
    X1 is X - 1,
    tanyaPemain(X1, PemainT),

    repeat,
        write('Masukkan nama pemain '), write(X), write(': '),
        read(Input), 
        
        ( cekPemainUnik(Input, X1, PemainT) ->
            PemainH = Input, !
        ;
            write('Nama sudah digunakan. Masukkan nama lain!'), nl,
            fail
        ).

% bikin nomor urutan
noRandom([], []).
noRandom([Pemain | PemainT], [No-Pemain|SisaRandom]):-
    random(No),
    noRandom(PemainT, SisaRandom).

% ngebuang nomor urutannya
buangNo([], []).
buangNo([No-Pemain|SisaRandom], [Pemain|SisaPemain]):-
    buangNo(SisaRandom, SisaPemain).

% mengacak urutan pemain
acakGiliran(UrutanAwal, UrutanAcak):-
    noRandom(UrutanAwal, UrutanDenganNo),
    keysort(UrutanDenganNo, UrutanAcakDenganNo),
    buangNo(UrutanAcakDenganNo, UrutanAcak).

% ngeprint per pemainnya
printUrutanKe([Pemain]):-
    write(Pemain),
    write('.').

printUrutanKe([PemainH | PemainT]):-
    write(PemainH),
    write(' - '),
    printUrutanKe(PemainT).

% ngeprint urutan pemain
printUrutan(UrutanPemain):-
    write('Urutan pemain: '),
    printUrutanKe(UrutanPemain),
    nl.


% MAIN
startGame:-
    inputJumlahPemain(JumlahPemain),
    tanyaPemain(JumlahPemain, DaftarPemain),
    acakGiliran(DaftarPemain, UrutanPemain),
    printUrutan(UrutanPemain).
    