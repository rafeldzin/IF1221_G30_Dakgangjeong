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