/*-------------------------------------------*/
/* Extraction des mot clés et standardization de la phrase*/
/*-------------------------------------------*/
:- [vins].
:- [common].

% operateurs.pl

:- discontiguous mclef/2.
:- discontiguous synonyme/2.

mclef('prix', 10).
mclef('bouche', 7).
mclef('nez', 7).
mclef('description', 6).
mclef('noel', 5).
mclef('canard', 5).
mclef('graves', 5).
mclef('haut', 5).
mclef('vin', 10).
mclef('bordeaux', 10).
mclef('bourgogne', 8).
mclef('rose', 7).
mclef('fête', 5).
mclef('entre', 2).
mclef('et', 2).

heuristique('bourgognes', 'bourgogne').
heuristique('prixs', 'prix').
heuristique('bouches', 'bouche').
heuristique('nezs', 'nez').
heuristique('descriptions', 'description').
heuristique('noels', 'noel').
heuristique('canards', 'canard').
heuristique('gravess', 'graves').
heuristique('hauts', 'haut').
heuristique('noeils', 'noel').
heuristique('noelles', 'noel').
heuristique('repas', 'repas').
heuristique('vins', 'vin').
heuristique('vin\'s', 'vin').
heuristique('vín', 'vin').
heuristique('bouchées', 'bouche').

synonyme('bourgogne', 'bourgogne').
synonyme('bourgognes', 'bourgogne').
synonyme('bourguignons', 'bourgogne').
synonyme('coteaux bourguignons', 'bourgogne').
synonyme('prixs', 'prix').
synonyme('bouches', 'bouche').
synonyme('nezs', 'nez').
synonyme('descriptions', 'description').
synonyme('noels', 'noel').
synonyme('canards', 'canard').
synonyme('gravess', 'graves').
synonyme('hauts', 'haut').
synonyme('bordeaux', 'vin').
synonyme('bourgogne', 'vin').
synonyme('noel', 'noel').
synonyme('repas', 'repas').
synonyme('bordeaux', 'bordeaux').
synonyme('rosé', 'rose').
synonyme('Bourgogne', 'bourgogne').
synonyme('vin', 'boisson').
synonymes(disponibles, [dispo, en_stock]).
synonyme('disponibles', 'disponible').


% lister plusieurs vins sur base de critères ex: voici les vins rouge de bourgogne que vous avez demandé: ...
% Rouge et bourogne vienne du parseur. la liste en réponse viens du parseur aussi.
% Demandez moi plus d'info sur un vin, si vous le désirez.

% [Combien] coute [nom] -> combien = mocle
% Que donne -> que = motcle  
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

% Trouver et classer les mots-clés
trouver_mots_cles(L_mots, Mots_Cles_Ordonnes) :-
    write('Mots d\'entrée : '), writeln(L_mots), % Debug
    appliquer_heuristiques(L_mots, HeuristiquesAppliquees),
    write('Après heuristiques : '), writeln(HeuristiquesAppliquees), % Debug
    appliquer_synonymes(HeuristiquesAppliquees, SynonymesAppliques),
    write('Après synonymes : '), writeln(SynonymesAppliques), % Debug
    include(est_mot_clef, SynonymesAppliques, MotsPertinents),
    write('Mots pertinents : '), writeln(MotsPertinents), % Debug
    findall(
        Mot-Importance,
        (member(Mot, MotsPertinents), mclef(Mot, Importance)),
        Mots_Cles
    ),
    sort(2, @>=, Mots_Cles, Mots_Cles_Ordonnes),
    write('Mots clés ordonnés : '), writeln(Mots_Cles_Ordonnes). % Debug

% Vérifie si un mot est un mot-clé
est_mot_clef(Mot) :-
    mclef(Mot, _), % Si le mot est défini dans mclef/2
    write('Reconnu comme mot-clé : '), writeln(Mot).
est_mot_clef(Mot) :-
    atom_number(Mot, _), % Si le mot est un nombre
    write('Reconnu comme nombre : '), writeln(Mot).
	
% Lire une question utilisateur sous forme de liste de mots
lire_question(LMots) :-
    read_line_to_string(user_input, Input), % Lire la ligne entrée par l'utilisateur
    split_string(Input, " ", "", Words),    % Diviser la chaîne en mots
    maplist(atom_string, LMots, Words).    % Convertir chaque mot en atome

% Afficher les réponses formatées
%afficher_reponse([]) :- nl.
%afficher_reponse([Ligne|Rest]) :-
%    atomic_list_concat(Ligne, ' ', Texte),
%    write('GGS : '), write(Texte), nl,
%    afficher_reponse(Rest).

% Point d'entrée pour traiter une question utilisateur
traiter_question(Question, Reponse) :-
    trouver_mots_cles(Question, Mots_Cles_Ordonnes),
    generer_reponse(Mots_Cles_Ordonnes, Question, Reponse),
    afficher_reponse(Reponse).


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

