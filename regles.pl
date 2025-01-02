% regles.pl

% Définition des règles pour répondre aux questions des utilisateurs
% regle_rep(MotCle, Contexte, Pattern, Reponse)
% MotCle : mot-clé identifié dans la question
% Contexte : contexte supplémentaire (non utilisé dans cet exemple)
% Pattern : modèle de correspondance pour valider la question
% Reponse : réponse associée au mot-clé

:- discontiguous regle_rep/4.

% Règle générique pour formater les résultats obtenus depuis query.pl
regle_rep(_, ArbreSyntaxique, Resultats, Reponse) :-
    valide_arbre(ArbreSyntaxique),
    format_reponse(Resultats, Reponse).

% Validation de l'arbre syntaxique (à voir si necessaire)
valide_arbre(noeud_question(_)).
valide_arbre(noeud_vin(_)).

% Format réponses
format_reponse([], [['Je suis desole, aucun resultat trouve.']]). % Cas vide

format_reponse(Resultats, [['Voici les resultats trouves :'] | Lignes]) :-
    maplist(format_ligne, Resultats, Lignes).

% Formatage générique d'une ligne de résultats
format_ligne(Ligne, Texte) :-
    atomic_list_concat(Ligne, ' ', Texte).

% Exemple test 
test_regle :-
    % Exemple de résultats récupérés depuis query.pl
    Resultats = [['Chateau Moulin de Mallet', 'rouge', 'Bordeaux'], ['Chateau Marguerite', 'rouge', 'Medoc']],
    regle_rep(_, noeud_question([vin, rouge, bordeaux]), Resultats, Reponse),
    writeln(Reponse).

% Exemple de règle par défaut
regle_rep(_, _, _, [['Je suis desole, je ne comprends pas votre question.']]).
