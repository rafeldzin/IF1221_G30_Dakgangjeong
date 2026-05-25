:- dynamic pemain_kartu/2.      
:- dynamic discard_pile/1.      
:- dynamic giliran_sekarang/1.  
:- dynamic urutan_pemain/1.     

====================================

ambil_kartu_ke(1, [H|T], H, T) :- !.
ambil_kartu_ke(N, [H|T], X, [H|Rest]) :-
    N > 1,
    N1 is N - 1,
    ambil_kartu_ke(N1, T, X, Rest).

valid_kartu(kartu(Warna, _), kartu(Warna, _)).
valid_kartu(kartu(_, Angka), kartu(_, Angka)).

pemain_selanjutnya(Sekarang, Berikutnya) :-
    urutan_pemain(ListPemain),
    append(_, [Sekarang, Berikutnya | _], ListPemain), !.
pemain_selanjutnya(Sekarang, Berikutnya) :-
    urutan_pemain(ListPemain),
    last(ListPemain, Sekarang),
    ListPemain = [Berikutnya|_].

tulis_kartu(kartu(Warna, Nilai)) :-
    write(Warna), write('-'), write(Nilai).

mainkanKartu(NomorUrut) :-
    giliran_sekarang(Pemain),
    pemain_kartu(Pemain, Tangan),
    
    ( ambil_kartu_ke(NomorUrut, Tangan, KartuDimainkan, TanganSisa) ->
        true
    ;
        write('Nomor urut kartu tidak valid! Silakan masukkan nomor yang benar.'), nl, fail
    ),
    
    discard_pile([KartuAtas | SisaDiscard]),
    
    ( valid_kartu(KartuDimainkan, KartuAtas) ->
        
        retract(pemain_kartu(Pemain, Tangan)),
        asserta(pemain_kartu(Pemain, TanganSisa)),
        
        retract(discard_pile(PileLama)),
        asserta(discard_pile([KartuDimainkan | PileLama])),
        
        write(Pemain), write(' memainkan kartu: '), tulis_kartu(KartuDimainkan), write('.'), nl,
        
        pemain_selanjutnya(Pemain, PemainBerikutnya),
        retract(giliran_sekarang(Pemain)),
        asserta(giliran_sekarang(PemainBerikutnya)),
        
        write('Giliran '), write(PemainBerikutnya), write('.'), nl
    ;
        write('Kartu tidak valid! Kartu harus memiliki warna atau angka yang sama dengan discard pile.'), nl, fail
    ).