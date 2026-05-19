:- include('facts.pl').
:- include('endgame.pl').

lihatCommand :-
    nl,
    write('Aksi utama yang tersedia:'), nl,
    write('1. ambilKartu'), nl,
    write('2. tantang'), nl,
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand'), nl,
    write('2. lihatKartu'), nl,
    write('3. cekInfo'), nl,
    nl.


lihatKartu :-
    giliran_sekarang(Pemain),
    kartu_pemain(Pemain, ListKartu),
    nl, write('Berikut kartu yang anda miliki.'), nl,
    print_daftar_kartu(ListKartu, 1), !.

lihatKartu :-
    \+ giliran_sekarang(_),
    nl, write('Permainan belum dimulai! Silakan ketik startGame. terlebih dahulu.'), nl.

print_daftar_kartu([], _).

print_daftar_kartu([kartu(hitam, Jenis) | SisaKartu], Nomor) :-
    write(Nomor), write('. hitam-'), write(Jenis), write(' (disembunyikan)'), nl,
    NomorSelanjutnya is Nomor + 1,
    print_daftar_kartu(SisaKartu, NomorSelanjutnya).

print_daftar_kartu([kartu(Warna, Jenis) | SisaKartu], Nomor) :-
    Warna \= hitam,
    write(Nomor), write('. '), write(Warna), write('-'), write(Jenis), nl,
    NomorSelanjutnya is Nomor + 1,
    print_daftar_kartu(SisaKartu, NomorSelanjutnya).

cekInfo :-
    discard_pile(kartu(Warna, Jenis)),
    nl, write('Kartu discard top: '), write(Warna), write('-'), write(Jenis), write('.'), nl, nl,
    
    urutan_pemain(Urutan),
    write('Urutan pemain: '), printUrutanInfo(Urutan), nl, nl,
    
    printPemainInfo(Urutan, 1).

printUrutanInfo([Pemain]) :- 
    write(Pemain), write('.').
printUrutanInfo([PemainH | PemainT]) :- 
    write(PemainH), write(' - '), printUrutanInfo(PemainT).

printPemainInfo([], _).
printPemainInfo([PemainH | PemainT], Nomor) :-
    kartu_pemain(PemainH, ListKartu),
    length(ListKartu, JumlahKartu),
    write('Nama pemain '), write(Nomor), write(': '), write(PemainH), nl,
    write('Jumlah kartu : '), write(JumlahKartu), nl, nl,
    NomorSelanjutnya is Nomor + 1,
    printPemainInfo(PemainT, NomorSelanjutnya).

mainkanKartu(X) :-
    ( status_plus4(aktif) ->
        nl, write('Anda sedang terkena efek +4! Anda HANYA BISA mengetik "tantang." atau "ambilKartu."'), nl
    ;
        giliran_sekarang(Pemain),
        kartu_pemain(Pemain, ListKartu),
        
        ( nth1(X, ListKartu, KartuPilihan) ->
            
            ( validasi_kartu(KartuPilihan) ->
                KartuPilihan = kartu(Warna, Jenis),
                
                hapus_kartu_index(X, ListKartu, SisaKartu),
                retract(kartu_pemain(Pemain, ListKartu)),
                asserta(kartu_pemain(Pemain, SisaKartu)),

                warna_aktif(WarnaLama),
                discard_pile(kartu(_, JenisLama)),
                retractall(warna_sebelumnya(_)), asserta(warna_sebelumnya(WarnaLama)),
                retractall(jenis_sebelumnya(_)), asserta(jenis_sebelumnya(JenisLama)),
                retractall(pemain_sebelumnya(_)), asserta(pemain_sebelumnya(Pemain)),
                
                retract(discard_pile(_)),
                asserta(discard_pile(KartuPilihan)),
                retract(warna_aktif(_)),
                asserta(warna_aktif(Warna)),
                
                nl, write(Pemain), write(' memainkan kartu: '), write(Warna), write('-'), write(Jenis), write('.'), nl,
                cekEndGame,
                terapkan_efek(KartuPilihan)
            ;
                nl, write('Kartu tidak valid! Warna atau jenisnya tidak cocok dengan kartu di meja.'), nl
            )
        ;
            nl, write('Nomor kartu tidak valid atau tidak ada di tanganmu.'), nl
        )
    ).

validasi_kartu(kartu(_, drawtwo)):- discard_pile(kartu(_, drawtwo)), !, fail.
validasi_kartu(kartu(hitam, wild)):- discard_pile(kartu(hitam, wild)), !, fail.
validasi_kartu(kartu(hitam, wildd4)):- discard_pile(kartu(hitam, wildd4)), !, fail.
validasi_kartu(kartu(Warna, _)):- warna_aktif(Warna).
validasi_kartu(kartu(_, Jenis)) :- discard_pile(kartu(_, Jenis)).
validasi_kartu(kartu(hitam, _)).
hapus_kartu_index(1, [_|Tail], Tail) :- !.
hapus_kartu_index(N, [Head|Tail], [Head|TailSisa]) :-
    N > 1,
    N1 is N - 1,
    hapus_kartu_index(N1, Tail, TailSisa).


% kartu biasa
terapkan_efek(kartu(_, Jenis)) :-
    integer(Jenis),
    pindahGiliran.

% skip
terapkan_efek(kartu(_, skip)) :-
    nl, write('Pemain selanjutnya terkena Skip!'), nl,
    pindahGiliran, pindahGiliran.

% +2
terapkan_efek(kartu(_, drawtwo)) :-
    nl, write('Pemain selanjutnya terkena Draw Two!'), nl,
    pindahGiliran,
    giliran_sekarang(Korban),
    ambil_n_kartu(Korban, 2),
    pindahGiliran.

% wild (kartu hitam)
terapkan_efek(kartu(hitam, wild)) :-
    pilihWarnaBaru,
    pindahGiliran.

% +4
terapkan_efek(kartu(hitam, wildd4)) :-
    pilihWarnaBaru,
    nl, write('PERINGATAN: Pemain selanjutnya diancam +4! (Ketik "tantang." atau "ambilKartu.")'), nl,
    retractall(status_plus4(_)), asserta(status_plus4(aktif)),
    pindahGiliran.


% reverse
terapkan_efek(kartu(_, reverse)) :-
    nl, write('Arah permainan diputar balik!'), nl,
    ubahArah,
    pindahGiliran.

% milih warna buat efek hitam
pilihWarnaBaru :-
    repeat,
        nl, write('Silahkan memilih warna: '),
        read(WarnaBaru),
        ( member(WarnaBaru, [merah, kuning, hijau, biru]) ->
            retract(warna_aktif(_)),
            asserta(warna_aktif(WarnaBaru)), nl, !
        ;
            write('Warna tidak valid!'), nl, fail
        ).

ubahArah :-
    arah_permainan(kanan),
    retract(arah_permainan(kanan)),
    asserta(arah_permainan(kiri)), !.

ubahArah :-
    arah_permainan(kiri),
    retract(arah_permainan(kiri)),
    asserta(arah_permainan(kanan)), !.


%mekanika uni
uni(X) :-
    giliran_sekarang(Pemain),
    kartu_pemain(Pemain, ListKartu),
    length(ListKartu, Jumlah),
    ( Jumlah =:= 2 ->
        ( nth1(X, ListKartu, KartuPilihan) ->
            % Cek apakah kartu itu valid dimainkan di atas discard pile
            ( validasi_kartu(KartuPilihan) ->
                asserta(status_uni(Pemain)),
                nl, write(Pemain), write(' UNI!!!'), nl,
                mainkanKartu(X) ; nl, write('Kartu tidak valid! Warna atau jenisnya tidak cocok.'), nl) ;
            nl, write('Nomor kartu tidak valid atau tidak ada di tanganmu.'), nl)
    ;
        nl, write('Gagal! Perintah "uni(X)." HANYA bisa digunakan saat kartumu sisa 2.'), nl
    ).

% menangkap pemain belum uni
tangkap(Target) :-
    giliran_sekarang(Penuduh),
    kartu_pemain(Target, ListKartu),
    length(ListKartu, Jumlah),
    (Jumlah =:= 1 ->
        ( \+ status_uni(Target) ->
            nl, write('Tangkap BERHASIL! '), write(Target), write(' lupa bilang UNI.'), nl,
            write(Target), write(' terkena penalti 2 kartu!'), nl,
            ambil_n_kartu(Target, 2)
        ;
            nl, write('Tangkap SALAH! '), write(Target), write(' sudah teriak UNI.'), nl,
            write(Penuduh), write(' terkena penalti 1 kartu!'), nl,
            ambil_n_kartu(Penuduh, 1)
        )
    ;
        nl, write('Tangkap SALAH! Kartu milik '), write(Target), write(' tidak berjumlah 1.'), nl,
        write(Penuduh), write(' terkena penalti 1 kartu!'), nl,
        ambil_n_kartu(Penuduh, 1)
    ).

% menambahkan kartu secara custom (buat debugging doang)  
tambahKartu(Pemain, Warna, Jenis) :-
    kartu_pemain(Pemain, ListKartu),
    append(ListKartu, [kartu(Warna, Jenis)], ListBaru),
    retract(kartu_pemain(Pemain, ListKartu)),
    asserta(kartu_pemain(Pemain, ListBaru)).


%buat debugging (abisin kartu)
abisinKartu(Pemain):-
    retractall(kartu_pemain(Pemain, _)),
    asserta(kartu_pemain(Pemain, [])),
    nl, write('Kartu '), write(Pemain), write(' telah diset menjadi habis (0)!'), nl,
    cekEndGame.

% debugging uni
sisainDuaKartu(Pemain) :-
    retractall(kartu_pemain(Pemain, _)),
    asserta(kartu_pemain(Pemain, [kartu(hitam, wild), kartu(hitam, wildd4)])),
    nl, write('Kartu '), write(Pemain), write(' disisakan 2 kartu!'), nl.