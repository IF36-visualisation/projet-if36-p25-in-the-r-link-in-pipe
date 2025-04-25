# 🎮 Projet IF36 – Analyse des temps de complétion des jeux vidéo

## 🧭 Introduction

Lorsque nous avons dû choisir un sujet de projet pour visualiser des données, nous avons assez rapidement pensé aux **jeux vidéo**. C’est un domaine qui nous rassemble, qui parle à tout le monde dans notre groupe, et qui nous donne envie de travailler dessous. Nous voulions alors explorer un jeu de données à la fois accessible, complet, et compréhensible pour nous.

### 🗃️ Données

**📄 Source**

Ainsi, notre objectif principal est d'analyser le temps de complétion de différents jeus vidéos afin de voir par quoi il est impacté. Pour ce faire, nous avons donc sélectionné un jeu de données appelé Video Games Playtime, **Auteur Kaggle :** [baraazaid](https://www.kaggle.com/baraazaid), que nous avons trouvé sur [Kaggle](https://www.kaggle.com/datasets/baraazaid/how-long-to-beat-video-games) et qui remplissait nos critères. ll est basé sur les données du site [How Long To Beat](https://howlongtobeat.com), qui recense des données sur le temps nécessaire pour terminer un jeu vidéo, selon différents styles de jeu. Ce jeu de données a été mis à jour pour la dernière fois en **2023**. Le fichier est au format **jsonlines** et contient **60 410 entrées**.

---

**📦 Description détaillée des variables**

Plusieurs variables nous intéressent :

- `Single-Player_Main Story_Average` : temps moyen pour terminer l’histoire principale en solo.
- `Single-Player_Main + Extras_Average` : temps moyen pour l’histoire principale avec le contenu additionnel.
- `Single-Player_Completionist_Average` : temps moyen pour terminer le jeu à 100%.
- `Single-Player_All PlayStyles_Average` : temps moyen tous styles de joueurs confondus.
- `Single-Player_Main Story_Rushed` et `Single-Player_Main Story_Leisure` : estiment les temps pour une complétion rapide ou détendue.
- Pour chaque temps de jeu, des variables supplémentaires telles que `Polled`, `Median`, `Rushed`, `Leisure` permettent d’explorer :
  - Le nombre de joueurs sondés (`Polled`)
  - La médiane (`Median`)
  - Le style de jeu rapide (`Rushed`) ou détendu (`Leisure`)

Autres variables notables :
- `Genres` : liste des genres associés à chaque jeu (type `character`).
- `Review_score` : note moyenne attribuée par les joueurs (type `integer`, en pourcentage).
- `Release_date` : date de sortie du jeu (type `character`, au format `YYYY-MM-DD`).
- `Platform` : liste des plateformes sur lesquelles le jeu est disponible (type `character`).
- `Name` : titre du jeu (type `character`).

---

**🧩 Données complémentaires potentielles : **

#### 1️⃣ OpenCritic

Afin d’enrichir notre analyse et de croiser les points de vue entre joueurs et professionnels, nous avons mis de côté un potentiel second jeu de données. En complément du premier dataset, nous avons sélectionné **OpenCritic Ratings for all games and platforms**, contenant les évaluations issues de la presse spécialisée. Ce dataset provient du site [OpenCritic](https://opencritic.com), et permet de croiser :

- Le **score moyen agrégé** de la presse  
- Une **classification qualitative OpenCritic** (ex. "Mighty", "Strong", etc.)  
- Les **plateformes**, la **date de sortie** et l’**URL OpenCritic** de chaque jeu  

Ce fichier est un `.csv` comportant 6 variables (toutes au format texte), avec des dates sous la forme `"Month Day, Year"` (ex: `"January 1, 2023"`). Il couvre tous les jeux sortis jusqu’en 2023.

Ce second dataset pourrait nous permettre de comparer les **avis des joueurs** (depuis `How Long To Beat`) avec ceux de la **presse spécialisée** (via `OpenCritic`) par exemple.

---

#### 2️⃣ Steam Playtime & Engagement

Pour élargir notre perspective sur les comportements de jeu et les durées de complétion, nous avons également considéré un **troisième jeu de données** extrait de la plateforme **Steam**, souvent utilisée comme référence dans l’analyse des tendances vidéoludiques.

Ce fichier, intitulé `steam.csv`, contient des données publiques relatives à plus de **27 000 jeux** publiés sur Steam. Il regroupe à la fois des métadonnées (comme le développeur, la date de sortie, le prix) et des mesures d’engagement des joueurs, notamment les **temps de jeu moyens**, les **notes positives/négatives**, et les **nombre d’achievements**.

Parmi les variables les plus utiles pour notre projet :

- `average_playtime` : temps de jeu moyen en minutes (sur tous les joueurs).
- `median_playtime` : temps de jeu médian.
- `positive_ratings` / `negative_ratings` : nombre total d’évaluations positives et négatives laissées sur le jeu.
- `owners` : fourchette estimée du nombre de propriétaires du jeu (ex. : "1,000,000-2,000,000").
- `release_date` : date de sortie au format `YYYY-MM-DD`.
- `price` : prix affiché du jeu au moment de l’extraction.
- `categories`, `genres`, `steamspy_tags` : diverses classifications décrivant le gameplay et le contenu.
- `platforms` : plateformes supportées (Windows, Mac, Linux).
- `developer` / `publisher` : entités de développement et de publication.

L’intérêt de ce dataset est de pouvoir **relier le temps de jeu réel observé sur Steam** avec les **temps de complétion déclarés** sur HowLongToBeat, et de confronter cela aux **notes utilisateur Steam** ou encore à la **popularité** mesurée par le nombre d’owners. Il offre également un aperçu de l’**engagement général des joueurs** indépendamment du style de complétion.
---


### 🧠 Plan d’analyse

Avant toute chose, nous avons réfléchi aux questions que nous souhaitons poser à nos données, aux croisements de variables intéressants, et aux méthodes de visualisation potentielles.

**🎯 Objectifs & interrogations**

- Quels sont les facteurs qui influencent le temps de complétion d’un jeu vidéo ?
- Sur quelles parties les joueurs passent-ils le plus de temps (main story, extras, completionist) ?
- Les temps de complétion varient-ils selon la plateforme ?
- Combien de temps les joueurs passent-ils à jouer en moyenne ?
- Y a-t-il une corrélation entre le temps de jeu et la note du jeu ? la date de sortie ? les genres ?
- Quels sont les jeux les plus longs et les plus courts ? Appartiennent-ils à certains genres ?
- Les modes multijoueurs (coopératif ou compétitif) influencent-ils la durée de jeu ?

---

**🔄 Variables à comparer**

D'une façon générale nous voulons comparer les temps moyens de complétion :
- Pour chaque mode de complétion (`Completionist`, `Speedrun`, `Multi-Player`...)
- Par plateforme (si disponible)
- Par genre(s) des jeux
- Par année (ou mois) de publication
- Par note (`Review_score`)
- Par extrêmes des temps de jeu : valeurs minimales et maximales
Nous pouvons aussi comparer le taux de complétion par rapport au prix du jeu pour voir si les joueurs sont plus investis en payant plus cher.
Comparaison du playtime Steam vs HowLongToBeat (vérifie siles joueurs jouent plus ou moins longtemps que ce qui est annoncé comme temps "complet".)


---

**🧰 Méthodes envisagées**

Selon les variables analysées, nous envisageons d’utiliser :
- Des **histogrammes** pour visualiser les distributions de temps
- Des **boîtes à moustaches** (boxplots) pour comparer les genres ou années
- Des **courbes temporelles** pour étudier l’évolution dans le temps
- **D'autres visualisations adéquates** pour explorer les corrélations (temps vs note, par exemple)
- Des **matrices de corrélation** pour visualiser les corrélations entre plusieurs variables quantitatives (playtime, ratings, score, price)
- Des **Bargraph** pour visualiser la distribution des temps de jeu en fonction des genres/modes de jeu

---

**⚠️ Limites anticipées**

- Certaines durées sont enregistrées en format texte (`"12h 30m"`) et devront être transformées en **valeurs numériques** (minutes ou heures).
- Les colonnes comme `Genres` contiennent plusieurs genres séparés par des délimiteurs ; (`"Third-Person, Action, Adventure, Role-Playing"` ==> phase de **nettoyage**).
- Faire attention aux données qui peuvent être **manquantes** ou **aberrantes**.


---

