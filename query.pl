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

% parse question 
known_localite(X) :- localite(_, _, Y), downcase_atom(Y, X),!.
known_localite(X) :- localite(_, Y, _), downcase_atom(Y, X),!.
known_appelation(X) :- appelation(_, Y), downcase_atom(Y, X),!.
known_nom_vin(X) :- nom(_, L), atomic_list_concat(L, '_', Y), downcase_atom(Y, X).
parse_vin(Arbre) --> [_], parse_vin(Arbre).
parse_vin(noeud_vin([Couleur, Localite])) --> const_vin, parse_couleur(Couleur), const_de, parse_localite(Localite).
parse_vin(noeud_vin([Localite])) --> const_vin, const_de, parse_localite(Localite).
parse_vin(noeud_vin([Couleur])) --> const_vin, parse_couleur(Couleur).
parse_vin(noeud_vin([])) --> const_vin.
parse_vin(noeud_vin([Couleur, Localite])) --> const_det_couleur, parse_couleur(Couleur), const_de, parse_localite(Localite).
parse_vin(noeud_vin([Couleur])) --> const_det_couleur, parse_couleur(Couleur).
parse_vin(noeud_vin([Appelation])) --> const_det_appelation, parse_appelation(Appelation).
parse_vin(noeud_vin([Appelation, Localite])) --> const_det_appelation, parse_appelation(Appelation), const_de, parse_localite(Localite).
parse_vin(noeud_vin([Appelation, Couleur])) --> const_det_appelation, parse_appelation(Appelation), parse_couleur(Couleur).
parse_vin(noeud_vin([Localite, Couleur])) --> const_vin, const_de, parse_localite(Localite), parse_couleur(Couleur).
parse_question(Question) --> [_], parse_question(Question).
parse_question(noeud_question([Vin])) --> const_mot_instruction, parse_vin(Vin). 
parse_question(noeud_question([Vin, Prix])) --> const_mot_instruction, parse_vin(Vin), parse_prix(Prix). 
parse_question(noeud_question([Vin, Prix])) --> const_mot_instruction, parse_vin(Vin), parse_annee(Prix). 
parse_question(noeud_question([bouche, Nom])) --> const_mot_question, const_verbe_question, const_det_nom_vin, parse_nom_vin(Nom), const_bouche.
parse_question(noeud_question([bouche, Nom])) --> const_mot_question, const_verbe_question, const_bouche, const_det_nom_vin, parse_nom_vin(Nom).
parse_question(noeud_question([nez, Nom])) --> const_mot_question, const_verbe_question, const_det_nom_vin, parse_nom_vin(Nom), const_nez.
parse_question(noeud_question([nez, Nom])) --> const_mot_question, const_verbe_question, const_nez, const_det_nom_vin, parse_nom_vin(Nom).
parse_couleur(noeud_couleur(rouge)) --> [rouge].
parse_couleur(noeud_couleur(rouge)) --> [rouges].
parse_couleur(noeud_couleur(blanc)) --> [blanc].
parse_couleur(noeud_couleur(blanc)) --> [blancs].
parse_couleur(noeud_couleur(rose)) --> [rose].
parse_couleur(noeud_couleur(rose)) --> [roses].
parse_localite(noeud_localite(L)) --> [L], {known_localite(L)}. 
parse_appelation(noeud_appelation(A)) --> [A], {known_appelation(A)}. 
parse_annee(noeud_annee(eq, Annee)) --> const_de, [Annee], {number(Annee)}.
parse_annee(noeud_annee(eq, Annee)) --> const_millesime, [Annee], {number(Annee)}.
parse_annee(noeud_annee(lte, Annee)) --> const_plus_vieux, [Annee], {number(Annee)}.
parse_annee(noeud_annee(gte, Annee)) --> const_plus_recent, [Annee], {number(Annee)}.
parse_prix(noeud_prix(eq, Prix)) --> [Prix], const_euro(), {number(Prix)}.
parse_prix(noeud_prix(eq, Prix)) --> [a], [Prix], const_euro(), {number(Prix)}.
parse_prix(noeud_prix(lte, Prix)) --> const_moins_cher, [Prix], const_euro(), {number(Prix)}. 
parse_prix(noeud_prix(gte, Prix)) --> const_plus_cher, [Prix], const_euro(), {number(Prix)}. 
parse_nom_vin(noeud_nom_vin(Nom)) --> [Nom], {known_nom_vin(Nom)}. 
const_vin() --> [vin].
const_vin() --> [vins].
const_de() --> [de].
const_du() --> [du].
const_des() --> [des].
const_le() --> [le].
const_det_couleur --> [du].
const_det_couleur --> [des].
const_det_couleur --> [un].
const_det_appelation() --> [un].
const_det_appelation() --> [du].
const_det_nom_vin() --> [le].
const_det_nom_vin() --> [du].
const_euro() --> [eur].
const_euro() --> [euro].
const_plus_vieux() --> [plus], [vieux], [que].
const_plus_vieux() --> [moins], [recent], [que].
const_plus_recent() --> [plus], [recent], [que].
const_plus_recent() --> [moins], [vieux], [que].
const_millesime() --> [millesime].
const_plus_cher() --> [prix], [superieur], [a].
const_plus_cher() --> [plus], [cher], [que].
const_plus_cher() --> [a], [plus], [de].
const_moins_cher() --> [prix], [inferieur], [a].
const_moins_cher() --> [moins], [cher], [que].
const_moins_cher() --> [a], [moins], [de].
const_mot_instruction() --> [lister].
const_mot_instruction() --> [liste].
const_mot_instruction() --> [chercher].
const_mot_instruction() --> [cherche].
const_mot_instruction() --> [voudrait].
const_mot_instruction() --> [veux].
const_mot_instruction() --> [trouver].
const_mot_instruction() --> [trouve].
const_bouche() --> [bouche].
const_bouche() --> [la], [bouche].
const_bouche() --> [en], [bouche].
const_nez() --> [nez].
const_nez() --> [au], [nez].
const_nez() --> [le], [nez].
const_mot_question() --> [que].
const_mot_question() --> [quel].
const_mot_question() --> [quelle].
const_verbe_question() --> [donne].
const_verbe_question() --> [vaut].
% Parsing : ?- phrase(parse_vin(Arbre), [je, cherche, un, vin de, 'Bordeaux'], []).

% create query from question
create_query(noeud_question(L), query(Lproj, Lfilters, 0, Take, Sort)) :- 
    create_projections(L, Lproj),
    create_filters(L, Lfilters),
    create_take(L, Take),
    create_sort(L, Lproj, Sort).

create_projections([], []).
create_projections([bouche | T], [bouche | Projections]) :- 
    create_projections(T, Projections).
create_projections([nez | T], [nez | Projections]) :- 
    create_projections(T, Projections).
create_projections([noeud_vin(L) | T], [nom | AllProjections]) :- 
    create_projections(L, Projections), 
    create_projections(T, RestProjections),
    append(Projections, RestProjections, AllProjections).
create_projections([noeud_prix(_, _) | T], [prix | Projections]) :- 
    create_projections(T, Projections).
create_projections([noeud_annee(_, _) | T], [annee | Projections]) :- 
    create_projections(T, Projections).
create_projections([_ | T], Projections) :- 
    create_projections(T, Projections).

create_filters([], []).
create_filters([noeud_vin(L) | T], AllFilters) :- 
    create_filters(L, Filters), 
    create_filters(T, RestFilters),
    append(Filters, RestFilters, AllFilters).
create_filters([noeud_nom_vin(Nom) | T], [[nom, eq, Nom] | RestFilters]) :-
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
create_filters([_ | T], Filters) :- create_filters(T, Filters).

create_take(L, 1) :- member(bouche, L).
create_take(L, 1) :- member(nez, L).
create_take(_, 3).
create_sort(L, _, asc(bouche)) :- member(bouche, L).
create_sort(L, _, asc(nez)) :- member(nez, L).
create_sort(_, Lproj, asc(nom)) :- member(nom, Lproj).

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

%TEST
test_query(L) :- execute_query(query([couleur, nom, annee, prix], [[annee, gt, 2014], [couleur, eq, rouge]], 0, 5, asc(annee)), L).

test_create_query(Sentence, Result) :- 
    phrase(parse_question(Question), Sentence),
    create_query(Question, Query),
    execute_query(Query, Result).