% extraction_mots_cles.pl

:- [heuristiques].
:- [synonymes].
:- [levenshtein].
:- [operateurs].

% Appliquer les heuristiques pour corriger les mots
appliquer_heuristiques([], []).
appliquer_heuristiques([Mot|Reste], [MotCorrige|ResteCorrige]) :-
    heuristique(Mot, MotCorrige), !,
    appliquer_heuristiques(Reste, ResteCorrige).
appliquer_heuristiques([Mot|Reste], [Mot|ResteCorrige]) :-
    appliquer_heuristiques(Reste, ResteCorrige).

% Appliquer les synonymes pour harmoniser les mots
appliquer_synonymes([], []).
appliquer_synonymes([Mot|Reste], [MotCorrige|ResteCorrige]) :-
    synonyme(Mot, MotCorrige), !,
    appliquer_synonymes(Reste, ResteCorrige).
appliquer_synonymes([Mot|Reste], [Mot|ResteCorrige]) :-
    appliquer_synonymes(Reste, ResteCorrige).

% Trouver et classer les mots-cl�s
trouver_mots_cles(L_mots, Mots_Cles_Ordonnes) :-
    write('Mots d\'entr�e : '), writeln(L_mots), % Debug
    appliquer_heuristiques(L_mots, HeuristiquesAppliquees),
    write('Apr�s heuristiques : '), writeln(HeuristiquesAppliquees), % Debug
    appliquer_synonymes(HeuristiquesAppliquees, SynonymesAppliques),
    write('Apr�s synonymes : '), writeln(SynonymesAppliques), % Debug
    include(est_mot_clef, SynonymesAppliques, MotsPertinents),
    write('Mots pertinents : '), writeln(MotsPertinents), % Debug
    findall(
        Mot-Importance,
        (member(Mot, MotsPertinents), mclef(Mot, Importance)),
        Mots_Cles
    ),
    sort(2, @>=, Mots_Cles, Mots_Cles_Ordonnes),
    write('Mots cl�s ordonn�s : '), writeln(Mots_Cles_Ordonnes). % Debug

% V�rifie si un mot est un mot-cl�
est_mot_clef(Mot) :-
    mclef(Mot, _), % Si le mot est d�fini dans mclef/2
    write('Reconnu comme mot-cl� : '), writeln(Mot).
est_mot_clef(Mot) :-
    atom_number(Mot, _), % Si le mot est un nombre
    write('Reconnu comme nombre : '), writeln(Mot).
	
% Lire une question utilisateur sous forme de liste de mots
lire_question(LMots) :-
    read_line_to_string(user_input, Input), % Lire la ligne entr�e par l'utilisateur
    split_string(Input, " ", "", Words),    % Diviser la cha�ne en mots
    maplist(atom_string, LMots, Words).    % Convertir chaque mot en atome

% Afficher les r�ponses format�es
%afficher_reponse([]) :- nl.
%afficher_reponse([Ligne|Rest]) :-
%    atomic_list_concat(Ligne, ' ', Texte),
%    write('GGS : '), write(Texte), nl,
%    afficher_reponse(Rest).

% Point d'entr�e pour traiter une question utilisateur
traiter_question(Question, Reponse) :-
    trouver_mots_cles(Question, Mots_Cles_Ordonnes),
    generer_reponse(Mots_Cles_Ordonnes, Question, Reponse),
    afficher_reponse(Reponse).
