%common operators
% retourne l'index I de l'élément E dans la liste L
indexOf(E, [E | _], 0).
indexOf(E, [_ | L], J) :- indexOf(E, L, I), J is I + 1. 

% retourne les N premiers elements de la liste L
take(0, _, []).
take(_, [], []).
take(N, [H|T], [H|L2]) :-
    N > 0,
    N1 is N - 1,
    take(N1, T, L2).
 
% retourne les length(L) - N derniers elements de la liste.
skip(0, List, List).
skip(_, [], []).
skip(N, [_|Tail], Result) :-
    N > 0,
    N1 is N - 1,
    skip(N1, Tail, Result).
% skip les N premiers elements de la liste L

% trie une liste de liste sur base d'une column spécifiée par un index
columnSort(InputList, Order, Index, SortedList) :-
    findall(Key-Row, (member(Row, InputList), nth0(Index, Row, Key)), DecoratedList),
    sort(DecoratedList, SortedDecoratedList),
    (   Order = ascending
    ->  SortedDecoratedList = OrderedDecoratedList
    ;   Order = descending
    ->  reverse(SortedDecoratedList, OrderedDecoratedList)
    ),
    findall(Row, member(_-Row, OrderedDecoratedList), SortedList).

:- dynamic memo_distance/3.

%calcule la distance entre Str1 et Str2, ignore la casse.
distance_ignore_case(Str1, Str2, Distance) :-
    string_lower(Str1, LowerStr1),
    string_lower(Str2, LowerStr2),
    distance(LowerStr1, LowerStr2, Distance).

% calcule la distance entre 2 mots
distance(Str1, Str2, Distance) :-
    string(Str1),
    string(Str2),
    string_chars(Str1, List1),  % Convertir la chaîne en liste de caractères
    string_chars(Str2, List2),
    distance(List1, List2, Distance).

% Cas de base : deux listes vides
distance([], [], 0).

% Cas : une liste vide et une liste non vide
distance([_|Tail1], [], N) :-
    distance(Tail1, [], M),
    N is M + 1.
distance([], [_|Tail2], N) :-
    distance([], Tail2, M),
    N is M + 1.

% Cas : premier élément des deux listes identique
distance([H1|Tail1], [H2|Tail2], N) :-
    H1 == H2,
    distance(Tail1, Tail2, M),
    N is M.

% Cas : premier élément des deux listes différent
distance([H1|Tail1], [H2|Tail2], N) :-
    H1 \== H2,
    (memo_distance([H1|Tail1], [H2|Tail2], M1) ->
        true
    ;
        distance(Tail1, [H2|Tail2], M1),
        assertz(memo_distance([H1|Tail1], [H2|Tail2], M1))
    ),
    (memo_distance([H1|Tail1], Tail2, M2) ->
        true
    ;
        distance([H1|Tail1], Tail2, M2),
        assertz(memo_distance([H1|Tail1], Tail2, M2))
    ),
    (memo_distance(Tail1, Tail2, M3) ->
        true
    ;
        distance(Tail1, Tail2, M3),
        assertz(memo_distance(Tail1, Tail2, M3))
    ),
    N is min(M1, min(M2, M3)) + 1.
