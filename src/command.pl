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
            
            retract(discard_pile(_)),
            asserta(discard_pile(KartuPilihan)),
            retract(warna_aktif(_)),
            asserta(warna_aktif(Warna)),
            
            nl, write(Pemain), write(' memainkan kartu: '), write(Warna), write('-'), write(Jenis), write('.'), nl,
            
            
            nl, pindahGiliran
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