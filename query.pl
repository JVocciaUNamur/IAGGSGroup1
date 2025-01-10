:- debug.
/*---------------------------------------
Définition d'une recherche dans la base de connaissances.

query(Lproj, Lfilters, Skip, Take, Sort)
- Lproj = un ensemble non vide de valeurs a sélectionner, ex: [nom, annee, mois].
- Lfilters = une liste de filtres, ex: [[annee, eq, 2014], [couleur, eq, rouge]].
- Skip = Nombre >= 0, nombre d'éléments a sauter dans le résultat.
- Take = Nombre >=0, nombre d'éléments a retourner dans le résultat.
- Sort = asc(Proj), desc(Proj). Proj = élément de l'ensemble LProj.

execute_query(Query, LVin)
    Query = query(Lproj, Lfilters, Skip, Take, Sort),
    LVin = liste de résultats ex: [[2014, 'chateau latour', 'loire'], [2015, 'mon bazillac', 'bordeau']].
--------------------------------------*/
%

:- [vins].
:- [common].

% on suppose que la question est en minuscule, les noms des vins ont été préalablement concaténé par des _ 

:- discontiguous appelation_prefix/1.

% Question
parse_question(noeud_question([Object, Context])) --> parse_object(Object), parse_context(Context).
parse_question(noeud_question([Context, Object])) --> parse_context(Context), parse_object(Object).
parse_question(noeud_question([Object, Criteria])) --> parse_object(Object), parse_criteria(Criteria).
parse_question(noeud_question([Criteria, Object])) --> parse_criteria(Criteria), parse_object(Object).
parse_question(noeud_question([Object])) --> parse_object(Object).
parse_question(noeud_question([Context])) --> parse_context(Context).

parse_question(Q) --> [_], parse_question(Q).

parse_object(noeud_object([Vin])) --> parse_vin(Vin).
parse_object(noeud_object([Nom])) --> parse_nom_vin(Nom).
parse_object(O) --> [_], parse_object(O).

parse_criterium(appelation) --> parse_appelation.
parse_criterium(annee) --> parse_millesime.
parse_criterium(bouche) --> parse_bouche.
parse_criterium(nez) --> parse_nez.
parse_criterium(localite) --> parse_localite.
parse_criterium(description) --> parse_description.
parse_criterium(prix) --> parse_prix.
criteria_separator([',', et]).
parse_criteria(noeud_critere([Crit | Criteres])) --> parse_criterium(Crit), [Sep], parse_criteria(noeud_critere(Criteres)), {criteria_separator(L), member(Sep, L)}.
parse_criteria(noeud_critere([Crit])) --> parse_criterium(Crit). 
parse_criteria(C) --> [_], parse_criteria(C).

%context
context_prefix([pour, accompagner, avec, du, de, la]).
mot_context(M) :- accord(_, M).
parse_context(C) --> [P], parse_context(C), {context_prefix(L), member(P, L)}.
parse_context(noeud_context(M)) --> [M], {mot_context(M)}. 
parse_context(C) --> [_], parse_context(C).

%object
vin_prefix([le, les, du, des, un, vin, vins, pinard, pinards]).
parse_vin(noeud_vin(Params)) --> parse_params(Params).
parse_vin(V) --> [P], parse_vin(V), {vin_prefix(L), member(P, L)}.

parse_param(P) --> parse_couleur(P).
parse_param(P) --> parse_localite(P).
parse_param(P) --> parse_appelation(P).
parse_param(P) --> parse_prix(P).
parse_param(P) --> parse_annee(P).
parse_params([P | Params]) --> parse_param(P), parse_params(Params).
parse_params([P]) --> parse_param(P).

known_nom_vin(X) :- nom(_, L), atomic_list_concat(L, '_', Y), downcase_atom(Y, X).
nom_vin_prefix([le, les, du, des]).
parse_nom_vin(noeud_nom_vin(N)) --> [N], {known_nom_vin(N)}.
parse_nom_vin(noeud_nom_vin(N, Annee)) --> parse_nom_vin(noeud_nom_vin(N)), [Annee], {number(Annee)}.
parse_nom_vin(N) --> [P], parse_nom_vin(N), {nom_vin_prefix(L), member(P, L)}.

couleur_prefix([du, un, des]).
known_couleur([(rouge, [rouge, rouges]), (blanc, [blanc, blancs]), (rose, [rose, roses])]).
parse_couleur(noeud_couleur(C)) --> [Couleur], {known_couleur(X), member((C, Alt), X), member(Couleur, Alt)}.
parse_couleur(C) --> [P], parse_couleur(C), {couleur_prefix(L), member(P, L)}.

known_localite(X) :- localite(_, _, Y), downcase_atom(Y, X),!.
known_localite(X) :- localite(_, Y, _), downcase_atom(Y, X),!.
localite_prefix([de]).
parse_localite(noeud_localite(L)) --> [L], {known_localite(L)}. 
parse_localite(L) --> [P], parse_localite(L), {localite_prefix(Loc), member(P, Loc)}. 

known_appelation(X) :- appelation(_, Y), downcase_atom(Y, X),!.
appelation_prefix([un, du, des]).
parse_appelation(noeud_appelation(A)) --> [A], {known_appelation(A)}.
parse_appelation(A) --> [P], parse_appelation(A), {appelation_prefix(L), member(P, L)}.

prix_prefix([au, le, au, prix, cout, qui, coute, vaut, est, a, un]).
parse_prix(P) --> parse_prix_egal(P).
parse_prix(P) --> parse_prix_inf(P). 
parse_prix(P) --> parse_prix_sup(P). 
parse_prix(P) --> parse_prix_entre(P). 
parse_prix(P) --> [Pref], parse_prix(P), {prix_prefix(L), member(Pref, L)}.

euro([eur, euro]).
prix_num(P) --> [P], [E], {euro(Le), member(E, Le), number(P)}.
prix_egal_prefix([egal, a]).
parse_prix_egal(noeud_prix(eq, P)) --> prix_num(P). 
parse_prix_egal(P) --> [Pref], parse_prix_egal(P), {prix_egal_prefix(L), member(Pref, L)}.
prix_sup_prefix([plus, cher, que, superieur, a, au, dessus, de]).
parse_prix_sup(noeud_prix(gte, P)) --> prix_num(P). 
parse_prix_sup(P) --> [Pref], parse_prix_sup(P), {prix_sup_prefix(L), member(Pref, L)}.
prix_inf_prefix([moins, cher, que, inferieur, a, en, dessous, de]).
parse_prix_inf(noeud_prix(lte, P)) --> prix_num(P). 
parse_prix_inf(P) --> [Pref], parse_prix_inf(P), {prix_inf_prefix(L), member(Pref, L)}. 
prix_entre_prefix([entre]).
prix_entre_separator([et]).
parse_prix_entre(noeud_prix(in, [Pmin, Pmax])) --> [Pref], prix_num(Pmin) , [Sep], prix_num(Pmax), {prix_entre_prefix(LPref), member(Pref, LPref), prix_entre_separator(LSep), member(Sep, LSep)}.

prefix_annee([de, millesime, annee]).
parse_annee(noeud_annee(eq, Annee)) --> [Annee], {number(Annee), Annee >= 1000, Annee =< 9999}.
parse_annee(A) --> [P], parse_annee(A), {prefix_annee(L), member(P, L)}.

%criteria
appelation_criteria_prefix([la, les, 'l\'']).
mot_appelation([appelation, appelations]).
parse_appelation() --> [M], {mot_appelation(L), member(M, L)}.
parse_appelation() --> [P], parse_appelation, {appelation_criteria_prefix(L), member(P, L)}.

millesime_prefix([la, le, les]).
mot_millesime([millesime, millesimes, annee, annees]).
parse_millesime() --> [M], {mot_millesime(L), member(M, L)}.
parse_millesime() --> [P], parse_millesime, {millesime_prefix(L), member(P, L)}.

bouche_prefix([sa, la, en]).
parse_bouche() --> [bouche].
parse_bouche() --> [P], parse_bouche, {bouche_prefix(L), member(P, L)}.

nez_prefix([son, le, au]).
parse_nez() --> [nez].
parse_nez() --> [P], parse_nez, {nez_prefix(L), member(P, L)}.

parse_localite() --> [localite].
parse_localite() --> [la], parse_localite.

prefix_description([la, les, me, en]).
mot_description([dire, decrire, description, descriptions]).
parse_description() --> [M], {mot_description(L), member(M, L)}.
parse_description() --> [P], parse_description, {prefix_description(L), member(P, L)}.

prefix_prix([le, les, combien]).
mot_prix([prix, coute, vaut]).
parse_prix() --> [M], {mot_prix(L), member(M, L)}.
parse_prix() --> [P], parse_prix, {prefix_prix(L), member(P, L)}.

% create query from question
create_query(noeud_question(L), query(UniqueProj, UniqueFilters, 0, Take, asc(nom))) :- 
    create_projections(L, Lproj),
    list_to_set(Lproj, UniqueProj),
    create_filters(L, Lfilters),
    list_to_set(Lfilters, UniqueFilters),
    create_take(L, Take).

create_projections([], [nom]).
create_projections([noeud_critere([Crit | Lcritere]) | T], [Crit | LProj]) :-
    create_projections(Lcritere, R),
    create_projections(T, L),
    append(L, R, LProj).
create_projections([noeud_object(Lo) | T], LProj) :-
    create_projections(Lo, R),
    create_projections(T, L),
    append(L, R, LProj).
create_projections([noeud_context(_) | T], [accord | LProj]) :- 
    create_projections(T, LProj).
create_projections([noeud_vin(L) | T], AllProjections) :- 
    create_projections(L, Projections), 
    create_projections(T, RestProjections),
    append(Projections, RestProjections, AllProjections).
create_projections([noeud_prix(_, _) | T], [prix | Projections]) :- 
    create_projections(T, Projections).
create_projections([noeud_prix(_, _, _) | T], [prix | Projections]) :- 
    create_projections(T, Projections).
create_projections([noeud_annee(_, _) | T], [annee | Projections]) :- 
    create_projections(T, Projections).
create_projections([noeud_localite(_) | T], [localite | Projections]) :- 
    create_projections(T, Projections).
create_projections([noeud_appelation(_) | T], [appelation | Projections]) :- 
    create_projections(T, Projections).
create_projections([noeud_couleur(_) | T], [couleur | Projections]) :-
    create_projections(T, Projections).
create_projections([noeud_nom_vin(_,_) | T], [annee | Projections]) :-
    create_projections(T, Projections).
create_projections([_ | T], Projections) :- 
    create_projections(T, Projections).

create_filters([], []).
create_filters([noeud_object(Lo) | T], Lfilters) :-
    create_filters(Lo, R),
    create_filters(T, L),
    append(L, R, Lfilters).
create_filters([noeud_context(Ctx) | T], [[accord, eq, Ctx] | Lfilters]) :-
    create_filters(T, Lfilters).
create_filters([noeud_vin(L) | T], AllFilters) :- 
    create_filters(L, Filters), 
    create_filters(T, RestFilters),
    append(Filters, RestFilters, AllFilters).
create_filters([noeud_nom_vin(Nom) | T], [[nom, eq, Nom] | RestFilters]) :-
    create_filters(T, RestFilters).
create_filters([noeud_nom_vin(Nom, Annee) | T], [[nom, eq, Nom], [annee, eq, Annee] | RestFilters]) :-
    create_filters(T, RestFilters).
create_filters([noeud_couleur(Couleur) | T], [[couleur, eq, Couleur] | RestFilters]) :-
    create_filters(T, RestFilters).
create_filters([noeud_appelation(Appelation) | T], [[appelation, eq, Appelation] | RestFilters]) :-
    create_filters(T, RestFilters).
create_filters([noeud_localite(Localite) | T], [[localite, eq, Localite] | RestFilters]) :-
    create_filters(T, RestFilters).
create_filters([noeud_annee(Op, Annee) | T], [[annee, Op, Annee] | Restfilters]) :-
    create_filters(T, Restfilters).
create_filters([noeud_prix(Op, Prix) | T], [[prix, Op, Prix] | Restfilters]) :-
    create_filters(T, Restfilters).
create_filters([noeud_prix(in, Pmin, Pmax) | T], [[prix, gte, Pmin], [prix, lte, Pmax] | Restfilters]) :-
    create_filters(T, Restfilters).
create_filters([_ | T], Filters) :- create_filters(T, Filters).
create_take(L, 1) :- member(noeud_critere(_), L).
create_take(_, 3).

% Execute Query
execute_query(query(Lproj, Lfilters, Skip, Take, Sort), Lvin) :-
    findall(Id, (
        apply_filters(Lfilters, Id) 
    ), Lid),
    apply_projections(Lid, Lproj, LResults),
    apply_sort(Sort, Lproj, LResults, LSorted),
    skip(Skip, LSorted, LRest),
    take(Take, LRest, Lvin).

apply_sort(asc(Col), Projections, Lin, Lout) :- 
    indexOf(Col, Projections, SortIndex),
    columnSort(Lin, ascending, SortIndex, Lout).

apply_sort(desc(Col), Projections, Lin, Lout) :- 
    indexOf(Col, Projections, SortIndex),
    columnSort(Lin, descending, SortIndex, Lout).

apply_filters([], Id) :- nom(Id, _).

apply_filters([[nom, eq, L] | Rest], Id) 
    :- nom(Id, X),
    atomic_list_concat(X, '_', Y),
    downcase_atom(Y, L),
    apply_filters(Rest, Id).

apply_filters([[localite, eq, L] | Rest], Id) 
    :- localite(Id, _, X),
    downcase_atom(X, L),
    apply_filters(Rest, Id).

apply_filters([[localite, eq, L] | Rest], Id) 
    :- localite(Id, X, _),
    downcase_atom(X, L),
    apply_filters(Rest, Id).

apply_filters([[appelation, eq, L] | Rest], Id)
    :- appelation(Id, X),
    downcase_atom(X, L),
    apply_filters(Rest, Id).

apply_filters([[couleur, eq ,C] | Rest], Id)
    :- couleur(Id, C),
    apply_filters(Rest, Id).

apply_filters([[annee, eq, A] | Rest], Id)
    :- annee(Id, A),
    apply_filters(Rest, Id).

apply_filters([[annee, gt, A] | Rest], Id)
    :- annee(Id, X),
    X > A,
    apply_filters(Rest, Id).

apply_filters([[annee, gte, A] | Rest], Id)
    :- annee(Id, X),
    X >= A,
    apply_filters(Rest, Id).

apply_filters([[annee, lt, A] | Rest], Id)
    :- annee(Id, X),
    X < A,
    apply_filters(Rest, Id).

apply_filters([[annee, lte, A] | Rest], Id)
    :- annee(Id, X),
    X =< A,
    apply_filters(Rest, Id).

apply_filters([[prix, lte, P] | Rest], Id)
    :- prix(Id, _, X),
    X =< P,
    apply_filters(Rest, Id).

apply_filters([[prix, lt, P] | Rest], Id)
    :- prix(Id, _, X),
    X < P,
    apply_filters(Rest, Id).
   
apply_filters([[prix, eq, P] | Rest], Id)
    :- prix(Id, _, P),
    apply_filters(Rest, Id).

apply_filters([[prix, gte, P] | Rest], Id)
    :- prix(Id, _, X),
    X >= P,
    apply_filters(Rest, Id).

apply_filters([[prix, gt, P] | Rest], Id)
    :- prix(Id, _, X),
    X > P,
    apply_filters(Rest, Id).

apply_filters([[accord, eq, X] | Rest], Id) :- 
    accord(Id, X),
    apply_filters(Rest, Id).

apply_filters([[accord, eq, X] | Rest], Id) :-
    accord(Id, Y),
    accord(Y, X),
    apply_filters(Rest, Id).

apply_projections([], _, []).
apply_projections([Id | Rest], Projections, [Value | RestResult]) :-
    apply_projections(Id, Projections, Value),
    apply_projections(Rest, Projections, RestResult).
apply_projections(Id, Projections, Result) :-
    get_projections(Id, Projections, Result).

get_projections(_, [], []).
get_projections(Id, [Projection | Rest], [CurrentValue | OtherValues]) :-
    get_projection(Id, Projection, CurrentValue),
    get_projections(Id, Rest, OtherValues).

get_projection(Id, nom, Value) :-
    nom(Id, NomList),
    atomic_list_concat(NomList, ' ', Value).
get_projection(Id, bouche, Value) :-
    bouche(Id, BoucheList),
    atomic_list_concat(BoucheList, ' ', Value).
get_projection(Id, nez, Value) :-
    nez(Id, NezList),
    atomic_list_concat(NezList, ' ', Value).
get_projection(Id, annee, Value) :-
    annee(Id, Annee),
    atom_number(Value, Annee).
get_projection(Id, prix, Value) :-
    prix(Id, _, PrixMax),
    format(atom(Value), '~2f EUR', [PrixMax]).
get_projection(Id, couleur, Value) :-
    couleur(Id, Couleur),
    Value = Couleur.
get_projection(Id, appelation, Value) :-
    appelation(Id, Appellation),
    Value = Appellation.
get_projection(Id, localite, Value) :- 
    localite(Id, Loc1, Loc2),
    atomic_list_concat([Loc1, Loc2], ', ', Value).
get_projection(Id, description, Value) :-
    description(Id, Desc),
    flatten(Desc, FDesc),
    atomic_list_concat(FDesc, '.', Value).
get_projection(Id, accord, Value) :- accord(Id, Value).
    
%TEST
test_query(L) :- execute_query(query([couleur, nom, annee, prix], [[annee, gt, 2014], [couleur, eq, rouge]], 0, 5, asc(annee)), L).

test_query(Sentence, Result) :- 
    phrase(parse_question(Question), Sentence, _),
    writeln(Question),
    create_query(Question, Query),
    writeln(Query),
    execute_query(Query, Result).
