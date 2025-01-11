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
	write('ArbreSyntaxique : '), writeln(ArbreSyntaxique), % Debug
    format_reponse(ArbreSyntaxique, Resultats, Reponse),
	write('Resultats /:'), writeln(Resultats), % Debug
	write('Reponse /:'), writeln(Reponse). 

% Validation de l'arbre syntaxique
valide_arbre(noeud_question(_)).

% Format réponses selon le type de question et le nombre de résultats
format_reponse(_, [], [['Je suis desole, aucun vin ne correspond a vos criteres.']]).

% Format pour une question avec plusieurs résultats
format_reponse(_, Resultats, [['Voici', NVins, 'vins qui correspondent a vos criteres', ':', ListeVins]]) :-
    length(Resultats, N),
    N > 1,
    number_chars(N, NChars),
    atom_chars(NVins, NChars),
    maplist(format_result_line, Resultats, LignesFormatees),
    atomic_list_concat(LignesFormatees, ', ', ListeVins).

% Format pour un seul résultat (hors nez - bouche)
format_reponse(_, [Resultat], [['Voici le vin trouve :', ListeVins]]) :-
    maplist(format_result_line, [Resultat], LignesFormatees),
    atomic_list_concat(LignesFormatees, ', ', ListeVins).

% Format pour une question sur le nez ou la bouche d'un vin spécifique
format_reponse(noeud_question([noeud_critere(TypeInfo), noeud_nom_vin(Nom)]), Resultats, Reponse) :-
    (TypeInfo = nez ; TypeInfo = bouche),
    !,  % Important : coupe pour empêcher le backtracking vers les autres règles
    memberchk([Description], Resultats),  % Prend la première description trouvée
    Reponse = [[TypeInfo, 'du', Nom, ':', Description]].

% Formate chaque ligne de résultat en une chaîne lisible
format_result_line(Resultat, Ligne) :-
    atomic_list_concat(Resultat, ' - ', Ligne).

% Règle par défaut si aucune autre ne correspond
regle_rep(_, _, _, [['Je suis desole, je ne comprends pas votre question.']]).
