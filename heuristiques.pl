% heuristiques.pl

:- discontiguous heuristique/2.

heuristique('bourgognes', 'bourgogne').
heuristique('prixs', 'prix').
heuristique('bouches', 'bouche').
heuristique('nezs', 'nez').
heuristique('descriptions', 'description').
heuristique('noels', 'noel').
heuristique('canards', 'canard').
heuristique('gravess', 'graves').
heuristique('hauts', 'haut').
heuristique('noeils', 'noel').
heuristique('noelles', 'noel').
heuristique('repas', 'repas').
heuristique('vins', 'vin').
heuristique('vin\'s', 'vin').
heuristique('vín', 'vin').
heuristique('bouchées', 'bouche').

choisir_meilleure_reponse([], [['Je suis désolé, je ne trouve pas de réponse.']]).
choisir_meilleure_reponse([Reponse|Rest], MeilleureReponse) :-
    choisir_meilleure_reponse(Rest, AutreReponse),
    prioriser_reponse(Reponse, AutreReponse, MeilleureReponse).

% Priorise la réponse avec le plus de détails
prioriser_reponse([], Reponse, Reponse).
prioriser_reponse(Reponse, [], Reponse).
prioriser_reponse(Reponse1, Reponse2, MeilleureReponse) :-
    poids_reponse(Reponse1, Poids1),
    poids_reponse(Reponse2, Poids2),
    (   Poids1 >= Poids2
    ->  MeilleureReponse = Reponse1
    ;   MeilleureReponse = Reponse2).

% Calcul du poids pour une réponse
poids_reponse(Reponse, Poids) :-
    flatten(Reponse, Elements),        % Aplatissement des sous-listes
    length(Elements, NombreElements),  % Compte le nombre total d'éléments
    length(Reponse, NombreLignes),     % Compte les sous-listes
    Poids is NombreElements + 2 * NombreLignes.  % Plus de poids aux lignes