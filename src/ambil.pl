ambilKartu :-
    giliran_sekarang(Pemain),
    pullKartu(Kartu),
    prosesAmbil(Pemain, Kartu).

prosesAmbil(Pemain, Kartu) :-
    kartu_pemain(Pemain, KartuLama),
    append(KartuLama, [Kartu], KartuBaru),
    retract(kartu_pemain(Pemain, KartuLama)),
    asserta(kartu_pemain(Pemain, KartuBaru)),
    write(Pemain), write(' mendapatkan kartu.'), write(KartuBaru), nl,
    pindahGiliran.

pindahGiliran :-
    giliran_sekarang(PemainSekarang),
    urutan_pemain(ListPemain),
    next_player(PemainSekarang, ListPemain, PemainBerikutnya),
    retract(giliran_sekarang(PemainSekarang)),
    asserta(giliran_sekarang(PemainBerikutnya)),
    nl, write('Giliran '), write(PemainBerikutnya), write('.'), nl.

next_player(X, [X|Tail], Next) :-
    (Tail = [Next|_] -> true ; urutan_pemain([Next|_])).
next_player(X, [_|Tail], Next) :-
    next_player(X, Tail, Next).