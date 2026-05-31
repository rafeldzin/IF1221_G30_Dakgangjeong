:- include('helper.pl').
:- include('inisiasi.pl').
:- include('ambil.pl').
:- include('command.pl').

startGame :-
    retractall(game_mode(_)),
    retractall(tim_sukses(_, _)),
    nl, write('Tersedia 2 mode permainan.'), nl,
    write('1. Mode klasik'), nl,
    write('2. Mode turnamen'), nl,
    repeat,
        nl, write('Pilih mode permainan: '),
        read(ModeInput),
        ( my_member(ModeInput, [1, 2]) -> ! ; write('Pilihan tidak valid!'), nl, fail ),
    ( ModeInput == 1 ->
        asserta(game_mode(klasik)),
        inputJumlahPemain(JumlahPemain),
        tanyaPemain(JumlahPemain, DaftarPemain),
        acakGiliran(DaftarPemain, UrutanPemain)
    ;
        asserta(game_mode(turnamen)),
        nl, write('Permainan dimulai dalam mode turnamen (Wajib 4 pemain).'), nl,
        tanyaPemain(4, DaftarPemain),
        acakGiliran(DaftarPemain, [T1P1, T1P2, T2P1, T2P2]),
        asserta(tim_sukses(tim1, [T1P1, T1P2])),
        asserta(tim_sukses(tim2, [T2P1, T2P2])),
        nl, write('Membentuk tim secara acak...'), nl, nl,
        write('Tim 1 : '), write(T1P1), write(', '), write(T1P2), nl,
        write('Tim 2 : '), write(T2P1), write(', '), write(T2P2), nl, nl,
        UrutanPemain = [T1P1, T2P1, T1P2, T2P2]
    ),
    printUrutan(UrutanPemain),
    retractall(urutan_pemain(_)),
    asserta(urutan_pemain(UrutanPemain)),
    UrutanPemain = [PemainPertama | _], 
    retractall(giliran_sekarang(_)),
    asserta(giliran_sekarang(PemainPertama)),
    % INISIALISASI STATE & DECK DINAMIS
    inisiasi_deck,
    retractall(arah_permainan(_)), asserta(arah_permainan(kanan)),
    retractall(status_plus4(_)), asserta(status_plus4(nonaktif)),
    retractall(jenis_sebelumnya(_)), asserta(jenis_sebelumnya(none)),
    retractall(warna_sebelumnya(_)), asserta(warna_sebelumnya(none)),
    retractall(pemain_sebelumnya(_)), asserta(pemain_sebelumnya(none)),
    retractall(kartu_aksi_terakhir(_)), asserta(kartu_aksi_terakhir(none)),
    retractall(status_swap(_)), asserta(status_swap(belum)),
    inisiasi_kartu_tersembunyi(UrutanPemain),
    
    bagi_kartu_semua(UrutanPemain),
    write('Kartu awal telah dibagikan kepada semua pemain!'), nl,
    
    pullKartu(KartuAwal),
    KartuAwal = kartu(WarnaAwal, _),
    ( WarnaAwal == hitam -> WarnaFix = merah ; WarnaFix = WarnaAwal ),
    
    retractall(discard_pile(_)),
    asserta(discard_pile(KartuAwal)),

    retractall(warna_aktif(_)),
    asserta(warna_aktif(WarnaFix)),
    
    cekInfo.

inisiasi_kartu_tersembunyi([]).
inisiasi_kartu_tersembunyi([P|T]) :-
    retractall(kartu_tersembunyi(P, _)),
    asserta(kartu_tersembunyi(P, [])),
    inisiasi_kartu_tersembunyi(T).

debugKlasik :-
    retractall(game_mode(_)),
    retractall(tim_sukses(_, _)),
    retractall(urutan_pemain(_)),
    retractall(giliran_sekarang(_)),
    retractall(kartu_pemain(_, _)),
    retractall(kartu_tersembunyi(_, _)),
    retractall(discard_pile(_)),
    retractall(warna_aktif(_)),
    retractall(arah_permainan(_)),
    retractall(status_plus4(_)),
    retractall(jenis_sebelumnya(_)),
    retractall(warna_sebelumnya(_)),
    retractall(pemain_sebelumnya(_)),
    retractall(kartu_aksi_terakhir(_)),
    retractall(status_swap(_)),

    asserta(game_mode(klasik)),
    asserta(urutan_pemain(['A', 'B'])),
    asserta(giliran_sekarang('A')),
    asserta(discard_pile(kartu(merah, 4))),
    asserta(warna_aktif(merah)),
    asserta(arah_permainan(kanan)),
    asserta(status_plus4(nonaktif)),
    asserta(jenis_sebelumnya(none)),
    asserta(warna_sebelumnya(none)),
    asserta(pemain_sebelumnya(none)),
    asserta(kartu_aksi_terakhir(none)),
    asserta(status_swap(belum)),
    inisiasi_kartu_tersembunyi(['A', 'B']),
    inisiasi_deck,

    sisainDuaKartu('A'),
    sisainDuaKartu('B'),
    nl,
    cekInfo, !.

debugTurnamen :-
    retractall(game_mode(_)),
    retractall(tim_sukses(_, _)),
    retractall(urutan_pemain(_)),
    retractall(giliran_sekarang(_)),
    retractall(kartu_pemain(_, _)),
    retractall(kartu_tersembunyi(_, _)),
    retractall(discard_pile(_)),
    retractall(warna_aktif(_)),
    retractall(arah_permainan(_)),
    retractall(status_plus4(_)),
    retractall(jenis_sebelumnya(_)),
    retractall(warna_sebelumnya(_)),
    retractall(pemain_sebelumnya(_)),
    retractall(kartu_aksi_terakhir(_)),
    retractall(status_swap(_)),

    asserta(game_mode(turnamen)),
    asserta(urutan_pemain(['A', 'B', 'C', 'D'])),
    asserta(tim_sukses(tim1, ['A', 'C'])),
    asserta(tim_sukses(tim2, ['B', 'D'])),
    asserta(giliran_sekarang('A')),
    asserta(discard_pile(kartu(merah, 4))),
    asserta(warna_aktif(merah)),
    asserta(arah_permainan(kanan)),
    asserta(status_plus4(nonaktif)),
    asserta(jenis_sebelumnya(none)),
    asserta(warna_sebelumnya(none)),
    asserta(pemain_sebelumnya(none)),
    asserta(kartu_aksi_terakhir(none)),
    asserta(status_swap(belum)),
    inisiasi_kartu_tersembunyi(['A', 'B', 'C', 'D']),
    inisiasi_deck,

    sisainDuaKartu('A'),
    sisainDuaKartu('B'),
    sisainDuaKartu('C'),
    sisainDuaKartu('D'),
    nl,
    cekInfo, !.
