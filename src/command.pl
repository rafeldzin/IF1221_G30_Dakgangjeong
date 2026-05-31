:- include('facts.pl').
:- include('endgame.pl').

lihatCommand :-
    nl,
    write('Aksi utama yang tersedia:'), nl,
    write('1. ambilKartu. -> draw kartu'), nl,
    write('2. mainkanKartu(slot). -> memainkan kartu dari tanganmu'), nl,
    write('3. uni(slot). -> melantangkan "uni" jika kartu bersisa 1'), nl,
    write('4. tangkap(player). -> menuduh player tidak mengatakan uni'), nl,
    write('5. tantang. -> menghindari kartu draw'), nl,
    write('6. sembunyikanKartu(slot). -> menyembunyikan kartu dari cekInfo (Bonus 3)'), nl,
    write('7. tampilkanKartu. -> mengembalikan kartu tersembunyi ke tangan (Bonus 3)'), nl,
    write('8. godsHand. -> memicu intervensi peluang acak (Bonus 1)'), nl,
    ( game_mode(turnamen) -> write('9. swapKartu(slot, slotTeman). -> menukar kartu dengan teman satu tim'), nl ; true ),
    nl,
    write('Aksi pendukung yang tersedia:'), nl,
    write('1. lihatCommand. -> semua command yang berlaku'), nl,
    write('2. lihatKartu. -> melihat kartu tangan'), nl,
    write('3. cekInfo. -> melihat kondisi meja permainan sekarang'), nl,
    write('4. saveGame. -> menyimpan status permainan ke dalam file'), nl,
    write('5. loadGame. -> memuat status permainan dari file'), nl,
    write('1. lihatCommand.'), nl,
    write('2. lihatKartu.'), nl,
    write('3. cekInfo.'), nl,
    nl.

lihatKartu :-
    giliran_sekarang(Pemain),
    kartu_pemain(Pemain, ListKartu),
    kartu_tersembunyi(Pemain, HiddenList),
    nl, write('Berikut kartu yang anda miliki.'), nl,
    print_daftar_kartu_all(ListKartu, 1, NextNo),
    print_daftar_kartu_hidden(HiddenList, NextNo, _),
    
    % --- BONUS 4: MODE TURNAMEN (LIHAT KARTU TEMAN TIM) ---
    ( game_mode(turnamen) ->
        cari_teman_tim(Pemain, Teman),
        kartu_pemain(Teman, ListKartuTeman),
        nl, write('Berikut kartu yang teman satu tim anda miliki ('), write(Teman), write(').'), nl,
        print_daftar_kartu_all(ListKartuTeman, 1, _)
    ;
        true
    ), !.

lihatKartu :-
    \+ giliran_sekarang(_),
    nl, write('Permainan belum dimulai! Silakan ketik startGame. terlebih dahulu.'), nl.

print_daftar_kartu_all([], Nomor, Nomor).
print_daftar_kartu_all([kartu(Warna, Jenis) | SisaKartu], Nomor, NextNo) :-
    write(Nomor), write('. '), write(Warna), write('-'), write(Jenis), nl,
    NomorSelanjutnya is Nomor + 1,
    print_daftar_kartu_all(SisaKartu, NomorSelanjutnya, NextNo).

print_daftar_kartu_hidden([], Nomor, Nomor).
print_daftar_kartu_hidden([kartu(Warna, Jenis) | SisaKartu], Nomor, FinalNo) :-
    write(Nomor), write('. '), write(Warna), write('-'), write(Jenis), write(' (TERSEMBUNYI)'), nl,
    NomorSelanjutnya is Nomor + 1,
    print_daftar_kartu_hidden(SisaKartu, NomorSelanjutnya, FinalNo).

cekInfo :-
    discard_pile(kartu(Warna, Jenis)),
    nl, write('Kartu discard top: '), write(Warna), write('-'), write(Jenis), write('.'), nl, nl,
    
    ( game_mode(turnamen) ->
        tim_sukses(tim1, [T1P1, T1P2]),
        tim_sukses(tim2, [T2P1, T2P2]),
        write('Tim 1 : '), write(T1P1), write(', '), write(T1P2), nl,
        write('Tim 2 : '), write(T2P1), write(', '), write(T2P2), nl, nl
    ;
        true
    ),
    
    urutan_pemain(Urutan),
    write('Urutan pemain: '), printUrutanInfo(Urutan), nl, nl,
    printPemainInfo(Urutan, 1).

printUrutanInfo([Pemain]) :- write(Pemain), write('.'), !.
printUrutanInfo([PemainH | PemainT]) :- write(PemainH), write(' - '), printUrutanInfo(PemainT).

printPemainInfo([], _).
printPemainInfo([PemainH | PemainT], Nomor) :-
    kartu_pemain(PemainH, ListKartu),
    get_length(ListKartu, JumlahKartu),
    write('Nama pemain '), write(Nomor), write(': '), write(PemainH), nl,
    write('Jumlah kartu : '), write(JumlahKartu), nl, nl,
    NomorSelanjutnya is Nomor + 1,
    printPemainInfo(PemainT, NomorSelanjutnya).

mainkanKartu(X) :-
    ( status_plus4(aktif) ->
        nl, write('Anda sedang terkena efek +4! Anda HANYA BISA mengetik "tantang." or "ambilKartu."'), nl
    ;
        giliran_sekarang(Pemain),
        kartu_pemain(Pemain, ListKartu),
        ( get_element_1based(ListKartu, X, KartuPilihan) ->
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
                
                retractall(discard_pile(_)),
                asserta(discard_pile(KartuPilihan)),
                retractall(warna_aktif(_)),
                asserta(warna_aktif(Warna)),
                
                nl, write(Pemain), write(' memainkan kartu: '), write(Warna), write('-'), write(Jenis), write('.'), nl,
                cekEndGame,
                catat_kartu_aksi(KartuPilihan),
                terapkan_efek(KartuPilihan), !
            ;
                ( KartuPilihan = kartu(hitam, wildd4), discard_pile(kartu(hitam, wildd4)) -> true 
                ; nl, write('Kartu tidak valid! Warna atau jenisnya tidak cocok dengan kartu di meja.'), nl )
            )
        ;
            nl, write('Nomor kartu tidak valid atau tidak ada di tanganmu.'), nl
        )
    ).

% VALIDASI KARTU
validasi_kartu(kartu(hitam, wildd4)) :- 
    discard_pile(kartu(hitam, wildd4)), 
    nl, write('PELANGGARAN: Kartu Wild Draw Four tidak boleh ditumpuk di atas Wild Draw Four lainnya!'), nl, !, fail.
validasi_kartu(kartu(hitam, mimic)) :- !.
validasi_kartu(kartu(Warna, _)):- warna_aktif(Warna), !.
validasi_kartu(kartu(_, Jenis)) :- discard_pile(kartu(_, Jenis)), !.
validasi_kartu(kartu(hitam, _)):- !.

hapus_kartu_index(1, [_|Tail], Tail) :- !.
hapus_kartu_index(N, [Head|Tail], [Head|TailSisa]) :-
    N > 1, N1 is N - 1, hapus_kartu_index(N1, Tail, TailSisa).

% EFECTS INTERPRETATION
terapkan_efek(kartu(_, Jenis)) :- integer(Jenis), pindahGiliran.
terapkan_efek(kartu(_, skip)) :- nl, write('Pemain selanjutnya terkena Skip!'), nl, pindahGiliran, pindahGiliran.
terapkan_efek(kartu(_, drawtwo)) :-
    nl, write('Pemain selanjutnya terkena Draw Two!'), nl,
    pindahGiliran, giliran_sekarang(Korban), ambil_n_kartu(Korban, 2), pindahGiliran.
terapkan_efek(kartu(hitam, wild)) :- pilihWarnaBaru, pindahGiliran.
terapkan_efek(kartu(hitam, wildd4)) :-
    pilihWarnaBaru,
    nl, write('PERINGATAN: Pemain selanjutnya diancam +4! (Ketik "tantang." atau "ambilKartu.")'), nl,
    retractall(status_plus4(_)), asserta(status_plus4(aktif)),
    pindahGiliran.
terapkan_efek(kartu(_, reverse)) :- nl, write('Arah permainan diputar balik!'), nl, ubahArah, pindahGiliran.
terapkan_efek(kartu(hitam, mimic)) :-
    kartu_aksi_terakhir(KartuAksi),
    ( KartuAksi == none ->
        nl, write('Belum ada kartu aksi sebelumnya! Mimic Card berubah menjadi Wild biasa.'), nl,
        pilihWarnaBaru, pindahGiliran
    ;
        KartuAksi = kartu(WarnaAksi, JenisAksi),
        nl, write('Menelusuri riwayat permainan.'), nl,
        write('Kartu aksi terakhir yang dimainkan: '), write(WarnaAksi), write('-'), write(JenisAksi), nl,
        write('Kartu mimic menyalin efek '), write(JenisAksi), write('!'), nl,
        ( JenisAksi == skip -> pindahGiliran, pindahGiliran
        ; JenisAksi == reverse -> ubahArah, pindahGiliran
        ; JenisAksi == drawtwo -> pindahGiliran, giliran_sekarang(Korban), ambil_n_kartu(Korban, 2), pindahGiliran
        ; JenisAksi == wild -> pilihWarnaBaru, pindahGiliran
        ; JenisAksi == wildd4 -> pilihWarnaBaru, nl, write('PERINGATAN: Pemain selanjutnya diancam +4!'), nl, retractall(status_plus4(_)), asserta(status_plus4(aktif)), pindahGiliran
        )
    ).

pilihWarnaBaru :-
    repeat,
        nl, write('Silahkan memilih warna baru (merah/kuning/hijau/biru): '),
        read(WarnaBaru),
        ( my_member(WarnaBaru, [merah, kuning, hijau, biru]) ->
            retractall(warna_aktif(_)), asserta(warna_aktif(WarnaBaru)), nl, !
        ; write('Warna tidak valid! Pastikan menggunakan huruf kecil.'), nl, fail ).

ubahArah :- arah_permainan(kanan), retractall(arah_permainan(_)), asserta(arah_permainan(kiri)), !.
ubahArah :- arah_permainan(kiri), retractall(arah_permainan(_)), asserta(arah_permainan(kanan)), !.

uni(X) :-
    giliran_sekarang(Pemain),
    kartu_pemain(Pemain, ListKartu),
    get_length(ListKartu, Jumlah), 
    ( Jumlah =:= 2 ->
        ( get_element_1based(ListKartu, X, KartuPilihan) -> 
            ( validasi_kartu(KartuPilihan) ->
                asserta(status_uni(Pemain)),
                nl, write(Pemain), write(' UNI!!!'), nl,
                mainkanKartu(X), !
            ; ( KartuPilihan = kartu(hitam, wildd4), discard_pile(kartu(hitam, wildd4)) -> true 
              ; nl, write('Kartu tidak valid! Warna atau jenisnya tidak cocok.'), nl ) ) 
        ; nl, write('Nomor kartu tidak valid atau tidak ada di tanganmu.'), nl )
    ; nl, write('Gagal! Perintah "uni(X)." HANYA bisa digunakan saat kartumu sisa 2.'), nl ).

tangkap(Target) :-
    giliran_sekarang(Penuduh),
    kartu_tersembunyi(Target, HiddenList),
    ( HiddenList \= [] ->
        nl, write('Terdapat kartu yang disembunyikan oleh '), write(Target), write('.'), nl,
        write('Perintah tangkap tidak valid. '), write(Penuduh), write(' mendapatkan 1 kartu penalti.'), nl,
        ambil_n_kartu(Penuduh, 1), pindahGiliran
    ;
        kartu_pemain(Target, ListKartu),
        get_length(ListKartu, Jumlah),
        (Jumlah =:= 1 ->
            ( \+ status_uni(Target) ->
                nl, write('Tangkap BERHASIL! '), write(Target), write(' lupa bilang UNI.'), nl,
                write(Target), write(' terkena penalti 2 kartu!'), nl,
                ambil_n_kartu(Target, 2), pindahGiliran
            ;   nl, write('Tangkap SALAH! '), write(Target), write(' sudah teriak UNI.'), nl,
                write(Penuduh), write(' terkena penalti 1 kartu!'), nl,
                ambil_n_kartu(Penuduh, 1), pindahGiliran )
        ;   nl, write('Tangkap SALAH! Kartu milik '), write(Target), write(' tidak berjumlah 1.'), nl,
            write(Penuduh), write(' terkena penalti 1 kartu!'), nl,
            ambil_n_kartu(Penuduh, 1), pindahGiliran )
    ).

% BONUS 2: MIMIC ENGINE
catat_kartu_aksi(Kartu) :-
    Kartu = kartu(_, Jenis),
    ( my_member(Jenis, [skip, reverse, drawtwo, wild, wildd4]) ->
        retractall(kartu_aksi_terakhir(_)), asserta(kartu_aksi_terakhir(Kartu)) ; true ).

% BONUS 1: GOD'S HAND INTERVENTION
godsHand :-
    ( cek_semua_satu_kartu ->
        nl, write('Mekanisme batal. Semua pemain hanya memiliki satu kartu untuk menjaga keseimbangan.'), nl
    ;
        random(1, 101, Peluang),
        ( Peluang =< 20 -> eksekusi_gods_hand
        ; nl, write('Tuhan sedang tidak ingin campur tangan. Tidak terjadi apa-apa.'), nl, pindahGiliran )
    ).

cek_semua_satu_kartu :- urutan_pemain(List), cek_satu_kartu_loop(List).
cek_satu_kartu_loop([]).
cek_satu_kartu_loop([P|T]) :- kartu_pemain(P, K), get_length(K, 1), cek_satu_kartu_loop(T).

eksekusi_gods_hand :-
    urutan_pemain(ListPemain),
    ambil_pemain_random_ada_kartu(ListPemain, PemainAsal),
    kartu_pemain(PemainAsal, KartuAsal),
    get_length(KartuAsal, Len), random(0, Len, Idx), 
    ambil_dan_hapus_nth0(Idx, KartuAsal, KartuPindahan, SisaKartuAsal),
    hapus_elemen(PemainAsal, ListPemain, CalonTujuan),
    get_length(CalonTujuan, LenTujuan), random(0, LenTujuan, IdxTujuan), 
    ambil_dan_hapus_nth0(IdxTujuan, CalonTujuan, PemainTujuan, _),
    
    retract(kartu_pemain(PemainAsal, KartuAsal)), asserta(kartu_pemain(PemainAsal, SisaKartuAsal)),
    kartu_pemain(PemainTujuan, KartuTujuanLama), append_element(KartuTujuanLama, KartuPindahan, KartuTujuanBaru),
    retract(kartu_pemain(PemainTujuan, KartuTujuanLama)), asserta(kartu_pemain(PemainTujuan, KartuTujuanBaru)),
    
    nl, write('Tuhan telah berkehendak.'), nl,
    KartuPindahan = kartu(W, J),
    write('Kartu '), write(W), write('-'), write(J), write(' milik '), write(PemainAsal), write(' berpindah ke tangan '), write(PemainTujuan), write('!'), nl,
    cekEndGame, pindahGiliran.

ambil_pemain_random_ada_kartu(List, Pemain) :-
    get_length(List, Len), random(0, Len, Idx), ambil_dan_hapus_nth0(Idx, List, P, _), 
    kartu_pemain(P, K), get_length(K, L), ( L > 0 -> Pemain = P ; ambil_pemain_random_ada_kartu(List, Pemain) ).

ambil_dan_hapus_nth0(0, [H|T], H, T) :- !.
ambil_dan_hapus_nth0(N, [H|T], Elem, [H|Sisa]) :- N > 0, N1 is N - 1, ambil_dan_hapus_nth0(N1, T, Elem, Sisa).
hapus_elemen(_, [], []).
hapus_elemen(X, [X|T], T) :- !.
hapus_elemen(X, [H|T], [H|T2]) :- hapus_elemen(X, T, T2).

% BONUS 3: HIDDEN CARD CORE MECHANICS
sembunyikanKartu(X) :-
    giliran_sekarang(Pemain),
    kartu_pemain(Pemain, ListKartu),
    kartu_tersembunyi(Pemain, HiddenList),
    get_length(ListKartu, TotalVisible), 
    get_length(HiddenList, TotalHidden),
    TotalTotal is TotalVisible + TotalHidden,
    ( TotalTotal =< 1 ->
        nl, write('Gagal! Perintah ini tidak berlaku jika pemain hanya memiliki satu buah kartu.'), nl
    ;
        ( get_element_1based(ListKartu, X, KartuPilihan) -> 
            hapus_kartu_index(X, ListKartu, SisaKartu),
            retract(kartu_pemain(Pemain, ListKartu)), asserta(kartu_pemain(Pemain, SisaKartu)),
            append_element(HiddenList, KartuPilihan, NewHiddenList), 
            retractall(kartu_tersembunyi(Pemain, _)), asserta(kartu_tersembunyi(Pemain, NewHiddenList)),
            KartuPilihan = kartu(W, J),
            nl, write('Kartu '), write(W), write('-'), write(J), write(' berhasil disembunyikan.'), nl
        ;   nl, write('Nomor kartu tidak valid.'), nl )
    ).

tampilkanKartu :-
    giliran_sekarang(Pemain),
    kartu_pemain(Pemain, ListKartu),
    kartu_tersembunyi(Pemain, HiddenList),
    ( HiddenList == [] -> nl, write('Tidak ada kartu yang sedang disembunyikan.'), nl
    ;
        get_length(ListKartu, TotalVisible),
        get_length(HiddenList, TotalHidden),
        TotalTotal is TotalVisible + TotalHidden,
        ( TotalTotal =< 1 -> nl, write('Gagal! Perintah ini tidak berlaku jika pemain hanya memiliki satu buah kartu.'), nl
        ;   append_list(ListKartu, HiddenList, NewListKartu),
            retract(kartu_pemain(Pemain, ListKartu)), asserta(kartu_pemain(Pemain, NewListKartu)),
            retractall(kartu_tersembunyi(Pemain, _)), asserta(kartu_tersembunyi(Pemain, [])),
            nl, write('Semua kartu yang tersembunyi berhasil ditampilkan kembali ke tangan.'), nl )
    ).

% BONUS 4: TOURNAMENT MODE SWAP LOGIC
swapKartu(X, Y) :-
    ( \+ game_mode(turnamen) -> nl, write('Perintah ini hanya tersedia pada Mode Turnamen!'), nl
    ; status_swap(sudah) -> nl, write('Gagal! Anda hanya bisa menukar kartu sekali dalam satu giliran.'), nl
    ;
        giliran_sekarang(Pemain),
        cari_teman_tim(Pemain, Teman),
        kartu_pemain(Pemain, ListKartu),
        kartu_pemain(Teman, ListKartuTeman),
        get_length(ListKartu, LenP), get_length(ListKartuTeman, LenT),
        ( (LenP =< 1 ; LenT =< 1) ->
            nl, write('Gagal! Pertukaran tidak dapat dilakukan jika salah satu pemain hanya memiliki satu kartu.'), nl
        ;
            ( get_element_1based(ListKartu, X, KartuP), get_element_1based(ListKartuTeman, Y, KartuT) ->
                hapus_kartu_index(X, ListKartu, SisaP),
                append_element(SisaP, KartuT, BaruP),
                retract(kartu_pemain(Pemain, ListKartu)), asserta(kartu_pemain(Pemain, BaruP)),
                
                hapus_kartu_index(Y, ListKartuTeman, SisaT),
                append_element(SisaT, KartuP, BaruT),
                retract(kartu_pemain(Teman, ListKartuTeman)), asserta(kartu_pemain(Teman, BaruT)),
                
                retractall(status_swap(_)), asserta(status_swap(sudah)),
                nl, write(Pemain), write(' menukar kartu '),
                KartuP = kartu(WP, JP), write(WP), write('-'), write(JP), write(' dengan kartu '),
                KartuT = kartu(WT, JT), write(WT), write('-'), write(JT), write(' milik '), write(Teman), write('.'), nl,
                write('Pertukaran kartu berhasil.'), nl,
                pindahGiliran
            ;
                nl, write('Nomor urut kartu tidak valid!'), nl
            )
        )
    ).

cari_teman_tim(Pemain, Teman) :-
    tim_sukses(_, [P1, P2]), (Pemain == P1 -> Teman = P2 ; Pemain == P2 -> Teman = P1), !.

tambahKartu(Pemain, Warna, Jenis) :-
    kartu_pemain(Pemain, ListKartu),
    append_element(ListKartu, kartu(Warna, Jenis), ListBaru), 
    retract(kartu_pemain(Pemain, ListKartu)), asserta(kartu_pemain(Pemain, ListBaru)).

abisinKartu(Pemain):-
    retractall(kartu_pemain(Pemain, _)), asserta(kartu_pemain(Pemain, [])),
    nl, write('Kartu '), write(Pemain), write(' telah diset menjadi habis (0)!'), nl, cekEndGame.

sisainDuaKartu(Pemain) :-
    retractall(kartu_pemain(Pemain, _)), asserta(kartu_pemain(Pemain, [kartu(hitam, wild), kartu(hitam, wildd4)])),
    nl, write('Kartu '), write(Pemain), write(' disisakan 2 kartu!'), nl.

help:-
    lihatCommand.