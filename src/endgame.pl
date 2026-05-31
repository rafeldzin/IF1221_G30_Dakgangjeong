%fungsi endgame
cekEndGame :-
    kartu_pemain(Pemenang, []), !,
    nl, write('Permainan selesai! '), write(Pemenang), write(' menghabiskan semua kartunya!'), nl,
    nl, write('Berikut perhitungan poin sisa kartu.'), nl,
    
    urutan_pemain(SemuaPemain),
    print_rincian_semua_pemain(SemuaPemain),
    nl,
    
    ( game_mode(turnamen) ->
        tim_sukses(tim1, [T1P1, T1P2]),
        tim_sukses(tim2, [T2P1, T2P2]),
        kartu_pemain(T1P1, KT1P1v), kartu_tersembunyi(T1P1, KT1P1h), append_list(KT1P1v, KT1P1h, KT1P1),
        kartu_pemain(T1P2, KT1P2v), kartu_tersembunyi(T1P2, KT1P2h), append_list(KT1P2v, KT1P2h, KT1P2),
        kartu_pemain(T2P1, KT2P1v), kartu_tersembunyi(T2P1, KT2P1h), append_list(KT2P1v, KT2P1h, KT2P1),
        kartu_pemain(T2P2, KT2P2v), kartu_tersembunyi(T2P2, KT2P2h), append_list(KT2P2v, KT2P2h, KT2P2),
        hitung_poin_tangan(KT1P1, PT1P1), hitung_poin_tangan(KT1P2, PT1P2),
        hitung_poin_tangan(KT2P1, PT2P1), hitung_poin_tangan(KT2P2, PT2P2),
        TotalTim1 is PT1P1 + PT1P2,
        TotalTim2 is PT2P1 + PT2P2,
        
        write('Berikut perhitungan poin untuk masing-masing tim.'), nl,
        write('Tim 1 ('), write(T1P1), write(', '), write(T1P2), write(') : '),
        write(PT1P1), write(' + '), write(PT1P2), write(' = '), write(TotalTim1), write(' poin'), nl,
        write('Tim 2 ('), write(T2P1), write(', '), write(T2P2), write(') : '),
        write(PT2P1), write(' + '), write(PT2P2), write(' = '), write(TotalTim2), write(' poin'), nl, nl,
        
        ( TotalTim1 < TotalTim2 ->
            write('Selamat, Tim 1 menjadi pemenang!'), nl
        ; TotalTim2 < TotalTim1 ->
            write('Selamat, Tim 2 menjadi pemenang!'), nl
        ;
            urutan_pemain([PemainPertama | _]),
            ( my_member(PemainPertama, [T1P1, T1P2]) ->
                write('Selamat, Tim 1 menjadi pemenang! (Poin sama, Tim 1 memiliki pemain dengan giliran pertama)'), nl
            ;
                write('Selamat, Tim 2 menjadi pemenang! (Poin sama, Tim 2 memiliki pemain dengan giliran pertama)'), nl
            )
        )
    ;
        hitung_semua_poin(SemuaPemain, ListSkor),
        my_keysort(ListSkor, SkorTerurut),
        write('Urutan pemenang:'), nl,
        print_leaderboard(SkorTerurut, 1)
    ),
    halt.

cekEndGame.

%poin tiap kartu
hitung_poin_kartu(kartu(_, 0), 1) :- !.
hitung_poin_kartu(kartu(hitam, mimic), 20) :- !.
hitung_poin_kartu(kartu(hitam, _), 20) :- !.
hitung_poin_kartu(kartu(_, skip), 10) :- !.
hitung_poin_kartu(kartu(_, reverse), 10) :- !.
hitung_poin_kartu(kartu(_, drawtwo), 10) :- !.
hitung_poin_kartu(kartu(_, Angka), Angka) :- integer(Angka), !.

%poin per tangan
hitung_poin_tangan([], 0).
hitung_poin_tangan([Kartu|Sisa], Total) :-
    hitung_poin_kartu(Kartu, Poin),
    hitung_poin_tangan(Sisa, TotalSisa),
    Total is Poin + TotalSisa.

hitung_semua_poin([], []).
hitung_semua_poin([Pemain|SisaPemain], [Poin-Pemain | SisaSkor]) :-
    kartu_pemain(Pemain, ListKartu),
    kartu_tersembunyi(Pemain, ListHidden),
    append_list(ListKartu, ListHidden, SemuaKartu),
    hitung_poin_tangan(SemuaKartu, Poin),
    hitung_semua_poin(SisaPemain, SisaSkor).

%print
print_rincian_semua_pemain([]).
print_rincian_semua_pemain([Pemain|Sisa]) :-
    kartu_pemain(Pemain, ListKartu),
    kartu_tersembunyi(Pemain, ListHidden),
    append_list(ListKartu, ListHidden, SemuaKartu),
    ( SemuaKartu == [] -> write(Pemain), write(': kartu habis = 0 poin'), nl
    ;
        write(Pemain), write(': '),
        print_nama_kartu_deret(SemuaKartu), write(' = '),
        print_poin_kartu_deret(SemuaKartu),
        hitung_poin_tangan(SemuaKartu, Total),
        write(' = '), write(Total), write(' poin'), nl
    ),
    print_rincian_semua_pemain(Sisa).

print_nama_kartu_deret([kartu(Warna, Jenis)]) :- !, write(Warna), write('-'), write(Jenis).
print_nama_kartu_deret([kartu(Warna, Jenis) | Sisa]) :-
    write(Warna), write('-'), write(Jenis), write(' + '), print_nama_kartu_deret(Sisa).

print_poin_kartu_deret([Kartu]) :- !, hitung_poin_kartu(Kartu, Poin), write(Poin).
print_poin_kartu_deret([Kartu | Sisa]) :-
    hitung_poin_kartu(Kartu, Poin), write(Poin), write(' + '), print_poin_kartu_deret(Sisa).

print_leaderboard([], _).
print_leaderboard([Poin-Pemain|Sisa], Peringkat) :-
    write(Peringkat), write('. '), write(Pemain), write(' ('), write(Poin), write(' poin)'), nl,
    NextPeringkat is Peringkat + 1,
    print_leaderboard(Sisa, NextPeringkat).