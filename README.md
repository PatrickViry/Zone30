# Zone30
Measure vehicle speeds using a webcam 

----------------

Zone30 permet de mesurer la vitesse des véhicules à l'aide d'une webcam, et de fournir des
statistiques sous forme d'histogramme de vitesses et de nombre de véhicules par heure.

L'idée est de viser une rue à l'aide d'une webcam, de placer des repères sur l'image pour 
indiquer les zones de mesure, et de laisser le logiciel travailler.

La précision atteignable dépend de la distance entre les repères (plus long = plus de précision)
et du nombre d'images par seconde de la caméra (fps, frames per second, plus d'images = plus de précision).

Par exemple, avec 30 images par seconde on a une précision maximale de 33ms. Si la distance entre 2 repères
est de 10m, alors on a une précision de
    vers 30km/h -> 1km/h
    vers 40km/h -> 2km/h
    vers 50km/h -> 3km/h
    ...
    vers 100km/h -> 10km/h

Installation
------------

- Installer Processing en suivant les instructions sur processing.org. Zone30 a été testé avec la version 3.5.4
- Télécharger le sketch Zone30 sur ... et le dézipper à un endroit qui vous plait
- Lancer Processing, ouvrir le sketch Zone30, le lancer en cliquant sur "Exécuter"


Utilisation
-----------

La première chose va être de lire un flux vidéo sur votre caméra. Au démarrage, Zone30 affiche la liste des caméras disponibles dans la console Processing (la petite zone de texte sous le programme), avec les résolutions et vitesses disponibles. Par exemple:
```
Available cameras:
name=Logitech HD Webcam C270,size=640x480,fps=5
name=Logitech HD Webcam C270,size=640x480,fps=30
name=Logitech HD Webcam C270,size=160x120,fps=5
name=Logitech HD Webcam C270,size=160x120,fps=30
...
```
Choisissez la caméra que vous souhaitez utiliser, avec la résolution et le fps maximaux.

Les paramètres de la caméra doivent être entrés avec un éditeur de texte dans le fichier zone30.json, présent dans le répertoire du sketch. Par exemple:

    {
      "cameraName": "Logitech HD Webcam C270",
     "frameRate": 30,
      "width": 1280,
      "height": 960,
      ... (ne vous occupez pas des autres paramètres pour l'instant / l'ordre n'est pas important)
    }

Sauvez zone30.json et relancez Zone30, le programme devrait utiliser la caméra que vous avez spécifié. Si tout va bien jusque là, vous voyez maintenant l'image de la caméra sur laquelle se superposent deux détecteurs.

Chaque détecteur va mesurer le temps pris par un objet mouvant entre les deux lignes du détecteur. La flèche indique le sens de détection. Fixez bien la caméra pour que l'image ne bouge plus. Cliquez dans l'image pour obtenir le focus, puis sélectionnez des points avec la barre espace (en avant) ou maj+barre espace (en arrière). Placez chaque point sur l'image en utilisant les flèches du clavier. 

Quand vous arrêtez proprement le programme (en fermant la fenêtre, pas en appuyant sur le bouton Arrêter), toutes ces positions sont enregistrées dans zone30.json et seront réutilisées la fois suivante. 

Le dernier paramètre important est la distance réelle entre les deux lignes du détecteur. Sortez avec un décamètre et allez mesurer. Allez ensuite reporter ces distances (en mètres) dans zone30.json:

    {
      "detector1": {
        "distance": 10.25,
        "name": "Voie montante",
        ...
      },
      "detector2": {
        "distance": 18.10,
        "name": "Voie descendante",
        ...
      },
      ..
    }

Vous pouvez aussi en profiter pour donner des noms parlants aux deux détecteurs, et en modifier la couleur.

Maintenant il n'y a plus qu'à laisser tourner le programme. Vous pouvez voir deux histogrammes sur l'écran qui vous donnent des statistiques sur les vitesses mesurées ainsi que le nombre de véhicules détectés. 

Pour chaque campagne de mesure, Zone30 crée un fichier log avec le détail de toutes les mesures. Ce fichier se trouve
dans le répertorie d'installation de Processing (attention, pas le répertoire du sketch) et a un nom de la forme
'transit-2020-05-23-172629.log' comprenant la date et l'heure de lancement du programme.

A l'intérieur de ce fichier, chaque détection est représentée par une ligne de la forme
Lane1, 2020-05-23 18:03:02, 15km/h
contenant
- le nom du détecteur
- la date
- l'heure
- la vitesse mesurée (il faut donc avoir renseigné correctement la distance)

Pour établir des statistiques à partir de ces fichiers log, un autre programme est nécessaire, il reste à écrire (avis aux bonnes volontés!).


Problèmes et améliorations
--------------------------

- Beaucoup de fausses détections, quand l'arrière d'un véhicule touche un détecteur avant l'avant d'un autre. En général ça produit des vitesses aberrantes (comme 200km/h en centre-ville), il suffit de ne pas tenir compte des extrêmes.

- C'est une toute première version. Signalez problèmes et suggestions à l'auteur.

