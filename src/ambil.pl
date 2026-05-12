ambilKartu :-
    giliran_sekarang(Pemain),
    deck_utama(Deck),

(Deck == [] ->
        write('Deck utama kosong! Melakukan kocok ulang dari discard pile...'), nl,
        daurUlangDeck,deck_utama(DeckBaru),
        prosesAmbil(Pemain, DeckBaru);prosesAmbil(Pemain, Deck)).

prosesAmbil(Pemain, [KartuDitarik | SisaDeck]) :-
retract(deck_utama(_)),asserta(deck_utama(SisaDeck)),

kartu_pemain(Pemain, KartuLama),
    append(KartuLama, [KartuDitarik], KartuBaru),
    retract(kartu_pemain(Pemain, KartuLama)),
    asserta(kartu_pemain(Pemain, KartuBaru)),

write(Pemain), write(' mendapatkan kartu.'), nl,
pindahGiliran.  

daurUlangDeck :-
    discard_pile([KartuAtas | SisaDiscard]),
    (SisaDiscard == [] ->
        write('Error: Tidak ada kartu di discard pile untuk dikocok ulang!'), nl
    ; shuffle(SisaDiscard, DeckBaru),retract(deck_utama(_)),
        asserta(deck_utama(DeckBaru)),retract(discard_pile(_)),
        asserta(discard_pile([KartuAtas]))
    ).


pindahGiliran :-
    giliran_sekarang(PemainSekarang),
    urutan_pemain(ListPemain),next_player(PemainSekarang, ListPemain, PemainBerikutnya),
    retract(giliran_sekarang(PemainSekarang)),
    asserta(giliran_sekarang(PemainBerikutnya)),
    
    nl, write('Giliran '), write(PemainBerikutnya), write('.'), nl.

next_player(X, [X|Tail], Next) :-
    (Tail = [Next|_] -> true ; urutan_pemain([Next|_])).
next_player(X, [_|Tail], Next) :-
    next_player(X, Tail, Next).

