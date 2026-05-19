:- include('deck.pl').

%Buat minta jumlah pemain
inputJumlahPemain(X):-
    write('Masukkan jumlah pemain: '),
    read(Input),
    validasiJumlahPemain(X, Input).

%Validasi agar jumlah pemainnya sesuai aturan (2 ampe 4)
validasiJumlahPemain(X, Input):-
    integer(Input),
    Input >= 2,
    Input =< 4,
    !,
    X = Input.


validasiJumlahPemain(X, _Input):-
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



cekHurufBesar(Input) :-
    \+ var(Input),
    atom(Input),
    atom_codes(Input, [HurufPertama | _]),
    HurufPertama >= 65,
    HurufPertama =< 90.

% Buat nanya nama pemain
tanyaPemain(1, [Pemain1]):-
    repeat,
        write('Masukkan nama pemain 1: '),
        read(Input),
        ( cekHurufBesar(Input) ->
                Pemain1 = Input, !
            ;
                write('Nama harus diawali huruf besar dan diapit tanda kutip tunggal.'), nl,
                fail
            ).

tanyaPemain(X, [PemainH|PemainT]):-
    X > 1,
    X1 is X - 1,
    tanyaPemain(X1, PemainT),

    repeat,
        write('Masukkan nama pemain '), write(X), write(': '),
        read(Input),
        
        
        (   \+ cekHurufBesar(Input) ->
            write('Nama harus diawali huruf besar dan diapit tanda kutip tunggal.'), nl,
            fail
            
        ;   cekPemainUnik(Input, X1, PemainT) ->
            PemainH = Input, !

        ;   \+ cekPemainUnik(Input, X1, PemainT) ->
            write('Nama sudah digunakan. Masukkan nama lain!'), nl,
            fail;
            PemainH = Input, !
        ).

% bikin nomor urutan
noRandom([], []).
noRandom([Pemain | PemainT], [No-Pemain|SisaRandom]):-
    random(No),
    noRandom(PemainT, SisaRandom).

% ngebuang nomor urutannya
buangNo([], []).
buangNo([_-Pemain|SisaRandom], [Pemain|SisaPemain]):-
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

siapkan_n_kartu(0, []).
siapkan_n_kartu(N, [Kartu | SisaKartu]) :-
    N > 0,
    pullKartu(Kartu),
    N1 is N - 1,          
    siapkan_n_kartu(N1, SisaKartu).

bagi_kartu_semua([]).
bagi_kartu_semua([Pemain | SisaPemain]) :-
    jumlah_card_awal(Jumlah),
    siapkan_n_kartu(Jumlah, ListKartuPemain),
    asserta(kartu_pemain(Pemain, ListKartuPemain)),
    bagi_kartu_semua(SisaPemain).