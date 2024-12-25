:- [vins].

% Trouve le prix d'un vin à partir de son nom
prix_du_vin_par_nom(Nom, Prix) :-
    normaliser_nom(Nom, NomNormalise),
    write('Nom normalisé recherché : '), writeln(NomNormalise),
    nom(ID, NomStocke),
    normaliser_nom(NomStocke, NomStockeNormalise),
    write('Nom normalisé stocké : '), writeln(NomStockeNormalise),
    NomNormalise = NomStockeNormalise,
    prix(ID, Prix).

normaliser_nom(Nom, NomNormalise) :-
    string_lower(Nom, NomMinuscule),  % Convertir en minuscules
    atom_string(NomNormalise, NomMinuscule).  % Convertir en atome si nécessaire

% Trouver le prix d'un vin par nom partiel (insensible à la casse)
prix_du_vin_par_nom_approximate(NomPartiel, Prix) :-
    nom(ID, NomComplet),
    string_to_lowercase(NomComplet, NomCompletLower),
    string_to_lowercase(NomPartiel, NomPartielLower),
    sub_string(NomCompletLower, _, _, _, NomPartielLower),
    prix(ID, Prix).

% Recherche des vins contenant tous les mots dans leur nom
recherche_multi_mots(NomsMots, Prix) :-
    nom(ID, NomComplet),
    maplist(string_to_lowercase, NomsMots, NomsMotsMinuscules),
    string_to_lowercase(NomComplet, NomCompletMinuscule),
    include(contains_substring(NomCompletMinuscule), NomsMotsMinuscules, MotsTrouves),
    length(NomsMotsMinuscules, NombreMotsRecherches),
    length(MotsTrouves, NombreMotsTrouves),
    NombreMotsRecherches = NombreMotsTrouves,
    prix(ID, Prix).

% Vérifie si un mot est une sous-chaîne
contains_substring(NomCompletMinuscule, Mot) :-
    sub_string(NomCompletMinuscule, _, _, _, Mot).

% Convertir une chaîne en minuscules
string_to_lowercase(String, LowercaseString) :-
    atom_chars(String, Chars),
    maplist(lowercase_char, Chars, LowercaseChars),
    atom_chars(LowercaseString, LowercaseChars).

% Convertir un caractère en minuscule
lowercase_char(Char, LowerChar) :-
    char_code(Char, Code),
    (   Code >= 65, Code =< 90
    ->  LowerCode is Code + 32
    ;   LowerCode = Code),
    char_code(LowerChar, LowerCode).
