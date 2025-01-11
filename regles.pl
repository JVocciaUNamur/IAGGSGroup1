% regles.pl
:- [vins].
:- [query].

% Définition des règles pour répondre aux questions des utilisateurs
% regle_rep(MotCle, Contexte, Pattern, Reponse)
% MotCle : mot-clé identifié dans la question
% Contexte : contexte supplémentaire (non utilisé dans cet exemple)
% Pattern : modèle de correspondance pour valider la question
% Reponse : réponse associée au mot-clé

:- discontiguous regle_rep/4.

% Règle générique pour formater les résultats obtenus depuis query.pl

regle_rep(Query, [Reponse]) :- 
    Query = query(Lproj,_,_,1,_),
    subset([nom, annee], Lproj),
    length(Lproj, L), L is 3,
    execute_query(Query, Resultat),
    Resultat = [VinTrouve | _],
    writeln(VinTrouve),
    result_values([nom, annee], Lproj, VinTrouve, [Nom, Annee]),
    subtract(Lproj, [nom, annee], [Proj | _]),
    format_projection(Proj, FormattedProj),
    result_values([Proj], Lproj, VinTrouve, [Description]),
    ReponsePattern = ['Le',  Nom, Annee, 'possède', FormattedProj, 'suivant(e):', Description],
    atomic_list_concat(ReponsePattern, ' ', Reponse).

regle_rep(Query, [Reponse | Lignes]) :- 
    Query = query(Lproj,_,_,1,_),
    write(Lproj),
    subset([nom, annee], Lproj),
    length(Lproj, L), L > 3,
    execute_query(Query, Resultat),
    Resultat = [VinTrouve | _],
    writeln(VinTrouve),
    result_values([nom, annee], Lproj, VinTrouve, [Nom, Annee]),
    subtract(Lproj, [nom, annee], RestProj),
    ReponsePattern = ['Le',  Nom, Annee, 'possède', 'les', 'caractéristiques', 'suivantes:'],
    atomic_list_concat(ReponsePattern, ' ', Reponse),
    format_caracteristiques(RestProj, VinTrouve, Lignes). 

regle_rep(Query, [Reponse | Lignes]) :- 
    Query = query(Lproj,_,_,1,_),
    write(Lproj),
    member(nom, Lproj),
    length(Lproj, L), L > 2,
    execute_query(Query, Resultat),
    Resultat = [VinTrouve | _],
    writeln(VinTrouve),
    result_values([nom], Lproj, VinTrouve, [Nom]),
    subtract(Lproj, [nom], RestProj),
    ReponsePattern = ['Le',  Nom, 'possède', 'les', 'caractéristiques', 'suivantes:'],
    atomic_list_concat(ReponsePattern, ' ', Reponse),
    format_caracteristiques(RestProj, VinTrouve, Lignes). 

regle_rep(Query, [Reponse]) :- 
    Query = query(Lproj,_,_,1,_),
    member(nom, Lproj),
    length(Lproj, L), L is 2,
    execute_query(Query, Resultat),
    Resultat = [VinTrouve | _],
    writeln(VinTrouve),
    result_values([nom], Lproj, VinTrouve, [Nom]),
    subtract(Lproj, [nom], [Proj | _]),
    format_projection(Proj, FormattedProj),
    result_values([Proj], Lproj, VinTrouve, [Description]),
    ReponsePattern = ['Le',  Nom, 'possède', FormattedProj, 'suivant(e):', Description],
    atomic_list_concat(ReponsePattern, ' ', Reponse).

format_projection(bouche, 'la bouche').
format_projection(nez, 'le nez').
format_projection(annee, 'le millesime').
format_projection(appelation, 'l\'appelation').
format_projection(prix, 'le prix').
format_projection(localite, 'la localite').
format_projection(description, 'la description').

format_caracteristiques([], _, []).
format_caracteristiques([X | Lproj], [Description | Vin], [Ligne | Lignes]) :-
    atomic_list_concat(['-', X, ':', Description], ' ', Ligne),
    format_caracteristiques(Lproj, Vin, Lignes).

result_values([], _, _, []).
result_values(_, _, [], []).
result_values([ReqVal | ReqValues], Lproj, Lvalues, [Result | Lresult]) :-
    indexOf(ReqVal, Lproj, ReqValIx),
    nth0(ReqValIx, Lvalues, Result),
    result_values(ReqValues, Lproj, Lvalues, Lresult).

test_match_regle :- 
    match_question_regle(noeud_question([noeud_object([noeud_nom_vin(clos_des_vignes)]),noeud_critere([bouche])]), [noeud_object([noeud_nom_vin(_, _)]), noeud_critere([bouche])]).
test_result_values(Values) :-
    result_values([nom, bouche, prix], [prix, nom, bouche], [12, 'domaine de clairval', 'fruité'], Values).