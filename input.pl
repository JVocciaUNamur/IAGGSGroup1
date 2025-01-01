/*-------------------------------------------*/
/* Extraction des mot clés et standardization de la phrase*/
/*-------------------------------------------*/
:- [vins].
:- [common].

mcle('vin', 100).
mcle('prix', 100).
mcle('annee', 100).
mcle('bouche', 100).
mcle('nez', 100).
mcle('localite', 100).
mcle('robe', 100).
mcle('de', 100).
mcle('accompagner', 100).
mcle(Appelation, 200) :- appelation(_, Appelation).
mcle(Couleur, 200) :- couleur(_, Couleur).

est_mcle(Mot) :- mcle(Mot, _).
trouve_mot_cle(Mot, Mot) :- est_mcle(Mot).
trouve_mot_cle(Mot, MotCle) :-
    atom_string(Mot, StrMot),
    findall(Dist-M, (
        mcle(M, _), 
        atom_string(M, StrMcle), 
        distance_ignore_case(StrMot, StrMcle, Dist),
        string_length(StrMcle, LongueurMot),
        MDist is min(LongueurMot - 1, 2),
        Dist < MDist), 
    Distances),
    sort(Distances, DistancesOrdonnees),
    DistancesOrdonnees = [_-MotCle|_].
    
corrige_phrase([], []).
corrige_phrase([Mot | Lmots], [Mcle | LCorrige]) :- 
    trouve_mot_cle(Mot, Mcle),
    !,
    corrige_phrase(Lmots, LCorrige).

corrige_phrase([Mot | Lmots], [Mot | LCorrige]) :- 
    corrige_phrase(Lmots, LCorrige).

extract_mcle(Lmots, Result) :-
    findall(Importance-MotCle,
        (member(Mot, Lmots), trouve_mot_cle(Mot, MotCle), mcle(MotCle, Importance)),
    MotCles),
    sort(MotCles, MotClesOrdonne),
    findall(Mot, member(_-Mot, MotClesOrdonne), Result),
    write('Mot cle ordonnes: '), writeln(Result).

