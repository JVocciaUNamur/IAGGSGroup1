/*---------------------------------------------------------*/
/* Extraction des mot clés et standardization de la phrase */
/*---------------------------------------------------------*/
:- [vins].
:- [common].

% operateurs.pl

:- discontiguous heuristique/2.

heuristique('bourgognes', 'bourgogne').
heuristique('prixs', 'prix').
heuristique('bouches', 'bouche').
heuristique('nezs', 'nez').
heuristique('descriptions', 'description').
heuristique('noels', 'noel').
heuristique('canards', 'canard').
heuristique('gravess', 'graves').
heuristique('hauts', 'haut').
heuristique('coteaux bourguignons', 'bourgogne').
heuristique('rosé', 'rose').
heuristique('vins', 'vin').
heuristique('vin\'s', 'vin').
heuristique('vín', 'vin').
heuristique('bouchées', 'bouche').
heuristique('dispo', 'disponible').
heuristique('en_stock', 'disponible').

% Nettoie les mots inutiles
nettoyer_mots([], []).
nettoyer_mots([Mot|Reste], [MotNettoye|ResteNettoyes]) :-
    downcase_atom(Mot, MotMinuscule),
    atom_codes(MotMinuscule, Codes),
    include(code_utilisable, Codes, CodesUtilisables),
    atom_codes(MotNettoye, CodesUtilisables),
    atom_length(MotNettoye, LM),
    LM > 0,
    nettoyer_mots(Reste, ResteNettoyes).
nettoyer_mots([_ | Rest], ResteNettoyes) :- nettoyer_mots(Rest, ResteNettoyes).

code_utilisable(Code) :- char_type(Char, alnum), char_code(Char, Code).

% Appliquer les heuristiques pour corriger les mots et gérer les synonymes
harmoniser_mots([], []).
harmoniser_mots([Mot|Reste], [MotCorrige|ResteCorrige]) :-
    (   heuristique(Mot, MotCorrige) ; MotCorrige = Mot),
    harmoniser_mots(Reste, ResteCorrige).

standardise_nom_vin([], []).
standardise_nom_vin(Lmots, [NomCorrige | LCorrige]) :-
    nom(_, NomVin),
    maplist(downcase_atom, NomVin, NomVinLower),
    next_nom_vin(Lmots, NomVinLower, LRest),!,
    atomic_list_concat(NomVinLower, '_', NomCorrige),
    standardise_nom_vin(LRest, LCorrige).
standardise_nom_vin([M | LRest], [M | LCorrige]) :-
    standardise_nom_vin(LRest, LCorrige).

next_nom_vin(Rest, [], Rest).
next_nom_vin([X | T], [X | L], R) :-
    next_nom_vin(T, L, R).
