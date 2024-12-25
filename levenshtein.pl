% levenshtein.pl

:- dynamic memo_levenshtein/3.

% Ajout pour gérer les chaînes directement
levenshtein(Str1, Str2, Distance) :-
    string(Str1),
    string(Str2),
    string_chars(Str1, List1),  % Convertir la chaîne en liste de caractères
    string_chars(Str2, List2),
    levenshtein(List1, List2, Distance).

% Cas de base : deux listes vides
levenshtein([], [], 0).

% Cas : une liste vide et une liste non vide
levenshtein([_|Tail1], [], N) :-
    levenshtein(Tail1, [], M),
    N is M + 1.
levenshtein([], [_|Tail2], N) :-
    levenshtein([], Tail2, M),
    N is M + 1.

% Cas : premier élément des deux listes identique
levenshtein([H1|Tail1], [H2|Tail2], N) :-
    H1 == H2,
    levenshtein(Tail1, Tail2, M),
    N is M.

% Cas : premier élément des deux listes différent
levenshtein([H1|Tail1], [H2|Tail2], N) :-
    H1 \== H2,
    (memo_levenshtein([H1|Tail1], [H2|Tail2], M1) ->
        true
    ;
        levenshtein(Tail1, [H2|Tail2], M1),
        assertz(memo_levenshtein([H1|Tail1], [H2|Tail2], M1))
    ),
    (memo_levenshtein([H1|Tail1], Tail2, M2) ->
        true
    ;
        levenshtein([H1|Tail1], Tail2, M2),
        assertz(memo_levenshtein([H1|Tail1], Tail2, M2))
    ),
    (memo_levenshtein(Tail1, Tail2, M3) ->
        true
    ;
        levenshtein(Tail1, Tail2, M3),
        assertz(memo_levenshtein(Tail1, Tail2, M3))
    ),
    N is min(M1, min(M2, M3)) + 1.
