/*---------------------------------------------------------*/
/* Extraction des mot clés et standardization de la phrase */
/*---------------------------------------------------------*/
:- [vins].
:- [common].

% operateurs.pl

:- discontiguous mclef/2.
:- discontiguous heuristique/2.

mclef(Mot, 1) :- atom_number(Mot, _). % Tous les nombres ont une importance de 1
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
    atom_string(Mot, MotStr),
    string_lower(MotStr, MotMinuscule),
    string_codes(MotMinuscule, Codes),
    include(code_utilisable, Codes, CodesUtilisables),
    string_codes(MotNettoye, CodesUtilisables),
    nettoyer_mots(Reste, ResteNettoyes).

code_utilisable(Code) :- char_type(Char, alnum), char_code(Char, Code).

% Appliquer les heuristiques pour corriger les mots et gérer les synonymes
harmoniser_mots([], []).
harmoniser_mots([Mot|Reste], [MotCorrige|ResteCorrige]) :-
    (   heuristique(Mot, MotCorrige) ; MotCorrige = Mot),
    harmoniser_mots(Reste, ResteCorrige).

% Trouver et classer les mots-clés
trouver_mots_cles(L_mots, Mots_Cles_Ordonnes) :-
    write('Mots d\'entrée : '), writeln(L_mots), % Debug
    nettoyer_mots(L_mots, MotsNettoyes),
    write('Mots nettoyés : '), writeln(MotsNettoyes), % Debug
    harmoniser_mots(MotsNettoyes, MotsHarmonises),
    write('Mots harmonisés : '), writeln(MotsHarmonises), % Debug
    include(est_mot_clef, MotsHarmonises, MotsPertinents),
    write('Mots pertinents : '), writeln(MotsPertinents), % Debug
    findall(Mot-Importance, (member(Mot, MotsPertinents), mclef(Mot, Importance)), Mots_Cles),
    sort(2, @>=, Mots_Cles, Mots_Cles_Ordonnes), % Trier par importance
    write('Mots clés ordonnés : '), writeln(Mots_Cles_Ordonnes). % Debug

% Vérifie si un mot est un mot-clé
est_mot_clef(Mot) :-
    mclef(Mot, _), % Si le mot est défini dans mclef/2
    write('Reconnu comme mot-cle : '), writeln(Mot).
est_mot_clef(Mot) :-
    atom_number(Mot, _), % Si le mot est un nombre
    write('Reconnu comme nombre : '), writeln(Mot).

% Lire une question utilisateur sous forme de liste de mots
lire_question(LMots) :-
    read_line_to_string(user_input, Input), % Lire la ligne entrée par l'utilisateur
    split_string(Input, " ", "", Words),    % Diviser la chaîne en mots
    maplist(atom_string, LMots, Words).    % Convertir chaque mot en atome

% Point d'entrée pour traiter une question utilisateur
traiter_question(Question, Reponse) :-
    trouver_mots_cles(Question, Mots_Cles_Ordonnes),
    generer_reponse(Mots_Cles_Ordonnes, Question, Reponse),
    afficher_reponse(Reponse).
