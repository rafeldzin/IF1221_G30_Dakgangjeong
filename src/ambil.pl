ambilKartu :-
    giliran_sekarang(Pemain),
    ( deck_utama([]) -> 
        write('Deck habis! Mengocok ulang tumpukan...'), nl,
        daurUlangDeck ;  true ),
    pull_kartu(Kartu),
    prosesAmbil(Pemain, Kartu).

prosesAmbil(Pemain, Kartu) :-
    kartu_pemain(Pemain, KartuLama),
    append(KartuLama, [Kartu], KartuBaru),
    retract(kartu_pemain(Pemain, KartuLama)),
    asserta(kartu_pemain(Pemain, KartuBaru)),
    write(Pemain), write(' mendapatkan kartu.'), nl,
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

tantang :-
    giliran_sekarang(Penantang),
    discard_pile(KartuAtas),
    
    % cek apa kartu atasnya adalah Wild Draw Four
  
    ( KartuAtas == kartu(hitam, wildd4) ->
        
        pemain_sebelumnya(Pembuang),
        warna_sebelumnya(WarnaLama),
        kartu_pemain(Pembuang, ListKartuPembuang),
        
        % cek apakah si pembuang punya kartu dengan WarnaLama
        ( cek_punya_warna(WarnaLama, ListKartuPembuang) ->
            
            % TANTANGAN BERHASIL
            nl, write('Tantangan BERHASIL! '), write(Pembuang), write(' menyembunyikan warna yang cocok.'), nl,
            write(Pembuang), write(' terkena penalti 4 kartu!'), nl,
            ambil_n_kartu(Pembuang, 4)
            % Giliran tetap milik penantang (tidak usah panggil pindahGiliran)
            
        ;
            % TANTANGAN GAGAL
            nl, write('Tantangan GAGAL! '), write(Pembuang), write(' bermain jujur.'), nl,
            write(Penantang), write(' terkena penalti 6 kartu (4 + 2 denda)!'), nl,
            ambil_n_kartu(Penantang, 6),
            pindahGiliran % Giliran penantang hangus karena kalah tantangan
        )
    ;
        % Jika kartu atasnya bukan Wild Draw Four
        nl, write('Tantang tidak valid! Kartu terakhir bukan Wild Draw Four.'), nl
    ).

cek_punya_warna(Warna, [kartu(Warna, _) | _]) :- !.
cek_punya_warna(Warna, [_ | SisaKartu]) :- cek_punya_warna(Warna, SisaKartu).

ambil_n_kartu(_, 0) :- !.
ambil_n_kartu(Pemain, N) :-
    N > 0,( deck_utama([]) -> daurUlangDeck ; true ),
    pull_kartu(Kartu),
    kartu_pemain(Pemain, KartuLama),
    append(KartuLama, [Kartu], KartuBaru),
    retract(kartu_pemain(Pemain, KartuLama)),
    asserta(kartu_pemain(Pemain, KartuBaru)),
    
    N1 is N - 1,
    ambil_n_kartu(Pemain, N1).