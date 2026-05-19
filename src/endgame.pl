% hitung poin
hitung_poin_kartu(kartu(_, 0), 1) :- !.
hitung_poin_kartu(kartu(hitam, _), 20) :- !.
hitung_poin_kartu(kartu(_, skip), 10) :- !.
hitung_poin_kartu(kartu(_, reverse), 10) :- !.
hitung_poin_kartu(kartu(_, drawtwo), 10) :- !.
hitung_poin_kartu(kartu(_, Angka), Angka) :- integer(Angka), !.

hitung_poin_tangan([], 0).
hitung_poin_tangan([Kartu|Sisa], Total) :-
    hitung_poin_kartu(Kartu, Poin),
    hitung_poin_tangan(Sisa, TotalSisa),
    Total is Poin + TotalSisa.

hitung_semua_poin([], []).
hitung_semua_poin([Pemain|SisaPemain], [Poin-Pemain | SisaSkor]) :-
    kartu_pemain(Pemain, ListKartu),
    hitung_poin_tangan(ListKartu, Poin),
    hitung_semua_poin(SisaPemain, SisaSkor).

cekEndGame :-
    kartu_pemain(Pemenang, []), !,
    nl, write('==========================================='), nl,
    write(' PERMAINAN SELESAI! PEMENANGNYA: '), write(Pemenang), nl,
    write('==========================================='), nl,
    
    urutan_pemain(SemuaPemain),
    hitung_semua_poin(SemuaPemain, ListSkor),
    keysort(ListSkor, SkorTerurut), 
    nl, write('Peringkat Akhir (Berdasarkan Poin Terkecil):'), nl,
    print_leaderboard(SkorTerurut, 1),
    halt. % Matikan GNU Prolog karena game kelar

cekEndGame.

% Ngeprint Leaderboard
print_leaderboard([], _).
print_leaderboard([Poin-Pemain|Sisa], Peringkat) :-
    write(Peringkat), write('. '), write(Pemain), write(' - '), write(Poin), write(' poin'), nl,
    NextPeringkat is Peringkat + 1,
    print_leaderboard(Sisa, NextPeringkat).