saveGame :-
    ( status_plus4(aktif) ->
        nl, write('Command ini tidak dapat digunakan ketika pemain diharuskan memilih command tertentu.'), nl,
        write('Misalnya, ketika pemain sebelumnya memainkan wild_draw_four, pemain yang sedang mendapat giliran hanya dapat memilih tantang atau ambilKartu hingga salah satu dipilih.'), nl
    ;
        nl, write('Masukkan nama file penyimpanan (gunakan kutip tunggal, cth: ''save1.txt''): '),
        read(Filename),
        ( \+ var(Filename) ->
            open(Filename, write, Stream),
            simpan_semua_fakta(Stream),
            close(Stream),
            nl, write('Status permainan berhasil disimpan ke '), write(Filename), nl
        ;   nl, write('Format nama file salah! Harus diapit kutip tunggal.'), nl )
    ).

simpan_semua_fakta(Stream) :-
    simpan_fakta(Stream, game_mode(_)),
    simpan_fakta(Stream, tim_sukses(_, _)),
    simpan_fakta(Stream, urutan_pemain(_)),
    simpan_fakta(Stream, giliran_sekarang(_)),
    simpan_fakta(Stream, arah_permainan(_)),
    simpan_fakta(Stream, discard_pile(_)),
    simpan_fakta(Stream, kartu_pemain(_, _)),
    simpan_fakta(Stream, kartu_tersembunyi(_, _)),
    simpan_fakta(Stream, warna_aktif(_)),
    simpan_fakta(Stream, pemain_sebelumnya(_)),
    simpan_fakta(Stream, warna_sebelumnya(_)),
    simpan_fakta(Stream, jenis_sebelumnya(_)),
    simpan_fakta(Stream, status_uni(_)),
    simpan_fakta(Stream, status_plus4(_)),
    simpan_fakta(Stream, kartu_aksi_terakhir(_)).

simpan_fakta(Stream, Pola) :-
    call(Pola), writeq(Stream, Pola), write(Stream, '.'), nl(Stream), fail.
simpan_fakta(_, _).

loadGame :-
    nl, write('Masukkan nama file yang ingin dimuat (cth: ''save1.txt''): '),
    read(Filename),
    ( \+ var(Filename) ->
        catch((
            open(Filename, read, Stream),
            bersihkan_state,
            baca_fakta(Stream),
            close(Stream),
            nl, write('Game berhasil dimuat dari file: '), write(Filename), nl,
            nl, write('--- STATUS GAME SAAT INI ---'), nl,
            cekInfo
        ), _, ( nl, write('ERROR: File '), write(Filename), write(' tidak ditemukan!'), nl ))
    ;   nl, write('Format nama file salah! Harus diapit kutip tunggal.'), nl ).

bersihkan_state :-
    retractall(game_mode(_)),
    retractall(tim_sukses(_, _)),
    retractall(urutan_pemain(_)),
    retractall(giliran_sekarang(_)),
    retractall(arah_permainan(_)),
    retractall(discard_pile(_)),
    retractall(kartu_pemain(_, _)),
    retractall(kartu_tersembunyi(_, _)),
    retractall(warna_aktif(_)),
    retractall(pemain_sebelumnya(_)),
    retractall(warna_sebelumnya(_)),
    retractall(jenis_sebelumnya(_)),
    retractall(status_uni(_)),
    retractall(status_plus4(_)),
    retractall(kartu_aksi_terakhir(_)).

baca_fakta(Stream) :-
    read(Stream, Term),
    ( Term == end_of_file -> true
    ; assertz(Term), baca_fakta(Stream) ).