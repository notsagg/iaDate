# iaDate

## Introduction
L'heure UNIX est le nombre de secondes écoulées depuis le 1 Janvier 1970. Ce compte présente une précision d'une seconde près ce dont la majorité des applications n'ont aucune utilité pour. C'est là que l'heure ia entre en jeu.

La class iaDate a été écrite dans l'objectif de réduire la quantité de stockage nécessaire pour stocker une date. Cette classe a initialement été développé pour stocker une date de début et de fin d'un évènement entré dans un calendrier. Le stockage étant vite devenu un problème, il s'est avéré qu'une précision de plus de 5 minutes était inutile.

Contrairement à l'heure UNIX, l'heure ia correspond aux nombres de blocs de 5 minutes qui se sont écoulé depuis le 1 Janvier 2001. Cette classe offre donc un support de conversion entre une date classique, l'heure UNIX et l'heure ia. D'abord écrite en Swift pour une application IOS fonctionnant avec UIKit, la classe présente des fonctionnalités propre au langage qui ne seront pas forcément disponible dans son écriture dans un autre langage informatique.

## Licence

Ce projet est sous licence GNU GPLv3.
