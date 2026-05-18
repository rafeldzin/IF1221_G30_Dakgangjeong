:- include('facts.pl').
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
    giliran_sekarang(Pemain),
    kartu_pemain(Pemain, ListKartu),
    
    ( nth1(X, ListKartu, KartuPilihan) ->
        
        ( validasi_kartu(KartuPilihan) ->
            KartuPilihan = kartu(Warna, Jenis),
            
            hapus_kartu_index(X, ListKartu, SisaKartu),
            retract(kartu_pemain(Pemain, ListKartu)),
            asserta(kartu_pemain(Pemain, SisaKartu)),
            
            warna_aktif(WarnaLama),
            retractall(warna_sebelumnya(_)),
            asserta(warna_sebelumnya(WarnaLama)),
            
            retractall(pemain_sebelumnya(_)),
            asserta(pemain_sebelumnya(Pemain)),
            
            retract(discard_pile(_)),
            asserta(discard_pile(KartuPilihan)),
            
            ( Warna == hitam ->
                nl, write('Kamu mengeluarkan kartu spesial!'), nl,
                repeat,
                    write('Pilih warna aktif baru (merah/kuning/hijau/biru): '),
                    read(WarnaBaru),
                    ( member(WarnaBaru, [merah, kuning, hijau, biru]) ->
                        true, !
                    ;
                        write('Warna tidak valid! Ketik dengan huruf kecil, contoh: merah.'), nl, fail
                    ),
                retractall(warna_aktif(_)),
                asserta(warna_aktif(WarnaBaru)),
                nl, write(Pemain), write(' memainkan kartu: hitam-'), write(Jenis), nl,
                write(Pemain), write(' mengubah warna aktif menjadi: '), write(WarnaBaru), write('.'), nl
            ;
                retractall(warna_aktif(_)),
                asserta(warna_aktif(Warna)),
                nl, write(Pemain), write(' memainkan kartu: '), write(Warna), write('-'), write(Jenis), write('.'), nl
            ),
            
            ( Jenis == skip ->
                pindahGiliran_skip
            ; Jenis == reverse ->
                balikArah,
                pindahGiliran
            ; Jenis == drawtwo ->
    
                aplikasi_draw_two,
                pindahGiliran_skip
          ; Jenis == wildd4 ->
                aplikasi_wild_draw_four,
                pindahGiliran
            ;
                pindahGiliran
            )
            
        ;
            nl, write('Kartu tidak valid! Warna atau jenisnya tidak cocok dengan kartu di meja.'), nl
        )
    ;
        nl, write('Nomor kartu tidak valid atau tidak ada di tanganmu.'), nl
    ).

validasi_kartu(kartu(Warna, _)) :- warna_aktif(Warna).
validasi_kartu(kartu(_, Jenis)) :- discard_pile(kartu(_, Jenis)).
validasi_kartu(kartu(hitam, _)).
hapus_kartu_index(1, [_|Tail], Tail) :- !.
hapus_kartu_index(N, [Head|Tail], [Head|TailSisa]) :-
    N > 1,
    N1 is N - 1,
    hapus_kartu_index(N1, Tail, TailSisa).
    
balikArah :-
    arah_permainan(ArahSaatIni),
    ( ArahSaatIni == kanan -> ArahBaru = kiri ; ArahBaru = kanan ),
    retract(arah_permainan(ArahSaatIni)),
    asserta(arah_permainan(ArahBaru)),
    write('Arah permainan berbalik menjadi '), write(ArahBaru), write('!'), nl.

pindahGiliran_skip :-
    giliran_sekarang(PemainSekarang),
    urutan_pemain(ListPemain),
    cari_next_sesuai_arah(PemainSekarang, ListPemain, KorbanSkip),
    cari_next_sesuai_arah(KorbanSkip, ListPemain, PemainAsli),
    retract(giliran_sekarang(PemainSekarang)),
    asserta(giliran_sekarang(PemainAsli)),
    nl, write(KorbanSkip), write(' dilewati! Sekarang giliran '), write(PemainAsli), write('.'), nl.

aplikasi_draw_two :-
    urutan_pemain(ListPemain),
    giliran_sekarang(PemainSekarang),
    cari_next_sesuai_arah(PemainSekarang, ListPemain, Korban),
    nl, write('*** EFEK DRAW TWO! ***'), nl,
    write(Korban), write(' harus mengambil 2 kartu penalti!'), nl,
    ambil_n_kartu(Korban, 2).

aplikasi_wild_draw_four :-
    urutan_pemain(ListPemain),
    giliran_sekarang(PemainSekarang),
    cari_next_sesuai_arah(PemainSekarang, ListPemain, Korban),
    nl, write('*** EFEK WILD DRAW FOUR! ***'), nl,
    write(Korban), write(' dapat mengetikkan "tantang." atau otomatis mengambil 4 kartu di gilirannya.'), nl.

cari_next_sesuai_arah(Pemain, ListPemain, NextPemain) :-
    ( arah_permainan(kiri) ->
        reverse(ListPemain, ListReversed),
        next_player(Pemain, ListReversed, NextPemain)
    ;
        next_player(Pemain, ListPemain, NextPemain)
    ).