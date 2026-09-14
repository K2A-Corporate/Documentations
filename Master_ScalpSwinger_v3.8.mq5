//+------------------------------------------------------------------+
//|                                          K2A MASTER_SCALPSWINGER |
//|                                    Copyright 2026, K2A Corporate |
//|                            https://t.me/K2ACorporateOfficiel_bot |
//+------------------------------------------------------------------+
#property copyright "Copyright 2026, K2A Corporate"
#property link      "https://t.me/K2ACorporateOfficiel_bot"
#property version   "3.8"
#property strict

#resource "\\Indicators\\K2A Oscillator.ex5"
#resource "\\Indicators\\K2A Momentum.ex5"
#resource "\\Indicators\\Ln_K2A1000.ex5"

#include <for_Master_ScalpSwinger_v3.8\3.8_LicenseManager.mqh>
#include <for_Master_ScalpSwinger_v3.8\3.8.1_SignalManager.mqh>
#include <for_Master_ScalpSwinger_v3.8\3.8_TradeManager.mqh>
#include <for_Master_ScalpSwinger_v3.8\3.8_TrailingStopManager.mqh>
#include <for_Master_ScalpSwinger_v3.8\3.8_Outils.mqh>
//#include <for_Master_ScalpSwinger_v3.8\3.8_FiboManager_2.mqh>
#include <for_Master_ScalpSwinger_v3.8\3.8_K2A_Reporting.mqh>
#include <for_Master_ScalpSwinger_v3.8\3.8_Telecommande.mqh>
#include <for_Master_ScalpSwinger_v3.8\3.8_K2A_SniperAlert.mqh>

#include <Trade\Trade.mqh>

CTrade m_trade;
CTradeManager Executor;

enum ENUM_TRADING_DIRECTION { TRADE_BOTH = 0, TRADE_BUY_ONLY = 1, TRADE_SELL_ONLY = -1 };


////////////////////////////////////////////////////////////////////////
//--- INPUTS ---////////////////////////////////////////////////////////
input group "I🔹 PARAMÈTRE GÉNÉRAL"
input bool EATrader = true;
input ENUM_TRADING_DIRECTION buyOrSell = TRADE_BOTH;
input int MagicNumber  = 100001; // Identifiant unique pour ce graphique
input bool Display_Information;
input bool Send_Notification = true;
input bool Send_Alert = true;

input group ""
input group "II🔹 PARAMÈTRES DE TENDANCE"
input bool Multi_TimeFrames_Analysis = true;
input bool Use_Daily_Signal;
input ENUM_TIMEFRAMES Analysis_Trend_TIMEFRAMES = PERIOD_H1;
input ENUM_TIMEFRAMES Open_Positions_TIMEFRAMES = PERIOD_M3;
input int sniper_period = 12;
input int Max_Signals_Per_Trend = 1; // Nombre max de signaux par tendance (0 = Illimité)

input group ""
input group "III🔹 MANAGEMENT DU RISQUE"
input double percentage_of_capital = 1;
input double riskAmountUSD = 0.0;
input double lotSize = 0.0;
input double MaxlotSize = 20.0;
input int MaxPositionsPerSymbol = 1;
input int Simultaneous_Positions = 1;
input bool Use_SL = true;
input double SL_Factor = 2.50; // SL_Facteur (par défaut = 1.50, Max 3.00)
input bool Open_Market_order = true;
input bool Open_Limit_order = true;

input group ""
input group "IV🔹 MANAGEMENT DU PROFIT"
input bool Use_TP = true;
input double TP_Factor = 2.0;
input bool Use_TrailingStop = true;
input ENUM_TIMEFRAMES TrailingStop_TIMEFRAMES = PERIOD_M20;
input double Coef_Securite = 1.0;
input bool Use_Stop_Secure = true;
input double Candle_Coef = 1.0;
input double taux_d_encaissement = 0.0;
input bool CloseByMomentum;
input bool CloseBySniper;

input group ""
input group "V🔹 MODULE FIBONACCI"
input bool En_Developpement_A = true;

input group ""
input group "VI🔹 ALERTE DE TENDANCE SNIPER"
input ENUM_TIMEFRAMES Favorite_TF = PERIOD_M5; // Timeframes Préféré
input string telegram_ID = "";
input int Periodicite = 3600; // Période (En secondes)

input group ""
input group "VII🔹 ALERTES DE PRIX"
input bool En_Developpement_B = true;

input group ""
input group "VIII🔹 PARAMÈTRES DE SÉCURITÉ"
input bool     WorkTimeLimit      = false;
input datetime WorkTimeLimit_date = D'2026.12.31 23:59';

input group ""
input group "IX🔹 CONTRÔLE DU BOT À DISTANCE"
input string url_de_controle = "";


//--- GLOBALS ---
int Trend_K2Aox_Handle, Trend_K2Am_Handle, Open_K2Am_Handle, Open_K2Aox_Handle, TS_K2Am_Handle, K2A_Line, Ma_Handle;
datetime lastBarTime;
datetime last_update_License = 0; // 1ère variable qui Stocke l'heure de la dernière mise à jour des données d'affichage
datetime last_update_Ctrl = 0; // 2ème variable qui Stocke l'heure de la dernière mise à jour des données d'affichage


////////////////////////////////////////////////////////////////////////
//--- INIT ---//////////////////////////////////////////////////////////
int OnInit(){
   // --- TEST D'INTÉGRITÉ DU NOM ---
   if(!VerifierIntegriteNom()) {
      Alert("Violation d'intégrité du bot : Seul le propriétaire est autorisé à modifier le nom du bot");
      ExpertRemove(); // On retire le bot du graphique
      return(INIT_FAILED); // On stoppe l'initialisation
   }
   else{
      IdentifierClient(AccountInfoInteger(ACCOUNT_LOGIN));
      // 1. On enregistre ce graphique dans les variables globales
      RegisterChartInstance();
      // 2. On déclenche un timer de 2 secondes pour laisser le temps aux autres graphiques de s'enregistrer
      EventSetTimer(2);
   }
   
   // Nombre magic
   // Configuration de l'identifiant du robot pour le suivi des ordres
   Executor.SetMagic(MagicNumber);   

   // Vérification de la licence
   if(!CheckRemoteLicense()) return(INIT_FAILED);
   if(Date_Expiration_Stockee > 0) Print("✅ Félicitations ", K2A_matricule, ". Licence valide jusqu'au : ", TimeToString(Date_Expiration_Stockee, TIME_DATE), 
                                                                                                            " pour votre compte ", type_Label, " N° ",NumCompte);
   Sniper = new CK2ATrendSniper(sniper_period);

   // Définition des indicateurs
   Open_K2Am_Handle = iCustom(_Symbol, Open_Positions_TIMEFRAMES, "::Indicators\\K2A Momentum.ex5", 14, 21, 35, PRICE_CLOSE);
   Open_K2Aox_Handle = iCustom(_Symbol, Open_Positions_TIMEFRAMES, "::Indicators\\K2A Oscillator.ex5", 12, 35, 75, PRICE_CLOSE);
   //Trend_K2Am_Handle = iCustom(_Symbol, Analysis_Trend_TIMEFRAMES, "::Indicators\\K2A Momentum.ex5", 14, 21, 35, PRICE_CLOSE);
   Trend_K2Aox_Handle = iCustom(_Symbol, Analysis_Trend_TIMEFRAMES, "::Indicators\\K2A Oscillator.ex5", 14, 21, 35, PRICE_CLOSE);
   TS_K2Am_Handle = iCustom(_Symbol, TrailingStop_TIMEFRAMES, "::Indicators\\K2A Momentum.ex5", 14, 21, 35, PRICE_CLOSE);
   K2A_Line = iCustom(_Symbol, TrailingStop_TIMEFRAMES, "::Indicators\\Ln_K2A1000.ex5");

   // Affichage des informations
   UpdateUI();
   
   // On active le timer pour qu'il s'exécute toutes les 60 secondes
   EventSetTimer(60); 

   // Optionnel : Test de connexion ici pour vérifier au lancement
   //TestConnexionTelegram();

   return(INIT_SUCCEEDED);
}


////////////////////////////////////////////////////////////////////////
//--- TICK ---//////////////////////////////////////////////////////////
void OnTick(){
   datetime temps_actuel = TimeCurrent();
   
   // Vérification de la Licence en temps réel
   if(temps_actuel - last_update_License >= 3600) {
      if(!CheckRemoteLicense()) {
         Comment("!!! LICENCE EXPIRÉE !!!");
         ExpertRemove();
         return;
      }
      last_update_License = temps_actuel;
   }

   // Vérification de la limite de temps à chaque tick
   if(WorkTimeLimit && TimeCurrent() >= WorkTimeLimit_date) {
      return;
   }

   // SÉCURITÉ PORTEFEUILLE : On vérifie d'abord si on doit encaisser le % du taux d'encaissement
   if(taux_d_encaissement > 0) CheckGlobalTargetAndClose();
   
   // SÉCURITÉ : Controle à distance
   if(temps_actuel - last_update_Ctrl >= 60) {
      CheckRemoteControl(url_de_controle); // Controle à distance
      if(bot_ACTIVE) VerifierEtEnvoyerAlert(telegram_ID, Periodicite, Favorite_TF, _Symbol);
      last_update_Ctrl = temps_actuel;
      UpdateUI();
   }
   
// AFFICHAGE DU COMPTE A REBOUR
   DrawCountdown();
   
// DEBUT DU CERVEAU !!!!!!!!!!!!!!
   datetime ActuelBarTime = iTime(_Symbol, Open_Positions_TIMEFRAMES, 1);
   if(ActuelBarTime == lastBarTime) return;
   lastBarTime = ActuelBarTime;

   // Mise à jour permanente des tracés historiques si EATrader = false
   UpdateVisualTracking();
   
   int totalActive = 0;

   // Si EATrader est false, on utilise l'état de l'indicateur visuel comme "position virtuelle"
   if(!EATrader && currentVisual.active) totalActive = 1;
//------------------------------------
   
   // Variables qui recevront les prix calculés par SignalManager
   double Swing_Candle_Range = 0, Limit_price1 = 0, Limit_price2 = 0, Limit_price3 = 0, SL_Price = 0;
   
   // Appel à SignalManager.mqh classique...
   // Activation et récupération du signal du Open_Positions_TIMEFRAMES
   int tSignal = GetSignalForOpen(
                       Multi_TimeFrames_Analysis, 
                       Trend_K2Aox_Handle, 
                       Open_K2Am_Handle,
                       buyOrSell, 
                       Analysis_Trend_TIMEFRAMES, 
                       Open_Positions_TIMEFRAMES, 
                       Use_Daily_Signal,
                       MaxPositionsPerSymbol, 
                       Send_Alert, Send_Notification, 
                       EATrader, Swing_Candle_Range,
                       Limit_price1, Limit_price2, Limit_price3, SL_Price,
                       SL_Factor, Max_Signals_Per_Trend
                 );

   // Gestion des signaux confirmés
   if(tSignal != 0 && totalActive < MaxPositionsPerSymbol) {
      double entry = (tSignal == 1) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double sl_dist = SL_Factor * MathAbs(entry - SL_Price);
      double sl = (tSignal == 1) ? entry - sl_dist : entry + sl_dist;
      double tp = (tSignal == 1) ? entry + (TP_Factor * sl_dist) : entry - (TP_Factor * sl_dist);
      
      //-----------------------------
      bool YES_Can_Trade = (!Multi_TimeFrames_Analysis) ? (bot_ACTIVE && EATrader) :
                           (bot_ACTIVE && EATrader && tSignal == Global_Sniper_Signal);
      //-----------------------------
      
      if(YES_Can_Trade) {
         Executor.Execute(
               tSignal, SL_Price, 
               MaxPositionsPerSymbol, 
               percentage_of_capital, riskAmountUSD, 
               lotSize, MaxlotSize,
               Use_SL, SL_Factor, Use_TP, TP_Factor, 
               AccountInfoDouble(ACCOUNT_BALANCE), 
               Limit_price1, Limit_price2, Limit_price3, 
               Simultaneous_Positions,
               Open_Market_order, Open_Limit_order
         );
      }

      if(!bot_ACTIVE || !EATrader) {
         // --- DESSIN VISUEL (Quoi qu'il arrive) ---
         DrawVisualSignal(tSignal, entry, sl, tp);
      }
   }
   
   // Appel au Traling Stop
   Manage_Technical_Trailing(
         TS_K2Am_Handle, 
         K2A_Line, 
         TrailingStop_TIMEFRAMES, 
         Analysis_Trend_TIMEFRAMES, 
         Open_Positions_TIMEFRAMES, 
         Open_K2Aox_Handle,
         Use_TrailingStop,
         Coef_Securite,
         Use_Stop_Secure, 
         Candle_Coef,
         CloseByMomentum, 
         CloseBySniper
   );
}


//--- FONCTION D'AFFICHAGE ---
// +------------------------------------------------------------------+
// | AFFICHE L'ALERTE ROUGE EN HAUT À DROITE SI URGENCE               |
// +------------------------------------------------------------------+
void AfficherAlerteRouge(string texte) {
   string nomObj = "AlerteExpiration";
   if(ObjectFind(0, nomObj) < 0) {
      ObjectCreate(0, nomObj, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, nomObj, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
      ObjectSetInteger(0, nomObj, OBJPROP_XDISTANCE, 300);
      ObjectSetInteger(0, nomObj, OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, nomObj, OBJPROP_FONTSIZE, 12);
      ObjectSetString(0, nomObj, OBJPROP_FONT, "Arial Bold");
      ObjectSetInteger(0, nomObj, OBJPROP_COLOR, clrRed);
      ObjectSetInteger(0, nomObj, OBJPROP_BACK, false); // Force le texte devant le graphique
      ObjectSetInteger(0, nomObj, OBJPROP_SELECTABLE, false); // Évite de déplacer le texte par erreur
      ObjectSetInteger(0, nomObj, OBJPROP_HIDDEN, false); // S'assure qu'il n'est pas caché dans la liste
   }
   ObjectSetString(0, nomObj, OBJPROP_TEXT, texte);
}

// +------------------------------------------------------------------+
// | MISE À JOUR DE L'INTERFACE GRAPHIQUE                             |
// +------------------------------------------------------------------+
void UpdateUI() {
   // Si l'utilisateur a désactivé l'affichage dans les paramètres
   if(!Display_Information) { Comment(""); ObjectDelete(0, "AlerteExpiration"); return; }

   string typeCompte = (AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_REAL) ? "RÉEL" : "DÉMO";
   string tendance, ModeOperatoire;
   
   /*if(Multi_TimeFrames_Analysis){
      if(global_trend == 1) {
         tendance = "HAUSSE";
         ModeOperatoire = "ACHETER ▲";
      }   
      else if(global_trend == -1) {
         tendance = "BAISSE";
         ModeOperatoire = "VENDRE ▼";
      }   
      else {
         tendance = "Neutre";
         ModeOperatoire = "REPOS !!!";
      }
   }
   else {
      if(Signal_2 == 1){
         tendance = "HAUSSE";
         ModeOperatoire = "ACHETER ▲";
      }   
      else if(Signal_2 == -1) {
         tendance = "BAISSE";
         ModeOperatoire = "VENDRE ▼";
      }   
      else {
         tendance = "Neutre";
         ModeOperatoire = "REPOS !!!";
      }
   }*/
   
   string message = "==> MASTER_SCALPSWINGER (-K2A Corporate-) <==\n\n";
   message += "================================\n";
   message += "CLIENT : " + Mon_Matricule + " (" + Mon_Nom + ")\n";
   message += "================================\n";

   // --- GESTION DE LA LICENCE ---
   if(Est_Une_Licence_Illimitee) {
      message += "LICENCE : ✅ Illimitée (" + typeCompte + ")\n";
      ObjectDelete(0, "AlerteExpiration");
   } 
   else if(Date_Expiration_Stockee > 0) {
      long secondes_restantes = (long)Date_Expiration_Stockee - (long)TimeCurrent();
      int jours = (int)(secondes_restantes / 86400);
      
      message += "LICENCE : Active (" + IntegerToString(jours) + " jours restants)\n";

      // ALERTE ROUGE : Si moins de 48 heures (172800 secondes)
      if(secondes_restantes > 0 && secondes_restantes < 172800) {
         int heures = (int)(secondes_restantes / 3600);
         int minutes = (int)((secondes_restantes % 3600) / 60);
         AfficherAlerteRouge("⚠⚠⚠ : Licence expire dans " + IntegerToString(heures) + "h " + IntegerToString(minutes) + "min");
      } else {
         ObjectDelete(0, "AlerteExpiration");
      }
   } else {
      message += "LICENCE : Vérification en cours...\n";
   }

   message += "--------------------------------\n";
   message += "Centre d'aide : https://t.me/K2ACorporateOfficiel_bot\n";

   if(!bot_ACTIVE) {
      message += "\n";
      message += "================================\n";
      message += "📢 BLOCAGE A DISTANCE (Statut: OFF)\n";
      message += "================================\n";
      Comment("\n"+message);
      return;
   }

   message += "--------------------------------\n";
   message += "Temps d'Ouverture Positions : " + EnumToString(Open_Positions_TIMEFRAMES) + "\n";
   message += "--------------------------------\n";
   message += "Temps du Graphique : " + EnumToString(_Period) + "\n";
   message += ">>>>>>>>\n";
   
   if(Multi_TimeFrames_Analysis){
      message += "TENDANCE ACTUELLE en " + EnumToString(Analysis_Trend_TIMEFRAMES) + " : " + tendance + "\n";
   }
   else{
      message += "TENDANCE ACTUELLE en " + EnumToString(Get_Filter_TF(Open_Positions_TIMEFRAMES)) + " : " + tendance + "\n";
   }
   
   message += ">>>>>\n";
   message += "RECOMMANDATION = " + ModeOperatoire + "\n";
   message += ">>>>>>>>";
   
   Comment("\n"+message);
}


void OnTimer() {
   // 1. Identification du client (Matricule + Nom)
   if(Mon_Matricule == "Inconnu") {
      IdentifierClient(AccountInfoInteger(ACCOUNT_LOGIN));
   }

   if(Mon_Matricule != "Inconnu") {
      // Après 2 secondes, le premier graphique qui s'exécute envoie le rapport récapitulatif complet
      EnvoyerNotificationConnexion(Mon_Matricule);
      // On coupe le timer une fois la vérification effectuée
      EventKillTimer();
   }

   // 2. Vérification du rapport de performance
   if(Mon_Matricule != "Inconnu") {
      VerifierEtEnvoyerRapport(Mon_Matricule); 
   }
}

//+------------------------------------------------------------------+
//| Affiche le compte à rebours dynamique en bas à droite            |
//+------------------------------------------------------------------+
void DrawCountdown() {
   // 1. Calcul du compte à rebours
   datetime bar_start = iTime(_Symbol, _Period, 0);
   datetime next_bar = bar_start + PeriodSeconds(_Period);
   long seconds_left = (long)(next_bar - TimeCurrent());
   
   int h = (int)(seconds_left / 3600);
   int m = (int)((seconds_left % 3600) / 60);
   int s = (int)(seconds_left % 60);
   string time_str = StringFormat("%02d:%02d:%02d", h, m, s);
   
   // 2. Calcul de la variation journalière
   double open_day = iOpen(_Symbol, PERIOD_D1, 0);
   double close_current = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   if(close_current == 0) close_current = SymbolInfoDouble(_Symbol, SYMBOL_BID); // Sécurité
   
   double variation = ((close_current - open_day) / open_day) * 100;
   string var_str = StringFormat("(%+.2f%%)", variation);
   
   // 3. Assemblage du texte
   string display_text = time_str + " " + var_str;
   
   // 4. Gestion de l'objet graphique
   string objName = "K2A_CountdownLabel";
   if(ObjectFind(0, objName) < 0) {
      ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_RIGHT_LOWER);
      ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, 138);
      ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, 25);
      ObjectSetInteger(0, objName, OBJPROP_FONTSIZE, 11);
      ObjectSetString(0, objName, OBJPROP_FONT, "Calibri");
   }
   
   ObjectSetString(0, objName, OBJPROP_TEXT, display_text);
   
   //--- AJOUTEZ CETTE LOGIQUE POUR LA COULEUR AUTOMATIQUE
   color backgroundColor = (color)ChartGetInteger(0, CHART_COLOR_BACKGROUND);
   
   // On extrait les composantes rouge, vert et bleu pour déterminer la luminosité (formule standard)
   int r = (int)(backgroundColor & 0xFF);
   int g = (int)((backgroundColor >> 8) & 0xFF);
   int b = (int)((backgroundColor >> 16) & 0xFF);
   double brightness = (r * 0.299 + g * 0.587 + b * 0.114);
   
   // Si la luminosité est faible (< 128), le fond est sombre -> texte blanc. Sinon texte noir.
   color textColor = (brightness < 128) ? clrWhite : clrBlack;
   
   ObjectSetInteger(0, objName, OBJPROP_COLOR, textColor);
}

//+------------------------------------------------------------------+
//| GESTION DU PORTEFEUILLE : ÉQUITE +2% OBSTRUCTIF                  |
//+------------------------------------------------------------------+
void CheckGlobalTargetAndClose()
{
   // 1. Vérifier s'il y a des positions ouvertes
   int total_positions = PositionsTotal();
   if(total_positions == 0) return;

   double total_profit = 0;
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity  = AccountInfoDouble(ACCOUNT_EQUITY);
   
   // Calcul de l'objectif : 2% de la balance actuelle
   double target_profit_currency = balance * 0.01 * taux_d_encaissement; 

   // 2. Parcourir les positions pour calculer le profit latent réel de CE robot 
   // (Optionnel : vous pouvez filtrer par MagicNumber ou par Symbole si nécessaire)
   for(int i = total_positions - 1; i >= 0; i--)
   {
      string symbol = PositionGetSymbol(i);
      if(symbol == _Symbol) // Filtre sur le symbole en cours
      {
         total_profit += PositionGetDouble(POSITION_PROFIT) 
                       + PositionGetDouble(POSITION_SWAP);
      }
   }

   // 3. Vérification de la condition : Est-ce que le gain total atteint ou dépasse les 2% ?
   // Ou de manière plus globale : l'Equity est-elle supérieure à 102% de la Balance ?
   if(total_profit >= target_profit_currency || equity >= (balance + target_profit_currency))
   {
      Print("💰 [TARGET REACHED] L'équité a atteint l'objectif de +2% (Gain: ", total_profit, " / Cible: ", target_profit_currency, "). Fermeture d'urgence de TOUS les trades...");
      
      // Fermeture de TOUTES les positions du symbole
      for(int i = PositionsTotal() - 1; i >= 0; i--)
      {
         uint ticket = (uint)PositionGetTicket(i);
         if(PositionGetSymbol(i) == _Symbol)
         {
            m_trade.PositionClose(ticket);
         }
      }
   }
}


//+------------------------------------------------------------------+
//| Clôture toutes les positions d'un type donné sur le symbole actuel|
//+------------------------------------------------------------------+
void ClosePositionsByType(ENUM_POSITION_TYPE pos_type)
{
   for(int i = PositionsTotal() - 1; i >= 0; i--)
   {
      ulong ticket = PositionGetTicket(i);
      if(ticket > 0)
      {
         // Vérifie que la position appartient à ce graphique et au bon MagicNumber
         if(PositionGetString(POSITION_SYMBOL) == _Symbol)
         {
            if(PositionGetInteger(POSITION_TYPE) == pos_type)
            {
               // Clôture la position sur le marché
               m_trade.PositionClose(ticket);
            }
         }
      }
   }
}


//+------------------------------------------------------------------+
//| DESINITIALISATION                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   Comment("");
   ObjectDelete(0, "AlerteExpiration");
   ObjectDelete(0, "K2A_CountdownLabel");
   UnregisterChartInstance();
   EventKillTimer();
   delete Sniper;
}