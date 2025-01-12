% grandgousier.pl
:- set_prolog_flag(encoding, utf8).
:- dynamic previous_query/1.

:- [vins].
:- [query].
:- [regles].
:- [input].

/* --------------------------------------------------------------------- */
/*                                                                       */
/*        PRODUIRE_REPONSE(L_Mots,L_Lignes_reponse) :        */
/*                                                                       */
/*        Input : une liste de mots L_Mots representant la question      */
/*                de l'utilisateur                                       */
/*        Output : une liste de liste de lignes correspondant a la       */
/*                 reponse fournie par le bot                            */
/*                                                                       */
/* --------------------------------------------------------------------- */

produire_reponse([fin], [L1]) :-
    L1 = 'Merci de m\'avoir consulté.', !, retractall(previous_query(_)).
produire_reponse(Question, Reponse) :-
    nettoyer_mots(Question, MotsNettoyes),
    harmoniser_mots(MotsNettoyes, MotsHarmonises),
    standardise_nom_vin(MotsHarmonises, NomVinStandardises),
    (
        (previous_query(PreviousQuery), demande_plus_de_resultats(NomVinStandardises)) -> 
        (
            PreviousQuery = query(Lproj, Lfilters, Skip, Take, Sort),
            NewSkip is Skip + Take,
            Query = query(Lproj, Lfilters, NewSkip, Take, Sort) 
        ) ;
        (
            phrase(parse_question(ParsedQuestion), NomVinStandardises, _),
            create_query(ParsedQuestion, Query)
        )
    )
    ,!,
    retractall(previous_query(_)),
    assertz(previous_query(Query)),
    regle_rep(Query, Reponse).
produire_reponse(_, ['Je suis désolé je ne comprends pas votre question.']). 
demande_plus_de_resultats(Question) :- subset(['autres', 'vins'], Question).
demande_plus_de_resultats(Question) :- subset(['plus', 'de', 'vins'], Question).
demande_plus_de_resultats(Question) :- subset(['plus', 'de', 'suggestions'], Question).
demande_plus_de_resultats(Question) :- subset(['autres', 'suggestions'], Question).
demande_plus_de_resultats(Question) :- subset(['de', 'nouvelles','suggestions'], Question).
/* --------------------------------------------------------------------- */
/*                                                                       */
/*          CONVERSION D'UNE QUESTION DE L'UTILISATEUR EN                */
/*                        LISTE DE MOTS                                  */
/*                                                                       */
/* --------------------------------------------------------------------- */

% lire_question(L_Mots)

% Utilisez le prédicat défini dans extraction_mots_cles.pl
% lire_question(LMots) :- extraction_mots_cles:lire_question(LMots).

/* --------------------------------------------------------------------- */
/*                                                                       */
/*        ECRIRE_REPONSE : ecrit une suite de lignes de texte            */
/*                                                                       */
/* --------------------------------------------------------------------- */

% Affiche les réponses sous forme lisible
ecrire_reponse([]) :- nl.
ecrire_reponse([Ligne|Rest]) :-
    (   is_list(Ligne)
    ->  atomic_list_concat(Ligne, ' ', Texte)
    ;   Texte = Ligne),
    write('GGS : '), write(Texte), nl,
    ecrire_reponse(Rest).

% ecrire_li_reponse(Ll,M,E)
% input : Ll, liste de listes de mots (tout en minuscules)
%         M, indique si le premier caractere du premier mot de
%            la premiere ligne doit etre mis en majuscule (1 si oui, 0 si non)
%         E, indique le nombre d'espaces avant ce premier mot

ecrire_li_reponse([],_,_) :-
    nl.

ecrire_li_reponse([Li|Lls],Mi,Ei) :-
   ecrire_ligne(Li,Mi,Ei,Mf),
   ecrire_li_reponse(Lls,Mf,2).

% ecrire_ligne(Li,Mi,Ei,Mf)
% input : Li, liste de mots a ecrire
%         Mi, Ei booleens tels que decrits ci-dessus
% output : Mf, booleen tel que decrit ci-dessus a appliquer
%          a la ligne suivante, si elle existe

ecrire_ligne([],M,_,M) :-
   nl.

ecrire_ligne([M|L],Mi,Ei,Mf) :-
   ecrire_mot(M,Mi,Maux,Ei,Eaux),
   ecrire_ligne(L,Maux,Eaux,Mf).

% ecrire_mot(M,B1,B2,E1,E2)
% input : M, le mot a ecrire
%         B1, indique s'il faut une majuscule (1 si oui, 0 si non)
%         E1, indique s'il faut un espace avant le mot (1 si oui, 0 si non)
% output : B2, indique si le mot suivant prend une majuscule
%          E2, indique si le mot suivant doit etre precede d'un espace

ecrire_mot('.',_,1,_,1) :-
   write('. '), !.
ecrire_mot('\'',X,X,_,0) :-
   write('\''), !.
ecrire_mot(',',X,X,E,1) :-
   espace(E), write(','), !.
ecrire_mot(M,0,0,E,1) :-
   espace(E), write(M).
ecrire_mot(M,1,0,E,1) :-
   name(M,[C|L]),
   D is C - 32,
   name(N,[D|L]),
   espace(E), write(N).

espace(0).
espace(N) :- N>0, Nn is N-1, write(' '), espace(Nn).

/* --------------------------------------------------------------------- */
/*                                                                       */
/*                            TEST DE FIN                                */
/*                                                                       */
/* --------------------------------------------------------------------- */

fin(L) :- member(fin,L).

/* --------------------------------------------------------------------- */
/*                                                                       */
/*                         BOUCLE PRINCIPALE                             */
/*                                                                       */
/* --------------------------------------------------------------------- */

grandgousier :-
    nl,
    write('Bonjour, je suis Grandgousier, GGS pour les intimes, '), nl,
	write('conseiller en vin. En quoi puis-je vous être utile ?'), nl,
    lire_question(Question),
    (   Question = [fin]
    ->  write('GGS : Merci de m\'avoir consulté.'), nl
    ;   produire_reponse(Question, Reponse),
        afficher_reponse(Reponse),
        grandgousier).
		
lire_question(Question, MotsCles) :-
    extraction_mots_cles:extraire_mots(Question, MotsCles).

% Affiche la réponse finalisée
afficher_reponse([]) :-
    write('GGS : Je suis désolé, je ne trouve pas de réponse.'), nl.
afficher_reponse(Liste) :-
    Liste \= [],
    afficher_lignes(Liste).

afficher_lignes([]).
afficher_lignes([Ligne|Rest]) :-
    Ligne \= [],
    write('GGS : '), write(Ligne), nl,
    afficher_lignes(Rest).
/* --------------------------------------------------------------------- */
/*                                                                       */
/*             ACTIVATION DU PROGRAMME APRES COMPILATION                 */
/*                                                                       */
/* --------------------------------------------------------------------- */

:- grandgousier.
