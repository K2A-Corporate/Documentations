# 🛠️ GUIDE D’INSTALLATION ET D’INITIATION
## SYSTÈME : Master_ScalpSwinger (K2A-ts)

Ce guide vous accompagne pas à pas pour configurer votre infrastructure de trading avec l'expertise **K2A Corporate**.

---

### 📥 1. INSTALLATION DU BOT (2 MÉTHODES)

Selon votre aisance technique, choisissez l'une des deux approches suivantes :

#### 🔹 Approche A : Lancement direct (Mode "Application")
1. Laissez votre terminal **MetaTrader 5** ouvert.
2. Localisez le fichier `Master_ScalpSwinger.ex5` sur votre ordinateur.
3. Faites un **double-clic** sur le fichier.
4. Le bot s'installe instantanément dans votre terminal et la fenêtre des réglages apparaît.

#### 🔹 Approche B : Installation manuelle (Dossier Source)
1. Sur MT5, cliquez sur le menu **Fichier** > **Ouvrir le dossier des données**.
2. Allez dans le dossier `MQL5`, puis dans le sous-dossier `Experts`.
3. **Copiez-collez** votre fichier `Master_ScalpSwinger.ex5` à cet endroit.
4. Dans le navigateur de MT5 (à gauche), faites un clic droit sur "Conseillers Experts" et choisissez **Rafraîchir**.

---

### 📈 2. ATTACHEMENT AU GRAPHIQUE

1. Ouvrez le graphique de l'actif souhaité (ex: *Crash 1000* ou *EURUSD*).
2. Faites glisser le bot depuis le navigateur vers le graphique.
3. **Configuration cruciale :** Dans l'onglet **"Commun"**, cochez impérativement la case **"Autoriser le trading algorithmique"**.
4. Vérifiez que le bouton **Algo Trading** (en haut de MT5) est passé au **Vert**.

---

### ⚙️ 3. CONFIGURATION DES PARAMÈTRES (INPUTS)

Voici la nomenclature complète des réglages de votre technologie.

| Paramètre technique (Code) | Explication et Rôle du réglage |
| :--- | :--- |
| `ENUM_TRADING_DIRECTION` | **Direction autorisée** : <br> Both (0) / Buy (1) / Sell (-1). |
| `_______________General____________________` | **Section Générale** : Paramètres d'identité du Bot. |
| `input bool EATrader = true;` | **Activation** : Autorise ou non le bot à passer des ordres. |
| `input ENUM_TRADING_DIRECTION buyOrSell = TRADE_BOTH;` | **Flux** : Choix entre Achat, Vente ou les deux. |
| `input int MagicNumber = 1010;` | **Identifiant unique** : Empêche le conflit avec vos autres trades. |
| `input bool Display_Information = true;` | **Interface visuelle** : Affiche les stats sur le graphique. |
| `input bool Send_Alert = false;` | **Alerte sonore** : Bip sur l'ordinateur lors d'un signal. |
| `input bool Send_Notification = false;` | **Notification Mobile** : Alerte Push sur smartphone. |
| `_______________Trend_Parameters___________` | **Section Tendance** : Détection du marché. |
| `input ENUM_TIMEFRAMES Open_Positions_TIMEFRAMES = PERIOD_M15;` | **Unité de temps** : Période d'analyse (ex: M15). |
| `input bool UseRSI;` | **Filtre RSI** : Utilise l'indicateur RSI pour filtrer les signaux. |
| `_______________Risks_Management___________` | **Section Risques** : Contrôle du capital. |
| `input double percentage_of_capital = 1.0;` | **Risque (%)** : Pourcentage du capital risqué par trade. |
| `input double riskAmountUSD = 0.0;` | **Risque ($)** : Montant fixe en dollars risqué par trade. |
| `input double lotSize = 0.0;` | **Lot Fixe** : Volume forcé (ex: 0.20) sans calcul auto. |
| `input double MaxlotSize = 100.0;` | **Limite de lot** : Volume maximum autorisé par le bot. |
| `input int MaxPositionsPerSymbol = 1;` | **Positions max** : Limite de trades ouverts simultanément. |
| `input bool Use_SL = true;` | **Stop Loss** : Active la protection contre la perte. |
| `input double SL_Factor = 2.0;` | **Facteur SL** : Ajuste la distance de sécurité du Stop Loss. |
| `_______________Take_Profit________________` | **Section Objectifs** : Gestion des gains. |
| `input bool Use_TP;` | **Take Profit** : Active la clôture automatique en profit. |
| `input double TP_Factor = 2.0;` | **Ratio Gain** : Multiplicateur du risque pour fixer l'objectif. |
| `input bool CloseByMomentum = true;` | **Sortie Dynamique** : Ferme le trade si le marché s'essouffle. |
| `_______________Fibonacci_Module___________` | **Section Fibonacci** : Précision mathématique. |
| `input bool Use_Fibo_Logic = false;` | **Mode Fibo** : Active la stratégie par retracements. |
| `input double Fibo_Level_0 = 0.0;` | Point bas de référence pour l'outil Fibonacci. |
| `input double Fibo_Level_100 = 0.0;` | Point haut de référence pour l'outil Fibonacci. |
| `input ENUM_FIBO_TARGET Fibo_Target_Entry = LEVEL_70;` | Niveau de retracement attendu pour l'entrée. |
| `input ENUM_FIBO_TP Fibo_Target_TP = TP_MINUS_25;` | Niveau visé pour la sortie en profit. |
| `input bool send_Fibo_Notification = true;` | Notification spécifique pour les signaux Fibo. |
| `input bool draw_Fibo_Lines = true;` | Affiche les lignes Fibonacci sur l'écran. |

---

### ⚠️ RAPPEL DE SÉCURITÉ

Assurez-vous d'avoir correctement ajouté les URLs de contrôle dans votre terminal (Menu **Outils** > **Options** > **Conseillers Experts**) :
* `https://raw.githubusercontent.com`
* `https://api.telegram.org`

> **Note :** Sans ces liens, le bot restera inactif pour protéger votre licence.

---
👉 **[Lire les Conditions Générales d'Utilisation (CGU)](CGU.md)**
