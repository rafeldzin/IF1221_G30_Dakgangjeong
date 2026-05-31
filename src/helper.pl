%file helper buat fungsi yang terkendala constrait praktikum

% dari handbook
append_element([], Element, [Element]).
append_element([Head|Tail], Element, [Head|NewTail]) :-
    append_element(Tail, Element, NewTail).

get_length([], 0).
get_length([_|Tail], Length) :-
    get_length(Tail, TailLength),
    Length is TailLength + 1.

get_element([Element|_], 0, Element).
get_element([_|Tail], Index, Element) :-
    Index > 0,
    NewIndex is Index - 1,
    get_element(Tail, NewIndex, Element).

reverse_list(List, Reversed) :-
    reverse_helper(List, [], Reversed).
reverse_helper([], Accumulator, Accumulator).
reverse_helper([Head|Tail], Accumulator, Reversed) :-
    reverse_helper(Tail, [Head|Accumulator], Reversed).

% pengganti append
append_list([], L, L).
append_list([H|T], L, [H|R]) :- append_list(T, L, R).

% pengganti nth1
get_element_1based(List, Index, Element) :-
    Index > 0,
    Idx0 is Index - 1,
    get_element(List, Idx0, Element).

% pengganti member
my_member(X, [X|_]).
my_member(X, [_|T]) :- my_member(X, T).

% pengganti keysort
my_keysort([], []).
my_keysort([H|T], Sorted) :-
    my_keysort(T, SortedT),
    insert_key(H, SortedT, Sorted).

insert_key(K-V, [], [K-V]).
insert_key(K1-V1, [K2-V2|T], [K1-V1,K2-V2|T]) :- K1 =< K2, !.
insert_key(K1-V1, [K2-V2|T], [K2-V2|R]) :-
    insert_key(K1-V1, T, R).