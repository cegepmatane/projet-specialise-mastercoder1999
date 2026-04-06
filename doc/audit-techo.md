https://chatgpt.com/g/g-p-698a4503f82081918fec2722e85cd547-potion-man-projet-specialise/shared/c/69d40b6a-41a8-8332-b9d4-f1930de38acf?owner_user_id=user-Rn1SNWjy3c8NKAbFmqE4gGbY

Question :
```
Tu es un consultant technique senior spécialisé dans
l'évaluation de projets logiciels. Ton rôle est d'évaluer
la santé technologique de mon projet.

Voici le contexte :
- [COLLER : description, technologies, objectifs]
- [COLLER : liste des dépendances avec versions]
- [JOINDRE : fichier de dépendances]

Confirme que tu comprends :
1. La nature du projet
2. Les technologies et leurs versions
3. Les dépendances critiques
Pose-moi des questions si nécessaire.
```
Reponse :
```
Oui. Voici ce que je comprends à partir des fichiers du projet.

Nature du projet
Ton projet est Potion Man, un jeu 3D de création de potions au style visuel PSX / PlayStation 1. Le joueur explore une forêt hostile, récolte des ingrédients, découvre des recettes via des pages de grimoire, fabrique des potions, combat des ennemis, puis revient se mettre à l’abri avant le jour. Le prototype fonctionnel vise aussi un inventaire et une interface de création de potions.
Technologies et versions
Je peux confirmer les technologies principales suivantes :
Godot Engine comme moteur principal du jeu.
SQLite comme base de données locale pour stocker les données d’herbes, potions et potentiellement une partie de la persistance.
Formats et composants techniques déjà identifiés : scènes 3D Godot, collisions, UI, audio 3D, particules, modèles glTF 2.0 (.glb), textures PNG, audio OGG/WAV, polices TTF/OTF, sauvegarde JSON ou ConfigFile.

Sur les versions, je dois être précis :

Je ne vois pas de version explicitement figée dans les documents pour Godot, SQLite, .NET/C#, ni pour les plugins éventuels.
Il y a des indices que tu travailles probablement dans l’écosystème Godot 4 parce que la veille et certains éléments mentionnent Godot 4 / la documentation stable récente, mais ce n’est pas assez formel pour que je le confirme comme version officielle du projet.
Dépendances critiques
Les dépendances critiques que je peux confirmer ou déduire fortement depuis les fiches sont :
Le couplage Godot ↔ base de données : c’est explicitement identifié comme le risque technique principal du projet. Au départ, la PoC testait même un lien avec une base externe / MySQL, puis la décision technologique cible semble revenir vers SQLite locale pour réduire le risque et mieux convenir au type de jeu.
La couche de persistance : DBService.gd, PotionRepository.gd, RecipeRepository.gd, InventoryService.gd, CraftService.gd, SaveService.gd. Ces scripts sont structurants pour l’architecture applicative.
Assets externes et shaders PSX : tu dépends d’assets 3D rétro, de shaders type PSX, et d’un pipeline d’import .glb / textures / audio cohérent.
UI gameplay critique : l’inventaire et le craft ne sont pas juste décoratifs, ils sont au cœur de la boucle de jeu et donc critiques pour la validation du prototype.

Mon constat d’évaluation préliminaire est donc :

Vision produit claire
Stack principale cohérente pour un jeu solo 3D stylisé
Versions et dépendances exécutables encore insuffisamment figées dans la documentation
Risque majeur concentré sur la persistance des données et l’intégration DB / gameplay
```
Annotation :
- ✅ L'IA comprends se que le projet utilise et ce qu'elle va devoir regarder pour confirmer la veille
Question :
```
Effectue un audit technologique complet.

A) Santé des dépendances
- Maintenues ? Deprecated ? CVE connues ?

B) Maturité de la techno principale
- Communauté, croissance, risques de rupture ?

C) Architecture et choix techniques
- Bonnes pratiques ? Anti-patterns ? Alternatives ?

D) Alternatives émergentes
- Technologies de remplacement ? Coût migration ?

Tableaux quand pertinent.
```

Réponse :
```
Je combine les docs du projet avec une vérification web pour distinguer ce qui est documenté dans tes fichiers de l’état réel des technos aujourd’hui, notamment maintenance, sécurité et alternatives.

J’ai déjà un point important : ton architecture cible est plus saine que la PoC initiale, parce que les docs montrent un passage de MySQL externe vers SQLite local, ce qui réduit fortement le risque opérationnel pour un jeu solo.

Thought for 1m 36s

Voici un audit technologique complet de ton projet Potion Man, basé sur tes documents de projet et sur l’état actuel des technologies au 6 avril 2026.

Ton projet est un jeu 3D Godot au style PSX, avec scripts en GDScript (.gd), une base locale SQLite, et une architecture logique déjà pensée autour de services comme DBService.gd, InventoryService.gd, CraftService.gd et SaveService.gd. La documentation montre aussi que le risque principal identifié au départ était le lien jeu ↔ base de données, d’abord exploré avec une PoC MySQL externe puis recentré vers SQLite local, ce qui est nettement plus cohérent pour un jeu solo comme le tien.

Verdict exécutif

État global : bon, avec quelques points à solidifier.

Choix principal Godot + GDScript + SQLite local : pertinent
Risque techno : faible à modéré
Risque architecture : surtout sur la séparation données statiques / sauvegarde / logique métier
Risque dépendances : actuellement mal maîtrisé sur le plan documentaire, car les versions exactes et le binding SQLite précis ne sont pas figés dans les docs
Remplacement technologique non recommandé à court terme : tu as déjà une stack adaptée au scope

Ma note synthèse :
| Axe                         | Évaluation                    |
| --------------------------- | ----------------------------- |
| Adéquation au projet        | **Très bonne**                |
| Maturité techno principale  | **Bonne à très bonne**        |
| Risque de rupture           | **Faible**                    |
| Risque sécurité             | **Faible à modéré**           |
| Dette technique potentielle | **Modérée**                   |
| Besoin de migration         | **Non recommandé maintenant** |

A) Santé des dépendances
1) Godot Engine

Godot est activement maintenu. Le site officiel affiche Godot 4.6.2 en maintenance release au 1er avril 2026, et la politique de release indique que Godot 4.6 et 3.6 sont supportés, tandis que 4.4, 4.3, 4.2, 4.1 et 4.0 sont EOL. Pour un nouveau projet, la documentation recommande explicitement Godot 4.x.

Conséquence pour toi :

si tu es en Godot 4.6.x, ta situation est saine ;
si tu es sur une branche plus ancienne, surtout 4.4 ou moins, il y a un risque de support et de correctifs.
2) GDScript

GDScript reste une techno maintenue et native à Godot. La doc officielle le décrit comme un langage graduellement typé, fortement intégré au moteur. Godot rappelle aussi que GDScript est généralement assez performant pour la logique gameplay, même s’il reste moins rapide que C# ou C++. La doc officielle recommande le typed GDScript pour une meilleure structure, moins d’erreurs, plus de scalabilité, et un peu de gain de performance.

Conséquence :

ton choix .gd est bon pour un projet scolaire/indie de ce type ;
le vrai risque n’est pas le langage lui-même, mais un codebase trop dynamique, peu typé, trop couplé aux nodes et aux autoloads.
3) SQLite

SQLite est extrêmement maintenu. Le site officiel publie régulièrement les releases ; la branche continue d’évoluer et les CVEs sont documentées de façon transparente sur le site officiel. SQLite rappelle aussi très clairement son positionnement : il vise le stockage local embarqué, pas un rôle de base centralisée client/serveur. Pour ton cas, c’est un excellent fit.

4) CVE connues
Godot

Il existe des CVE historiques sur Godot, notamment :

CVE-2018-1000224 sur la désérialisation réseau,
CVE-2019-10069 sur une politique de désérialisation incorrecte,
CVE-2021-26825 et CVE-2021-26826 liées au chargement de fichiers .TGA.

Pour ton projet, ces vulnérabilités sont surtout pertinentes si :

tu charges des assets non fiables,
tu fais du réseau,
tu laisses entrer des fichiers externes non validés.

Dans un jeu solo local sans modding ouvert ni réseau exposé, le risque pratique est faible, mais il faut éviter de rester sur des versions EOL. La communication de Godot sur le sujet sécurité existe, avec une adresse de signalement officielle, mais Godot n’est pas présenté comme un moteur “durci sécurité” par défaut.

SQLite

SQLite affiche plusieurs CVEs récentes sur son site officiel, par exemple :

CVE-2024-0232,
CVE-2025-29088,
CVE-2025-6965,
CVE-2025-7709.

Mais il faut bien lire la nature de ces failles : beaucoup supposent que l’attaquant peut injecter du SQL arbitraire, contrôler la base, ou fournir une entrée malveillante très spécifique. Dans ton projet local solo, le risque réel est surtout :

d’embarquer une vieille build SQLite,
d’utiliser une lib de binding non maintenue,
ou de charger une base modifiée par un tiers.
5) Dépendances critiques de ton projet

À partir de tes docs, les dépendances critiques sont :
| Dépendance             | Santé          | Risque principal                  | Commentaire                                              |
| ---------------------- | -------------- | --------------------------------- | -------------------------------------------------------- |
| Godot Engine           | Bonne si 4.6.x | obsolescence si version EOL       | moteur adapté au scope ([Godot Engine documentation][1]) |
| GDScript               | Bonne          | dette de code si non typé         | bon fit pour gameplay ([Godot Engine documentation][2])  |
| SQLite                 | Très bonne     | usage hors-cible / vieux binding  | très pertinent en local ([sqlite.org][3])                |
| Shader/asset tiers     | Variable       | maintenance/licence/compatibilité | dépend de la source réelle                               |
| Binding SQLite Godot   | **Inconnu**    | maintenance/CVE inconnues         | point non documenté                                      |
| Tes autoloads/services | Interne        | couplage excessif                 | principal risque d’architecture                          |

[1]: https://docs.godotengine.org/en/stable/about/release_policy.html "Godot release policy — Godot Engine (stable) documentation in English"
[2]: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/static_typing.html?utm_source=chatgpt.com "Static typing in GDScript - Godot Docs"
[3]: https://sqlite.org/whentouse.html?utm_source=chatgpt.com "Appropriate Uses For SQLite"

Conclusion A

Maintenues ?
Oui pour Godot, GDScript et SQLite.

Deprecated ?
Pas les technologies elles-mêmes, mais certaines versions Godot sont EOL.

CVE connues ?
Oui, pour Godot historiquement et pour SQLite récemment. Leur criticité pratique dans ton projet reste modérée à faible si tu es à jour et si tu restes sur un usage local/offline.

B) Maturité de la techno principale
Godot

Godot a aujourd’hui une maturité solide. Le dépôt officiel souligne plus de 10 ans de développement ouvert et indique des contributions de 2 800 utilisateurs au code à fin 2024. Les releases stables et maintenance releases sont fréquentes, et la gouvernance projet est claire.

Communauté

La communauté Godot est grande, active, et structurée autour :

de la doc officielle,
du GitHub principal,
du forum officiel,
de la bibliothèque d’assets,
des propositions d’amélioration publiques.
Croissance

Je n’irais pas jusqu’à te donner une métrique de marché précise ici sans surcharger l’audit, mais tous les signaux visibles sont ceux d’un moteur en croissance continue, avec cadence de release soutenue et écosystème contributif réel.

Risques de rupture

Les vrais risques de rupture pour toi ne sont pas “Godot va disparaître”, mais plutôt :

Rupture de compatibilité mineure entre versions 4.x
Godot explique que les upgrades sont généralement compatibles, mais qu’upgrader pendant le développement reste risqué.
Documentation communautaire parfois en retard
La doc officielle note qu’une partie de la documentation tierce n’est pas toujours alignée avec Godot 4.x.
3D plus exigeante que 2D
Godot est très bon pour de l’indie 3D stylisée, mais moins “clé en main AAA” qu’Unreal. Cela ne pose pas problème pour un projet PSX stylisé comme le tien.
Conclusion B

Pour un jeu comme Potion Man, la maturité de la techno principale est suffisante et rassurante.
Le risque de rupture existe surtout si tu :

ne fixes pas une version moteur,
multiplies les plugins tiers,
ou changes de branche en cours d’itération.
C) Architecture et choix techniques

Tes documents décrivent une architecture avec :

DBService.gd
PotionRepository.gd
RecipeRepository.gd
InventoryService.gd
CraftService.gd
SaveService.gd

Globalement, c’est une bonne direction. Il y a déjà une volonté de séparation entre accès données, logique métier et sauvegarde. Pour un projet étudiant/indie, c’est mieux que la moyenne.

Ce qui est bien
| Choix                                         | Avis                |
| --------------------------------------------- | ------------------- |
| Godot pour un jeu 3D PSX stylisé              | Très bon choix      |
| GDScript pour gameplay/itération rapide       | Très bon choix      |
| SQLite local pour recettes/herbes/potions     | Bon choix           |
| Services séparés (DB, inventory, craft, save) | Bonne pratique      |
| PoC précoce sur le risque principal           | Très bonne pratique |
Ce qui sent le risque ou l’anti-pattern
1) Mélanger données statiques et sauvegarde joueur

Tes docs indiquent à la fois :

base SQLite pour données,
save.json,
ConfigFile,
éventuellement “save/load dans la db”.

Ça peut vite devenir flou.

Recommandation nette :

SQLite : données de design / contenu semi-statique
(herbes, recettes, métadonnées de potions, tables d’équilibrage)
JSON ou ConfigFile : progression du joueur
(inventaire courant, recettes découvertes, position, état du monde simple)
pas les deux pour la même responsabilité

Sinon tu risques :

duplication de sources de vérité,
bugs de synchronisation,
logique de save trop compliquée.
2) Autoload partout

DBService.gd et InventoryService.gd en autoload peuvent être pertinents, mais trop d’autoloads deviennent vite un global state caché.

Anti-pattern typique :

n’importe quelle scène peut modifier n’importe quel état global
ordre d’initialisation fragile
tests difficiles
dépendances implicites

Règle simple :

garde en autoload seulement les vrais services globaux,
injecte ou référence explicitement le reste.
3) SQLite pour tout

SQLite est excellent pour du local, mais pas pour toutes les responsabilités.

Pour ton jeu :

recettes/herbes/potions : oui
save temps réel ultra fréquent : prudence
état riche d’objets dynamiques en scène : pas idéal comme premier choix

SQLite doit rester un support structuré, pas devenir ton moteur universel de gameplay.

4) Couplage scène ↔ DB

La PoC initiale montrait une logique “télécharger / afficher / stocker” très proche du runtime gameplay.

Pour l’architecture cible, évite :

UI qui requête directement la DB
logique de craft qui parle SQL
scènes de gameplay qui connaissent le schéma de base

La bonne forme est :
Scene/UI → Service métier → Repository → DB

5) GDScript non typé

La doc officielle pousse clairement le typed GDScript pour la maintenabilité.

Pour un inventaire/craft, c’est particulièrement important :

slots,
item stacks,
recipe entries,
retours de services,
enums de résultats.
Alternatives techniques internes plus propres
Option recommandée pour ton projet
Godot 4.6.x
GDScript typé
SQLite pour contenu métier
JSON / ConfigFile pour sauvegarde joueur
Resources .tres envisageables pour une partie des données de design

Les docs Godot rappellent que :

ConfigFile est approprié pour les configs,
JSON sert bien à sérialiser des données, avec limites de types et taille,
les Resources sont nativement sérialisables et versionnables.
Mon jugement sur l’architecture actuelle
| Élément                                                 | Avis             |
| ------------------------------------------------------- | ---------------- |
| séparation services / repository                        | **bon**          |
| choix local-first                                       | **très bon**     |
| PoC basée sur le risque principal                       | **très bon**     |
| persistance globale encore ambiguë                      | **à corriger**   |
| risque de sur-usage des autoloads                       | **à surveiller** |
| risque de faire parler le gameplay directement à SQLite | **à éviter**     |
D) Alternatives émergentes

Je sépare ici moteur et persistance, car ce ne sont pas les mêmes décisions.

1) Alternatives moteur
| Technologie          | Intérêt                                   | Risques                                                                   | Coût de migration depuis ton projet |
| -------------------- | ----------------------------------------- | ------------------------------------------------------------------------- | ----------------------------------- |
| **Rester sur Godot** | meilleur alignement actuel                | aucun coût majeur                                                         | **Très faible**                     |
| **Unity**            | écosystème énorme, tooling mature         | stack plus lourde, migration complète, dépendance éditeur/licence         | **Très élevé**                      |
| **Defold**           | léger, maintenu, docs solides             | moins naturel pour ton type de 3D stylisée complexe                       | **Élevé**                           |
| **Bevy (Rust)**      | moderne, très actif, approche data-driven | workflow radicalement différent, moins productif pour ton contexte actuel | **Très élevé**                      |

Unity

Unity reste très fort côté tooling et écosystème, avec plan Personal gratuit et large couverture de plateformes. Mais pour toi, migrer vers Unity voudrait dire :

réécrire tout le gameplay,
réécrire la persistance,
refaire pipeline de scènes/assets/scripts,
changer d’ergonomie moteur.

Conclusion : non pertinent maintenant.

Defold

Defold est maintenu et dispose bien de docs 3D, mais son ADN est moins aligné que Godot pour un projet 3D de ce type. Defold lui-même annonce encore travailler à améliorer le rendu et le support 3D.

Conclusion : intéressant, mais pas meilleur pour ton cas.

Bevy

Bevy est prometteur, moderne, Rust-first, open source, mais c’est une migration conceptuelle complète vers ECS/Rust. Tu perdrais beaucoup en vélocité à court terme.

Conclusion : technologie émergente à surveiller, pas à adopter en plein projet.

2) Alternatives à SQLite dans ton projet
| Alternative                | Quand c’est meilleur        | Coût migration | Avis               |
| -------------------------- | --------------------------- | -------------- | ------------------ |
| **Resources `.tres/.res`** | données de design statiques | Faible à moyen | très intéressant   |
| **JSON**                   | sauvegardes simples         | Faible         | bon complément     |
| **ConfigFile**             | options/configuration       | Faible         | bon complément     |
| **MySQL / DB distante**    | jeu connecté / live ops     | Très élevé     | mauvais fit actuel |
Resources Godot

Pour tes recettes, définitions d’herbes, potions, les Resources peuvent être plus simples, plus intégrées à l’éditeur, et plus naturelles à versionner que SQLite. Godot supporte leur sérialisation nativement.

Quand préférer Resources à SQLite :

peu de volume de données,
données surtout statiques,
besoin de confort dans l’éditeur,
faible complexité de requêtes.

Pour ton projet, c’est une alternative crédible si tes données restent modestes.

JSON / ConfigFile

Très bien pour la sauvegarde joueur et la config, moins bien pour des données relationnelles riches. Godot le dit lui-même : JSON a des limites de types et de taille.

MySQL / externe

Ta propre PoC montre que c’était le risque majeur. Pour un jeu solo local, ça ajoute :

complexité,
dépendance réseau,
sécurité,
synchronisation,
disponibilité.

Conclusion : à écarter pour ce projet, sauf pivot produit majeur.

Recommandation finale
Ce que je recommande de garder
Godot
GDScript
SQLite local, mais uniquement là où il apporte une vraie valeur
Architecture service/repository que tu as commencé
Ce que je recommande de corriger vite
Figer explicitement les versions
Godot exact
version SQLite
nom précis du binding SQLite si plugin ou module externe
Clarifier les responsabilités de persistance
SQLite = contenu
JSON/ConfigFile = save joueur
pas de chevauchement
Passer en GDScript typé sur les couches critiques
inventaire
recettes
craft
save/load
Réduire le couplage
scènes/UI ne parlent pas SQL
elles parlent à des services
Établir une politique de mise à jour
rester sur une branche supportée
éviter upgrade moteur en plein sprint sans raison
Diagnostic final
| Domaine                        | Diagnostic                        |
| ------------------------------ | --------------------------------- |
| Santé techno actuelle          | **bonne**                         |
| Risque sécurité réel           | **faible à modéré**               |
| Maturité stack                 | **suffisante pour livrer**        |
| Qualité des choix techniques   | **bonne**                         |
| Dette technique probable       | **persistance ambiguë + globals** |
| Nécessité de changer de techno | **non**                           |
En une phrase : ta stack actuelle est la bonne, mais ton projet gagnerait beaucoup en robustesse si tu transformes SQLite en composant bien délimité, au lieu d’en faire un point central flou entre contenu, sauvegarde et logique runtime.
```
Annotation :
- ⚠️ Je suis daccords avec le diagnostic de base, mais il n'y a pas de problèmes avec la database SQLite puisque je l'utilise seulement pour les crafts et cela ne cause pas de problème vu qu'elle ne contient pas l'information précise sur les items du jeu. Cela aide à ne pas devoir appeler la base de données pour tout ce qui est dans la gestion d'item.
Question :
```
Génère un plan d'action priorisé :

HAUTE : vulnérabilités, deps mortes, incompatibilités
MOYENNE : améliorations maintenance post-projet
BASSE : éléments à surveiller long terme

Résumé exécutif : 5-6 lignes.
Note sur 10 de la santé technologique.
```

Réponse :
```
transforme l’audit en plan d’action concret, trié par priorité, avec un cadrage “quoi faire maintenant” versus “à surveiller plus tard”.

Thought for 16s
Résumé exécutif

La santé technologique de Potion Man est globalement bonne : le trio Godot + GDScript (.gd) + SQLite local est cohérent avec un jeu 3D solo au style PSX, et tes documents montrent déjà une séparation utile entre services métier, accès aux données et sauvegarde.
Le principal risque immédiat n’est pas un “mauvais choix de techno”, mais plutôt un manque de verrouillage opérationnel : version exacte de Godot non figée dans la doc, binding SQLite non identifié, et responsabilité encore ambiguë entre DB de contenu et save joueur.
Côté dépendances, Godot est maintenu, mais seules les branches et patchs supportés doivent être utilisés ; Godot 4.6 est supporté et 4.6.2 est la stable courante au 1 avril 2026.
SQLite est lui aussi activement maintenu et publie ses CVEs officiellement ; cela ne crée pas une urgence critique pour un jeu local solo, mais justifie de connaître précisément la version embarquée et le wrapper utilisé.
En pratique, je recommande de traiter en priorité la mise à niveau/validation des dépendances, la clarification de l’architecture de persistance, puis l’amélioration de la maintenabilité du code GDScript.
Note de santé technologique : 7.8 / 10.
| Action                                                                                  | Pourquoi                                                                                                                                                                                                                             |    Impact | Priorité |
| --------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------: | -------- |
| **1. Figer la version exacte de Godot dans le projet**                                  | Les docs du projet disent “Godot”, mais pas la version. Or seules les branches/patchels supportés reçoivent correctifs et support actif. Godot 4.6 est supporté, et 4.6.2 est la stable actuelle.  ([Godot Engine documentation][1]) | Très fort | HAUTE    |
| **2. Identifier le binding SQLite exact**                                               | Tu as confirmé SQLite local, mais pas la librairie/plugin Godot qui le connecte. Sans ça, on ne peut pas auditer correctement maintenance, compatibilité, ni exposition aux CVEs du moteur SQLite embarqué.                          | Très fort | HAUTE    |
| **3. Vérifier que la version SQLite embarquée est à jour**                              | SQLite publie des CVEs officielles ; le risque réel dépend de la version embarquée dans ton wrapper, pas juste du fait “d’utiliser SQLite”. ([sqlite.org][2])                                                                        |      Fort | HAUTE    |
| **4. Bannir définitivement l’option DB distante/MySQL pour la version actuelle du jeu** | Tes docs montrent que la PoC a exploré MySQL externe, mais que SQLite local est le bon choix pour ce jeu. Garder les deux pistes vivantes créerait dette, complexité et surface de panne inutile.                                    |      Fort | HAUTE    |
| **5. Clarifier la séparation “contenu” vs “sauvegarde joueur”**                         | La fiche fonctionnelle mentionne à la fois SQLite, JSON/ConfigFile, et même “save/load dans la db”. Il faut une seule responsabilité par mécanisme pour éviter incohérences et corruption logique.                                   | Très fort | HAUTE    |
| **6. Tester la compatibilité du projet après mise à jour mineure Godot**                | Godot recommande de rester sur le dernier patch de la branche supportée ; il faut donc valider imports, UI, collisions, navigation et scripts après upgrade. ([Godot Engine documentation][1])                                       |      Fort | HAUTE    |

[1]: https://docs.godotengine.org/en/4.6/about/release_policy.html?utm_source=chatgpt.com "Godot release policy"
[2]: https://www.sqlite.org/cves.html?utm_source=chatgpt.com "Vulnerabilities"

Ordre conseillé d’exécution immédiat :

connaître ta version Godot réelle,
connaître ton plugin SQLite réel,
vérifier leur état support/CVE,
fixer l’architecture de persistance,
seulement ensuite faire les optimisations de code.
Priorité MOYENNE

Concerne la maintenance et la robustesse post-projet.
| Action                                                                | Pourquoi                                                                                                                                                                                                 |       Impact | Priorité |
| --------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -----------: | -------- |
| **7. Passer les scripts critiques en GDScript typé**                  | Ton projet repose sur `.gd`, et les couches inventaire/craft/save bénéficient fortement d’un typage plus strict pour réduire les bugs de runtime.                                                        |         Fort | MOYENNE  |
| **8. Réduire le couplage aux autoloads**                              | `DBService.gd` et `InventoryService.gd` en autoload sont raisonnables, mais trop de global state fragilise l’ordre d’initialisation et les tests.                                                        | Moyen à fort | MOYENNE  |
| **9. Faire respecter la chaîne Scene/UI → Service → Repository → DB** | La base ne doit pas “remonter” dans le gameplay. La séparation déjà esquissée dans tes docs est bonne, il faut la rendre stricte.                                                                        |         Fort | MOYENNE  |
| **10. Documenter les dépendances réelles dans le repo**               | Ajoute une section technique claire : version Godot, plugin SQLite, format save, conventions de dossiers, autoloads, assets critiques. Aujourd’hui cela est partiellement réparti dans plusieurs fiches. |        Moyen | MOYENNE  |
| **11. Définir un plan de sauvegarde robuste**                         | Décider quand sauver, quoi sauver, et sous quel format. La doc actuelle laisse plusieurs options ouvertes, ce qui nuit à la maintenabilité.                                                              |         Fort | MOYENNE  |
| **12. Encadrer les assets tiers et shaders PSX**                      | Les assets PSX et shaders sont au cœur de l’identité visuelle, mais ce sont souvent les premiers éléments à casser après upgrade moteur ou changement de pipeline d’import.                              |        Moyen | MOYENNE  |
Amélioration structurelle la plus rentable :
faire de SQLite la base de contenu et de JSON/ConfigFile la sauvegarde joueur, puis faire converger tout le code sur cette règle.

Priorité BASSE

Concerne la surveillance long terme.
| Élément à surveiller                                                           | Pourquoi                                                                                                                                         | Priorité |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ | -------: |
| **Cycle de support Godot**                                                     | Les branches deviennent EOL ; il faut éviter de rester trop longtemps sur une version non supportée. ([Godot Engine documentation][1])           |    BASSE |
| **Évolution des CVEs SQLite**                                                  | Pas critique au quotidien pour un jeu solo local, mais utile si tu conserves longtemps le projet ou publies une build durable. ([sqlite.org][2]) |    BASSE |
| **Compatibilité des plugins tiers**                                            | Le vrai point faible de long terme n’est souvent pas Godot lui-même, mais un plugin peu maintenu.                                                |    BASSE |
| **Possibilité de remplacer SQLite par des Resources pour le contenu statique** | Si ton volume de données reste faible, les `Resources` Godot pourraient simplifier le pipeline plus tard. Pour l’instant, pas prioritaire.       |    BASSE |
| **Migration vers une autre techno moteur**                                     | Unity, Bevy ou autre n’apporteraient pas de gain net à ce stade ; coût de migration trop élevé pour le bénéfice attendu.                         |    BASSE |

[1]: https://docs.godotengine.org/en/4.6/about/release_policy.html?utm_source=chatgpt.com "Godot release policy"
[2]: https://www.sqlite.org/cves.html?utm_source=chatgpt.com "Vulnerabilities"
Recommandations concrètes par phase
Cette semaine
noter la version exacte de Godot utilisée dans le repo et le document technique ;
noter le nom exact du plugin/wrapper SQLite ;
décider noir sur blanc : SQLite = contenu, JSON/ConfigFile = save joueur.
Ensuite
revoir DBService.gd, InventoryService.gd, CraftService.gd, SaveService.gd pour vérifier qu’aucune scène UI ne parle directement à la DB ;
typer les classes et retours les plus sensibles ;
tester la build sur la dernière maintenance release compatible.
Plus tard
surveiller l’état support de la branche Godot ;
surveiller les mises à jour du wrapper SQLite ;
évaluer si certaines données de contenu gagneraient à passer en Resource Godot.
Note finale

Santé technologique : 7.8 / 10

Pourquoi pas plus haut
versions et dépendances réelles pas encore totalement inventoriées ;
architecture de persistance encore ambiguë dans la documentation ;
risque de couplage si les services globaux prennent trop de place.
Pourquoi la note reste bonne
la stack choisie est cohérente avec le scope ;
Godot et SQLite sont vivants et maintenus ;
la structure service/repository est déjà une bonne base ;
le recentrage vers SQLite local est une bonne décision d’architecture.
```
Annotation :
- ✅ Utilisation de Godot 4 and up donc aucun problème avec ça. SQLite, utilisation local et aucun CVE urgent.