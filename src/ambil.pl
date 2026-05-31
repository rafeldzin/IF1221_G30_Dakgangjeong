ambilKartu :-
    giliran_sekarang(Pemain),
    ( status_plus4(aktif) ->
        retractall(status_plus4(_)),
        ambil_n_kartu(Pemain, 4),
        pindahGiliran
    ;
        ( deck_utama([]) -> daurUlangDeck ; true ),
        pullKartu(Kartu),
        prosesAmbil(Pemain, Kartu)
    ).

prosesAmbil(Pemain, Kartu) :-
    kartu_pemain(Pemain, KartuLama),
    append_element(KartuLama, Kartu, KartuBaru),
    retract(kartu_pemain(Pemain, KartuLama)),
    asserta(kartu_pemain(Pemain, KartuBaru)),
    retractall(status_uni(Pemain)),
    write(Pemain), write(' mendapatkan '), write(Kartu), nl,
    pindahGiliran.

pindahGiliran :-
    retractall(status_swap(_)), asserta(status_swap(belum)),
    giliran_sekarang(PemainSekarang),
    urutan_pemain(ListPemain),
    
    ( arah_permainan(kiri) ->
        reverse_list(ListPemain, ListReversed),
        next_player(PemainSekarang, ListReversed, PemainBerikutnya)
    ;
        next_player(PemainSekarang, ListPemain, PemainBerikutnya)
    ),
    
    retract(giliran_sekarang(PemainSekarang)),
    asserta(giliran_sekarang(PemainBerikutnya)),
    nl, write('Giliran '), write(PemainBerikutnya), write('.'), nl,
    !.

next_player(X, [X|Tail], Next) :-
    ( Tail = [Next|_] -> true
    ; urutan_pemain(Asli),
      ( arah_permainan(kiri) ->
          reverse_list(Asli, [Next|_])
      ;
          Asli = [Next|_]
      )
    ).
next_player(X, [_|Tail], Next) :-
    next_player(X, Tail, Next).

tantang :-
    giliran_sekarang(Penantang),
    ( status_plus4(aktif) ->
        pemain_sebelumnya(Pembuang),
        warna_sebelumnya(WarnaLama),
        jenis_sebelumnya(JenisLama),
        kartu_pemain(Pembuang, ListKartuPembuang),
        
        nl, write('Tantangan dilakukan!'), nl,
        write('Memeriksa kartu '), write(Pembuang), write('...'), nl, nl,
        
        ( cek_punya_kecocokan(WarnaLama, JenisLama, ListKartuPembuang) ->
            write('Tantangan berhasil. '), write(Pembuang), write(' mendapatkan 4 kartu acak.'), nl,
            retractall(status_plus4(_)),
            ambil_n_kartu(Pembuang, 4),
            pindahGiliran
        ;
            write('Tantangan gagal. '), write(Penantang), write(' mendapatkan 6 kartu acak.'), nl,
            retractall(status_plus4(_)),
            ambil_n_kartu(Penantang, 6),
            pindahGiliran
        )
    ;
        nl, write('Tantang tidak valid! Tidak ada kartu +4 yang bisa ditantang saat ini.'), nl
    ).

ambil_n_kartu(_, 0) :- !.
ambil_n_kartu(Pemain, N) :-
    N > 0,
    ( deck_utama([]) -> daurUlangDeck ; true ),
    pullKartu(Kartu),
    kartu_pemain(Pemain, KartuLama),
    append_element(KartuLama, Kartu, KartuBaru),
    retract(kartu_pemain(Pemain, KartuLama)),
    asserta(kartu_pemain(Pemain, KartuBaru)),
    retractall(status_uni(Pemain)),
    write(Pemain), write(' mendapatkan '), write(Kartu), nl,
    N1 is N - 1,
    ambil_n_kartu(Pemain, N1).

cek_punya_kecocokan(Warna, _, [kartu(Warna, _) | _]) :- Warna \= hitam, !.
cek_punya_kecocokan(_, Jenis, [kartu(_, Jenis) | _]) :- !.
cek_punya_kecocokan(Warna, Jenis, [_ | SisaKartu]) :- cek_punya_kecocokan(Warna, Jenis, SisaKartu).