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

.

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

apply_filters([[annee, te, A] | Rest], Id)
    :- annee(Id, X),
    X =< A,
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
get_projection(Id, annee, Value) :-
    annee(Id, Annee),
    atom_number(Value, Annee).
get_projection(Id, prix, Value) :-
    prix(Id, PrixMin, PrixMax),
    format(atom(Value), 'Prix: ~2f htva - ~2f tvac', [PrixMin, PrixMax]).
get_projection(Id, couleur, Value) :-
    couleur(Id, Couleur),
    Value = Couleur.
get_projection(Id, appelation, Value) :-
    appelation(Id, Appellation),
    Value = Appellation.

test_query(L) :- execute_query(query([couleur, nom, annee, prix], [[annee, gt, 2014], [couleur, eq, rouge]], 0, 5, asc(annee)), L).