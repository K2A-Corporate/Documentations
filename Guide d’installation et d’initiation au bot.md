# 🛠️ GUIDE D’INSTALLATION ET D’INITIATION
## SYSTÈME : Master_ScalpSwinger (K2Asts)

Ce guide vous accompagne pas à pas pour configurer votre infrastructure de trading avec l'expertise **K2A Corporate**.

---

### 📥 1. INSTALLATION DU BOT (2 MÉTHODES)

Selon votre aisance technique, choisissez l'une des deux approches suivantes :

#### 🔹 Approche A : Lancement direct (Mode "Application")
1. Laissez votre terminal **MetaTrader 5** ouvert.
2. Localisez le fichier `Master_ScalpSwinger.ex5` sur votre ordinateur.
3. Faites un **double-clic** sur le fichier.
4. Le bot s'installe instantanément dans votre terminal et apparait sous "Expert Consultant".

#### 🔹 Approche B : Installation manuelle (Dossier Source)
1. Sur MT5, cliquez sur le menu **Fichier** > **Ouvrir le dossier des données**.
2. Allez dans le dossier `MQL5`, puis dans le sous-dossier `Experts`.
3. **Copiez-collez** votre fichier `Master_ScalpSwinger.ex5` à cet endroit.
4. Dans le navigateur de MT5 (à gauche), faites un clic droit sur "Expert Consultant" et choisissez **Actualiser**.

---

### 📈 2. ATTACHEMENT AU GRAPHIQUE

1. Ouvrez le graphique de l'actif souhaité (ex: *Volatility Index 50* ou *EURUSD*).
2. Faites glisser le bot depuis le navigateur vers le graphique.
3. **Configuration cruciale :** Dans l'onglet **"Général"**, cochez impérativement la case **"Autoriser le trading algorithmique"**.
4. Vérifiez que le bouton **Trading Algo** (en haut de l'application MT5) est passé au **Vert**.

>Pour une prise en main rapide de la plateforme de trading MT5, cliquez sur [**Tutoriel 1**](https://youtu.be/RWrHimN3Ius?si=pjHs5w8rVnwFhVpB) ou [**Tutoriel 2**](https://youtu.be/7ynRo1it2lM?si=ilMEXJGSWtXmqtPq).

---

### ⚙️ 3. CONFIGURATION DES PARAMÈTRES (INPUTS)

Voici la nomenclature complète des réglages de votre technologie.

| Paramètre technique (Code) | Explication et Rôle du réglage |
| :--- | :--- |
| `_______________General____________________` |  |
| `EATrader = true` | **Activation** : Autorise ou non le bot à passer des ordres. <br> C'est votre interrupteur. Si vous mettez "false" le bot fonctionne comme un indicateur : Il envoie uniquement des signaux avec un affichage visuel du point d'entrée, du TP et du SL. Vous devez ensuite ouvrir manuellement les positions. <br> NB : Un trade positif laisse une ligne pointillée bleue, un trade négatif laisse une ligne pointillée rouge. |
| `buyOrSell = TRADE_BOTH` | **Flux** : Choix entre Achat (TRADE_BUY_ONLY), <br> Vente (TRADE_SELL_ONLY) ou les deux (TRADE_BOTH). Ce paramètre est intéressant si vous arrivez à identifier une tendance claire. |
| `MagicNumber = 1010` | **Identifiant unique** : Empêche le conflit avec vos autres trades. Veillez à ne pas utiliser le même numéro sur deux graphiques différents. |
| `Display_Information = true` | **Interface visuelle** : Affiche les stats sur le graphique. |
| `Send_Alert = false` | **Alerte sonore** : Bip sur l'ordinateur lors d'un signal. |
| `Send_Notification = false` | **Notification Mobile** : Alerte Push sur smartphone. Ne pas oublier de faire la liaison. |
| `_______________Trend_Parameters___________` |  |
| `Open_Positions_TIMEFRAMES = PERIOD_M15` | **Unité de temps** : Période d'analyse utilisée par le robot pour la détection des signaux et la prise de décisions. |
| `UseRSI;` | **Filtre RSI** : Utilise l'indicateur RSI pour filtrer les signaux. |
| `_______________Risks_Management___________` |  |
| `percentage_of_capital = 1.0` | **Risque (%)** : Pourcentage du capital risqué par trade. |
| `riskAmountUSD = 0.0` | **Risque ($)** : Montant fixe en dollars risqué par trade. <br> Ce montant n'est pas pris en compte si le pourcentage du capital risqué est différent de 0. |
| `lotSize = 0.0` | **Lot Fixe** : Volume forcé si différent de 0. Sinon calcul automatique par le robot. |
| `MaxlotSize = 100.0` | **Limite de lot** : Volume maximum autorisé par le bot. |
| `MaxPositionsPerSymbol = 1` | **Positions max** : Limite de trades ouverts simultanément sur le même actif. |
| `Use_SL = true` | **Stop Loss** : Interrupteur pour Activer/Désactiver la protection contre la perte. |
| `SL_Factor = 2.0` | **Facteur SL** : Ajuste la distance de sécurité du Stop Loss. |
| `_______________Take_Profit________________` |  |
| `Use_TP` | **Take Profit** : Active la clôture automatique en profit. |
| `TP_Factor = 2.0` | **Ratio Gain** : Multiplicateur du risque pour fixer l'objectif. <br> Si vous souhaitez que le bot définisse un niveau d'objectif optimal suivant la structure du marché, mettez cette valeur = 0. |
| `CloseByMomentum = true` | **Sortie Dynamique** : Ferme le trade si le marché s'essouffle. |
| `_______________Fibonacci_Module___________` |  |
| `Use_Fibo_Logic = false` | **Mode Fibo** : Active la stratégie par retracements. Outil supplémentaire puissant. |
| `Fibo_Level_0 = 0.0` | Point bas de référence pour l'outil Fibonacci. |
| `Fibo_Level_100 = 0.0` | Point haut de référence pour l'outil Fibonacci. |
| `Fibo_Target_Entry = LEVEL_70` | Niveau de retracement attendu pour l'entrée. |
| `Fibo_Target_TP = TP_MINUS_25` | Niveau visé pour la sortie en profit. |
| `send_Fibo_Notification = true` | Notification spécifique pour les signaux Fibo. |
| `draw_Fibo_Lines = true` | Affiche les lignes Fibonacci sur l'écran. |

> Le robot est conçu pour déplacer automatiquement le stop loss (Traling Stop). Ce paramètre n'est pas laisser au choix de l'utilisateur afin de garantir la rentabilité.

---

### ⚠️ RAPPEL DE SÉCURITÉ

Assurez-vous d'avoir correctement ajouté les URLs de contrôle dans votre terminal (Menu **Outils** > **Options** > **Expert Consultant**) :
* `https://raw.githubusercontent.com`
* `https://api.telegram.org`

> **Note :** Sans ces liens, le bot restera inactif pour protéger votre licence.

---
👉 **[Lire les Conditions Générales d'Utilisation (CGU)](Conditions%20Générales%20d'Utilisation)**
