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
    result_values([nom, annee], Lproj, VinTrouve, [Nom, Annee]),
    subtract(Lproj, [nom, annee], [Proj | _]),
    format_projection(Proj, FormattedProj),
    result_values([Proj], Lproj, VinTrouve, [Description]),
    ReponsePattern = ['Le',  Nom, Annee, 'possède', FormattedProj, 'suivant(e):', Description],
    atomic_list_concat(ReponsePattern, ' ', Reponse).

regle_rep(Query, [Reponse | Lignes]) :- 
    Query = query(Lproj,_,_,1,_),
    subset([nom, annee], Lproj),
    length(Lproj, L), L > 3,
    execute_query(Query, Resultat),
    Resultat = [VinTrouve | _],
    result_values([nom, annee], Lproj, VinTrouve, [Nom, Annee]),
    subtract(Lproj, [nom, annee], RestProj),
    ReponsePattern = ['Le',  Nom, Annee, 'possède', 'les', 'caractéristiques', 'suivantes:'],
    atomic_list_concat(ReponsePattern, ' ', Reponse),
    format_caracteristiques(RestProj, VinTrouve, Lignes). 

regle_rep(Query, [Reponse | Lignes]) :- 
    Query = query(Lproj,_,_,1,_),
    member(nom, Lproj),
    length(Lproj, L), L > 2,
    execute_query(Query, Resultat),
    Resultat = [VinTrouve | _],
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
    result_values([nom], Lproj, VinTrouve, [Nom]),
    subtract(Lproj, [nom], [Proj | _]),
    format_projection(Proj, FormattedProj),
    result_values([Proj], Lproj, VinTrouve, [Description]),
    ReponsePattern = ['Le',  Nom, 'possède', FormattedProj, 'suivant(e):', Description],
    atomic_list_concat(ReponsePattern, ' ', Reponse).

regle_rep(Query, [Reponse | Responses]) :-
    Query = query(Lproj, Lfiltres, _, N, _),
    execute_query(Query, Resultat),
    length(Resultat, RLength), RLength > 0,
    format_filtres(Lfiltres, Filtres),
    LReponse = ['Voici une selection de vins', Filtres, ':'],
    atomic_list_concat(LReponse, ' ', Reponse),
    format_reponses(Resultat, Lproj, Lignes),
    format_last(N, Resultat, Last),
    append(Lignes, Last, Responses).

regle_rep(Query, ['Je n\'ai malheureusement aucun vin correspondant à vos critères dans ma cave.']) :-
    execute_query(Query, Resultat),
    length(Resultat, RLength), RLength is 0.

format_filtres(Filtres, FormatFiltres) :-
    findall(Res, filtre_format(Filtres, Res), LFiltresFormat),
    atomic_list_concat(LFiltresFormat, ' ', FormatFiltres).
format_filtres(_, 'correspondant a vos critères').

filtre_format(Filtres, 'rouges') :- member([couleur, eq, rouge], Filtres).
filtre_format(Filtres, 'blancs') :- member([couleur, eq, blanc], Filtres).
filtre_format(Filtres, 'rosés') :- member([couleur, eq, rose], Filtres).
filtre_format(Filtres, Result) :- 
    member([appelation, eq, Appelation], Filtres),
    L = ['d\'appelation', Appelation],
    atomic_list_concat(L, ' ', Result).
filtre_format(Filtres, Result) :- 
    member([localite, eq, Localite], Filtres),
    L = ['de la région de', Localite],
    atomic_list_concat(L, ' ', Result).
filtre_format(Filtres, Result) :- 
    member([accord, eq, Accord], Filtres),
    L = ['pour accompagner la/le(s)', Accord],
    atomic_list_concat(L, ' ', Result).
filtre_format(Filtres, Result) :-
    member([prix, gte, Pmin], Filtres),
    member([prix, lte, Pmax], Filtres),!,
    L = ['dont le prix est supérieur à', Pmin, 'eur et inférieur à', Pmax],
    atomic_list_concat(L, ' ', Result).
filtre_format(Filtres, Result) :-
    member([prix, gte, Pmin], Filtres),
    L = ['dont le prix est supérieur à', Pmin],
    atomic_list_concat(L, ' ', Result).
filtre_format(Filtres, Result) :-
    member([prix, lte, Pmax], Filtres),
    L = ['dont le prix est inférieur à', Pmax],
    atomic_list_concat(L, ' ', Result).
filtre_format(Filtres, Result) :-
    member([prix, eq, P], Filtres),
    L = ['dont le prix est egal à', P],
    atomic_list_concat(L, ' ', Result).

format_reponses([], _, []).
format_reponses([Rep | Rest], Lproj, [Ligne | Lignes]) :- 
    member(prix, Lproj),
    member(nom, Lproj),
    member(annee, Lproj),
    result_values([prix, nom, annee], Lproj, Rep, [Prix, Nom, Annee]),
    atomic_list_concat(['*', Nom, Annee, '-', Prix], ' ', Ligne),
    format_reponses(Rest, Lproj, Lignes).

format_last(Nquery, Resultats, List) :-
    length(Resultats, ResLength),
    Nquery > ResLength,
    List = ['Si l’un de ces vins retient votre attention, je me ferai un plaisir de vous fournir davantage d’informations.'].

format_last(_, _, List) :-
    List = ['N’hésitez pas à me solliciter pour d’autres suggestions si celles-ci ne vous conviennent pas.',
    'Sinon, si l’un de ces vins retient votre attention, je me ferai un plaisir de vous fournir davantage d’informations.'].

format_projection(bouche, 'la bouche').
format_projection(nez, 'le nez').
format_projection(annee, 'le millesime').
format_projection(appelation, 'l\'appelation').
format_projection(prix, 'le prix').
format_projection(localite, 'la localite').
format_projection(description, 'la description').

format_caracteristiques([], _, []).
format_caracteristiques([X | Lproj], [Description | Vin], [Ligne | Lignes]) :-
    atomic_list_concat(['*', X, ':', Description], ' ', Ligne),
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