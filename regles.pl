% regles.pl

% Définition des règles pour répondre aux questions des utilisateurs
% regle_rep(MotCle, Contexte, Pattern, Reponse)
% MotCle : mot-clé identifié dans la question
% Contexte : contexte supplémentaire (non utilisé dans cet exemple)
% Pattern : modèle de correspondance pour valider la question
% Reponse : réponse associée au mot-clé


:- discontiguous regle_rep/4.

% Règle pour les mots-clés génériques "vin"
regle_rep('vin', _, [vin], [['Voici', 'les', 'vins', 'disponibles.']]).
regle_rep('prix', _, [prix, vin], Reponse) :-
    findall([Nom, Prix],
        (nom(ID, Nom), prix(ID, Prix)),
        ListeVinsAvecPrix),
    (   ListeVinsAvecPrix = []
    ->  Reponse = [['Aucun vin disponible avec un prix connu.']]
    ;   maplist(format_prix, ListeVinsAvecPrix, ReponsesFormattees),
        Reponse = [['Voici les vins et leurs prix :'] | ReponsesFormattees]
    ).

% Règle générique pour rechercher des vins spécifiques (e.g., Bourgogne, Bordeaux)
regle_rep('bourgogne', _, _, Reponse) :-
    findall(Nom,
        (nom(_, Nom), synonyme(Synonyme, 'bourgogne'), sub_string(Nom, _, _, _, Synonyme)),
        ListeVinsBruts),
    sort(ListeVinsBruts, ListeVins),
    (   ListeVins = []
    ->  Reponse = [['Aucun vin de Bourgogne trouvé.']]
    ;   Reponse = [['Voici les vins de Bourgogne disponibles :'] | ListeVins]).

% Règle pour les prix
regle_rep('prix', _, [prix, entre, Min, et, Max], Reponse) :-
    atom_number(Min, MinNum),
    atom_number(Max, MaxNum),
    findall(
        [Nom, PrixStr],
        (   nom(ID, Nom),
            prix(ID, PrixStr),
            clean_prix(PrixStr, PrixNum),  % Nettoyage et conversion du prix
            PrixNum >= MinNum,
            PrixNum =< MaxNum
        ),
        ListeVinsAvecPrix
    ),
    (   ListeVinsAvecPrix = []
    ->  Reponse = [['Aucun vin trouve dans cette gamme de prix.']]
    ;   maplist(format_prix, ListeVinsAvecPrix, ReponsesFormattees),
        Reponse = [['Voici les vins entre ', Min, ' et ', Max, ' EUR :'] | ReponsesFormattees]
    ).

% Nettoyage du prix : suppression des caractères non numériques et conversion en nombre
regle_rep('prix', _, [prix|Reste], Reponse) :-
    append([entre, Min, et, Max], _, Reste), % Vérifie la structure attendue
    atom_number(Min, MinNum),
    atom_number(Max, MaxNum),
    findall(
        [Nom, PrixStr],
        (   nom(ID, Nom),
            prix(ID, PrixStr),
            clean_prix(PrixStr, PrixNum),
            PrixNum >= MinNum,
            PrixNum =< MaxNum
        ),
        ListeVinsAvecPrix
    ),
    (   ListeVinsAvecPrix = []
    ->  Reponse = [['Aucun vin trouvé dans cette gamme de prix.']]
    ;   maplist(format_prix, ListeVinsAvecPrix, ReponsesFormattees),
        Reponse = [['Voici les vins entre ', Min, ' et ', Max, ' EUR :'] | ReponsesFormattees]
    ).

% Nettoyage des prix pour supprimer les caractères non pertinents et convertir en nombre
clean_prix(PrixStr, PrixNum) :-
    sub_atom(PrixStr, 0, _, 4, PrixSansEUR), % Supprime ' EUR'
    atom_chars(PrixSansEUR, Chars),
    maplist(replace_comma, Chars, CleanChars), % Remplace ',' par '.'
    atomic_list_concat(CleanChars, '', PrixNet),
    atom_number(PrixNet, PrixNum).

% Remplacement des virgules par des points
replace_comma(',', '.') :- !.
replace_comma(Char, Char).

	

% Formatte une réponse pour chaque vin et son prix
format_prix([Nom, Prix], Texte) :-
    format(atom(Texte), '~w : ~w €', [Nom, Prix]).

% Règle pour les vins de Bordeaux
regle_rep('bordeaux', _, ['bordeaux'], [['Voici', 'des', 'vins', 'de', 'Bordeaux.']]).

% Règle pour les fêtes
regle_rep('fête', _, ['fête'], [['Voici', 'des', 'vins', 'idéaux', 'pour', 'une', 'fête.']]).

% Règle pour les rosés
regle_rep('rosé', _, ['rosé'], [['Voici', 'les', 'vins', 'rosés', 'disponibles.']]).

% Règle pour les tarifs
regle_rep('tarifs', _, ['tarifs'], [['Les', 'tarifs', 'sont', 'disponibles', 'sur', 'demande.']]).

% Gestion d’un cas par défaut si aucune règle spécifique ne correspond
regle_rep(_, _, _, [['Je suis desole, je ne comprends pas votre question.']]).

regle_rep('rouge', _, [vin, rouge], ['Voici des vins rouges :', 'vin rouge 1', 'vin rouge 2']).

regle_rep('description', _, [description, de, NomVin], Reponse) :-
    (   nom(ID, NomVin),
        description(ID, Desc)
    ->  Reponse = [['Voici la description du vin :'], Desc]
    ;   Reponse = [['Je suis désolé, je ne trouve pas la description pour ce vin.']]).