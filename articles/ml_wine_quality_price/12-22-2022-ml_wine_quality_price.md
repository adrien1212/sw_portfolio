---
title: Prédire la qualité et le prix d'un vin
author: Adrien CAUBEL
date: 22/12/2022
keywords: Machine Learning, Wine, Regression, Classification
---

Dans cet article nous résumons le travail réalisé [ici](tp_regression.pdf) permettant de prédire la qualité puis le prix d'un vin. Pour ce faire nous utilisons deux dataset :

* Le premier nous donne des informations sur la qualité du vin via des données scientifiques
* Le second permet d'avoir le prix du vin en fonction de sa région, son Chateaux et son année

# Prédire la qualité d'un vin
Nous obtenons de meilleurs résultats si nous divisons notre problème en deux. Au lieu de donner directement une note via la régression nous allons :

1. Classer l'observation en *mauvaise*, *moyenne* ou *excellente*
2. Pour chaque classe appliquer un modèle de regression pour avoir une note

Ainsi, en ayant 4 modèles (1 de classifition et 3 de régression) les notes obtenues sont plus proches que des notes obtenues en appliquant un seul modèle de regression.

## Classifier le vin


## Donner une note
Nous avons déterminer les meilleurs hyperparamètres pour plusieurs modèles. Les MAEs et R2 score de chaque algorithmes sont présentés ci-dessous

# Donner un prix
Cette seconde partie s'est avéré plus compliquée car il n'y a très peu de corrélation entre les variables explicatives (qualité, pays et l'année) et la variable expliquée (le prix). On remarque cela graphiquement avec Weka ou avec le R2 score qui est proche de 0.

Ainsi, les modèles obtenus par regression ne sont pas exploitables. Cependant, le R2 score n'étant pas nul, nous pouvons essayer d'améliorer nos modèles mais cela demande plus de temps et de connaissances.