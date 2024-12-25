:- [heuristiques].
:- [synonymes].
:- [levenshtein].
:- [vins].


% Liste des mots-bruit
mot_bruit("quel").
mot_bruit("quels").
mot_bruit("le").
mot_bruit('sont').
mot_bruit("la").
mot_bruit("les").
mot_bruit("des").
mot_bruit("un").
mot_bruit("une").
mot_bruit("pour").
mot_bruit("avec").
mot_bruit("de").
mot_bruit("du").
% mot_bruit("et").
mot_bruit('disponibles').
mot_bruit('?').

% Filtrer les mots-bruit d'une question
filtrer_mots_bruit([], []).
filtrer_mots_bruit([Mot|Reste], Filtre) :-
    mot_bruit(Mot),
    !,
    filtrer_mots_bruit(Reste, Filtre).
filtrer_mots_bruit([Mot|Reste], [Mot|FiltreReste]) :-
    filtrer_mots_bruit(Reste, FiltreReste).
	
% Filtrer et préparer la question
preparer_question(Question, QuestionPreparee) :-
    filtrer_mots_bruit(Question, QuestionFiltre),
    appliquer_heuristiques(QuestionFiltre, QuestionCorrigee),
    appliquer_synonymes(QuestionCorrigee, QuestionPreparee).

% Identifier un vin mentionné dans une question
identifier_vin(Question, NomVin, Tolerance) :-
    maplist(canonicaliser_mot, Question, CanonicalQuestion),
    trouver_meilleure_correspondance(CanonicalQuestion, NomVin, Tolerance).

% Vérifier si chaque mot de la question correspond à au moins un mot du vin
tous_mots_present_tolerant([], _).
tous_mots_present_tolerant([MotQ|ResteQ], MotsVin) :-
    findall(Distance, (member(MotV, MotsVin), levenshtein(MotQ, MotV, Distance)), Distances),
    min_list(Distances, MinDistance),
    write('Mot question : '), write(MotQ), write(', Distances : '), write(Distances), write(', Min : '), write(MinDistance), nl,
    MinDistance =< 2,  % Tolérance stricte par mot
    tous_mots_present_tolerant(ResteQ, MotsVin).

% Trouver la meilleure correspondance parmi les noms
touver_meilleure_correspondance(Question, MeilleurVin, Tolerance) :-
    write('Question analysée : '), write(Question), nl,
    findall(
        [Distance, NomVin],
        (nom(_, NomVin),
         normaliser_nom(NomVin, NomVinNormalise),
         write('Nom vin normalisé : '), write(NomVinNormalise), nl,
         split_string(NomVinNormalise, " ", "", NomVinMots),
         (tous_mots_present_tolerant(Question, NomVinMots) ->
            somme_distances_par_mot(Question, NomVinMots, Distance)
         ;
            fail),
         write('Distance calculée pour : '), write(NomVin), write(' -> '), write(Distance), nl,
         Distance =< Tolerance),
        Correspondances
    ),
    (Correspondances \= [] ->
        sort(Correspondances, [[_, MeilleurVin]|_])
    ; write('Aucune correspondance trouvée.'), nl, fail).

% Calculer les distances avec tolérance par mot
somme_distances_par_mot([], [], 0).
somme_distances_par_mot([MotQ|ResteQ], MotsVin, TotalDistance) :-
    findall(Distance, (member(MotV, MotsVin), levenshtein(MotQ, MotV, Distance)), Distances),
    min_list(Distances, MinDistance),
    write('Mot question : '), write(MotQ), write(', Distances : '), write(Distances), write(', Min : '), write(MinDistance), nl,
    (MinDistance =< 2 ->
        somme_distances_par_mot(ResteQ, MotsVin, ResteDistance),
        TotalDistance is MinDistance + ResteDistance
    ;
        fail).

% Générer une réponse
produire_reponse(Question, Reponse) :-
    preparer_question(Question, QuestionPreparee),
    write('Question préparée : '), write(QuestionPreparee), nl,
    identifier_vin(QuestionPreparee, NomVin, 5),  % Appel de la fonction
    !,
    prix_du_vin_par_nom(NomVin, Prix),
    format(atom(ReponseTexte), "Le vin '~w' coûte ~w par bouteille.", [NomVin, Prix]),
    Reponse = [ReponseTexte].
produire_reponse(_, [["Je suis désolé, je ne trouve pas d'information sur ce vin."]]).
