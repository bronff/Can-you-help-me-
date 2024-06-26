//+------------------------------------------------------------------+
//|                               Copyright © 2016, Хлыстov Vladimir |
//|                                                cmillion@narod.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, http://cmillion.ru"
#property link      "cmillion@narod.ru"
#property strict
#property description "Poradca zadáva objednávky po prekročení stanovenej vzdialenosti. 1 krok hore – predaj, 1 krok dole – nákup"
#property description "Objaví sa tak sieť, ktorú zatvoríte rukami pomocou tlačidiel poradcu alebo dáte zisk podľa uváženia samotnému poradcovi"
#property description "Poradca je poloautomatický, takže jeho testovanie by sa malo vykonávať iba v režime vizualizácie. Optimalizácia pre tohto poradcu nie je potrebná"
//--------------------------------------------------------------------
extern bool    buystop              = true;        // povoliť odložený nákup 
extern bool    sellstop             = true;        // povoliť odložený predaj
extern int     maxOrdersinp         = 5;           // Maximum number of active orders allowed
extern bool    RemovePending        = true;        // At Max Orders, delete first pending
extern int     Offset               = 10;          // Offset in pips for pending orders from Ask and Bid prices
extern int     StepB                = 20;          // Krok nákupných objednávok
extern int     StepS                = 10;          // Krok objednávky na predaj
extern double  CloseProfitB         = 100;         // uzavrieť nákup založený na celkovom zisku
extern double  CloseProfitS         = 100;         // uzavrieť predaj na základe celkového zisku
extern double  CloseProfit          = 10;          // uzavrieť všetko na základe celkového zisku
extern double  DDTarget             = 2.0;         // Drawdown Target %
extern double  DDTargetDaily        = 3.0;         // Daily Drawdown Target %
extern double  LotB                 = 0.10;        // objem nákupných objednávok
extern double  LotS                 = 0.10;        // Objem predajnej objednávky
extern int     slippage             = 5;           // sklz
extern int     Magic                = 1;

// Vstupné parametre pre lock príkazy
input int     Start_Lock_Orders_    = 0;           // Start Lock Orders (число открытых колен для открытия лок ордера)
input double  PercentLock_          = 100.0;       // % Lock (% перекрытия объема)
input double  MinProfitLock_        = 1.0;         // MinProfitLock (минимальный профит перекрытия лока)
input int     Level_Lock            = 10;          // Level Lock (расстояние до лок ордера)

//--------------------------------------------------------------------
double STOPLEVEL;
double Level=0;
string val, GV_kn_CB, GV_kn_CS, GV_kn_DD, GV_kn_CA, GV_CPB, GV_CPS, GV_CPA, GV_kn_B, GV_kn_S, GV_kn_A, GV_LB, GV_LS, GV_StB, GV_StS, GV_DDT, GV_DLT;
bool LANGUAGE;
double OOP, Profit=0, ProfitB=0, ProfitS=0, DDPct, DailyLossPct, StartingBalance;
int i, b=0, s=0, tip, maxOrders;

// Premenné pre lock logiku
int LOCK_BUY = 0, LOCK_SELL = 0;
double TralLockBuy = 0, TralLockSell = 0;
double ProfitLockBuy = 0, ProfitLockSell = 0;
int TiketLockBuy = 0, TiketLockSell = 0;

// Adding missing variable declarations
int TREND_1, TREND_2;
double MaxOOP1, MinOOP1, MaxOOP2, MinOOP2, lot1, lot2;

// Assuming Ask and Bid are the current market prices fetched from the broker
double adjustedBuyStopPrice = Ask + Offset * Point; // Point is the smallest possible price change, considering broker's specification.
double adjustedSellStopPrice = Bid - Offset * Point;

// Define the StrCon function
string StrCon(string str1, string str2) {
    return StringConcatenate(str1, str2);
}

// Function to create a rectangle label
bool RectLabelCreate(const long chart_ID = 0, const string name = "RectLabel", const int sub_window = 0, const long x = 0, const long y = 0, const int width = 50, const int height = 18, const color back_clr = clrWhite, const color clr = clrBlack, const ENUM_LINE_STYLE style = STYLE_SOLID, const int line_width = 1, const bool back = false, const bool selection = false, const bool hidden = true, const long z_order = 0) {
    ResetLastError();
    if (ObjectFind(chart_ID, name) == -1) {
        ObjectCreate(chart_ID, name, OBJ_RECTANGLE_LABEL, sub_window, 0, 0);
        ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
        ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, line_width);
        ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
        ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
        ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
        ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
        ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
    }
    ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
    ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
    return (true);
}

// Function to create a text label
void DrawLABEL(string name, string Name, int X, int Y, color clr, ENUM_ANCHOR_POINT align = ANCHOR_RIGHT) {
    if (ObjectFind(name) == -1) {
        ObjectCreate(name, OBJ_LABEL, 0, 0, 0);
        ObjectSet(name, OBJPROP_CORNER, 1);
        ObjectSet(name, OBJPROP_XDISTANCE, X);
        ObjectSet(name, OBJPROP_YDISTANCE, Y);
        ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
        ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, name, OBJPROP_ANCHOR, align);
    }
    ObjectSetText(name, Name, 8, "Arial", clr);
}

// Function to create a button
bool ButtonCreate(const long chart_ID = 0, const string name = "Button", const int sub_window = 0, const long x = 0, const long y = 0, const int width = 50, const int height = 18, const string text = "Button", const string font = "Arial", const int font_size = 8, const color clr = clrBlack, const color clrON = clrLightGray, const color clrOFF = clrLightGray, const color border_clr = clrNONE, const bool state = false, const ENUM_BASE_CORNER CORNER = CORNER_RIGHT_UPPER) {
    if (ObjectFind(chart_ID, name) == -1) {
        ObjectCreate(chart_ID, name, OBJ_BUTTON, sub_window, 0, 0);
        ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
        ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
        ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, CORNER);
        ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
        ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
        ObjectSetInteger(chart_ID, name, OBJPROP_BACK, 0);
        ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, 0);
        ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, 0);
        ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, 1);
        ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, 1);
        ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
    }
    ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_COLOR, border_clr);
    color back_clr;
    if (ObjectGetInteger(chart_ID, name, OBJPROP_STATE)) back_clr = clrON;
    else back_clr = clrOFF;
    ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
    ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
    return (true);
}

// Function to create a horizontal line
bool HLineCreate(const string name = "HLine", double price = 0) {
    ResetLastError();
    if (!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price)) {
        Print(__FUNCTION__, ": failed to create a horizontal line! Error code = ", GetLastError());
        return (false);
    }
    ObjectSetInteger(0, name, OBJPROP_COLOR, clrYellow);
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    return (true);
}

// Function to select text based on a condition
string Text(bool P, string c, string d) {
    if (P) return (d);
    else return (c);
}

// Function to create an edit field
void EditCreate(const long chart_ID = 0, const string name = "Edit", const int sub_window = 0, const long x = 0, const long y = 0, const int width = 50, const int height = 18, const string text = "", const string font = "Arial", const int font_size = 8, const ENUM_ALIGN_MODE align = ALIGN_CENTER, const bool state = false) {
    if (ObjectFind(chart_ID, name) == -1) {
        ObjectCreate(chart_ID, name, OBJ_EDIT, sub_window, 0, 0);
        ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
        ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
        ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetString(chart_ID, name, OBJPROP_FONT, font);
        ObjectSetInteger(chart_ID, name, OBJPROP_FONTSIZE, font_size);
        ObjectSetInteger(chart_ID, name, OBJPROP_ALIGN, align);
        ObjectSetInteger(chart_ID, name, OBJPROP_STATE, state);
    }
    ObjectSetString(chart_ID, name, OBJPROP_TEXT, text);
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
}

//-------------------------------------------------------------------- 
int OnInit() { 
    LANGUAGE = TerminalInfoString(TERMINAL_LANGUAGE) == "English";
    if (IsTesting()) ObjectsDeleteAll(0);
    int AN = AccountNumber();
    string GVn = StringConcatenate("cm fishing ", AN, " ", Symbol());
    maxOrders = maxOrdersinp;
    StartingBalance = AccountBalance();
    RectLabelCreate(0, "rl BalanceW", 0, 195, 20, 195, 90);
    DrawLABEL("rl IsTradeAllowed", Text(LANGUAGE, "Obchod", "Trade"), 100, 30, clrRed, ANCHOR_CENTER);

    //-- current dd row
    ButtonCreate(0, "kn close Drawdown", 0, 85, 40, 80, 20, "Curr DD %");
    RectLabelCreate(0, "rl close DDD Pct", 0, 190, 40, 50, 20);

    //-- daily dd row
    ButtonCreate(0, "rl Loss Rec", 0, 85, 62, 80, 20, "Daily Loss"); 
    RectLabelCreate(0, "rl Daily PL P", 0, 190, 62, 50, 20);

    RectLabelCreate(0, "rl Close Profit", 0, 195, 105, 195, 90);
    DrawLABEL("rl CloseProfit", Text(LANGUAGE, "Uzatváranie na zisk", "Closing profit"), 100, 115, clrBlack, ANCHOR_CENTER);
    ButtonCreate(0, "kn close Buystop", 0, 140, 125, 50, 20, "X Buys");
    ButtonCreate(0, "kn close Sellstop", 0, 140, 147, 50, 20, "X Sells");
    ButtonCreate(0, "kn close All", 0, 140, 169, 50, 20, Text(LANGUAGE, "ZATVORENÉ", "X all"));

    ButtonCreate(0, "kn Buystop Auto", 0, 40, 125, 35, 20, Text(LANGUAGE, "auto", "auto"));
    ButtonCreate(0, "kn Sellstop Auto", 0, 40, 147, 35, 20, Text(LANGUAGE, "auto", "auto"));
    ButtonCreate(0, "kn All Auto", 0, 40, 169, 35, 20, Text(LANGUAGE, "auto", "auto"));

    if (Level != 0) HLineCreate("kn Start", Level);

    GV_kn_DD = StringConcatenate(GVn, " close Drawdown");
    if (GlobalVariableCheck(GV_kn_DD)) ObjectSetInteger(0, "kn close Drawdown", OBJPROP_STATE, true);
    GV_kn_CB = StringConcatenate(GVn, " Close Buystop Auto");
    if (GlobalVariableCheck(GV_kn_CB)) ObjectSetInteger(0, "kn Buystop Auto", OBJPROP_STATE, true);
    GV_kn_CS = StringConcatenate(GVn, " Close Sellstop Auto");
    if (GlobalVariableCheck(GV_kn_CS)) ObjectSetInteger(0, "kn Sellstop Auto", OBJPROP_STATE, true);
    GV_kn_CA = StringConcatenate(GVn, " Close All Auto");
    if (GlobalVariableCheck(GV_kn_CA)) ObjectSetInteger(0, "kn All Auto", OBJPROP_STATE, true);
    GV_CPB = StringConcatenate(GVn, " Close Profit Buystop");
    if (GlobalVariableCheck(GV_CPB)) CloseProfitB = GlobalVariableGet(GV_CPB);
    GV_CPS = StringConcatenate(GVn, " Close Profit Sellstop");
    if (GlobalVariableCheck(GV_CPS)) CloseProfitS = GlobalVariableGet(GV_CPS);
    GV_CPA = StringConcatenate(GVn, " Close Profit All");
    if (GlobalVariableCheck(GV_CPA)) CloseProfit = GlobalVariableGet(GV_CPA);
    GV_DDT = StringConcatenate(GVn, " DD Target");
    if (GlobalVariableCheck(GV_DDT)) DDTarget = GlobalVariableGet(GV_DDT);
    GV_DLT = StringConcatenate(GVn, " DL Target");
    if (GlobalVariableCheck(GV_DLT)) DDTargetDaily = GlobalVariableGet(GV_DLT);

    EditCreate(0, "rl DD Target", 0, 138, 40, 50, 20, DoubleToString(DDTarget, 1), "Arial", 8, ALIGN_CENTER, false);
    EditCreate(0, "rl Daily DD Target", 0, 138, 62, 50, 20, DoubleToString(DDTargetDaily, 1), "Arial", 8, ALIGN_CENTER, false);

    EditCreate(0, "rl Buystop Auto", 0, 90, 125, 50, 20, DoubleToString(CloseProfitB, 2), "Arial", 8, ALIGN_CENTER, false);
    EditCreate(0, "rl Sellstop Auto", 0, 90, 147, 50, 20, DoubleToString(CloseProfitS, 2), "Arial", 8, ALIGN_CENTER, false);
    EditCreate(0, "rl All Auto", 0, 90, 169, 50, 20, DoubleToString(CloseProfit, 2), "Arial", 8, ALIGN_CENTER, false);

    ButtonCreate(0, "kn Clear", 0, 75, 25, 70, 20, Text(LANGUAGE, "Nachinat", "Start"), "Times New Roman", 8, clrBlack, clrGray, clrLightGray, clrNONE, false, CORNER_RIGHT_LOWER);
    RectLabelCreate(0, "rl Buystop", 0, 190, 125, 50, 20);
    RectLabelCreate(0, "rl Sellstop", 0, 190, 147, 50, 20);
    RectLabelCreate(0, "rl All", 0, 190, 169, 50, 20);

    int Y = 192;
    RectLabelCreate(0, "rl Step Lot", 0, 195, Y, 195, 90);
    Y += 15;
    DrawLABEL("rl StepLot ", Text(LANGUAGE, "Nastavenia kroku a šarže", "Settings"), 100, Y, clrBlack, ANCHOR_CENTER);
    Y += 20;
    DrawLABEL("rl Step ", Text(LANGUAGE, "krok", "Step"), 120, Y, clrBlack, ANCHOR_CENTER);
    DrawLABEL("rl Lot ", Text(LANGUAGE, "Objem", "Lot"), 170, Y, clrBlack, ANCHOR_CENTER);
    Y += 10;

    GV_LB = StringConcatenate(GVn, " Lot Buystop");
    if (GlobalVariableCheck(GV_LB)) LotB = GlobalVariableGet(GV_LB);
    GV_LS = StringConcatenate(GVn, " Lot Sellstop");
    if (GlobalVariableCheck(GV_LS)) LotS = GlobalVariableGet(GV_LS);
    GV_StB = StringConcatenate(GVn, " Step Buystop");
    if (GlobalVariableCheck(GV_StB)) StepB = (int)GlobalVariableGet(GV_StB);
    GV_StS = StringConcatenate(GVn, " Step Sellstop");
    if (GlobalVariableCheck(GV_StS)) StepS = (int)GlobalVariableGet(GV_StS);

    EditCreate(0, "rl Buystop Step", 0, 139, Y, 40, 20, IntegerToString(StepB), "Arial", 8, ALIGN_CENTER, false);
    EditCreate(0, "rl Buystop Lot", 0, 190, Y, 40, 20, DoubleToString(LotB, 2), "Arial", 8, ALIGN_CENTER, false);
    ButtonCreate(0, "kn open Buystop", 0, 85, Y, 80, 20, Text(LANGUAGE, "Kúpiť", "Open Buystop"));
    Y += 20;
    EditCreate(0, "rl Sellstop Step", 0, 139, Y, 40, 20, IntegerToString(StepS), "Arial", 8, ALIGN_CENTER, false);
    EditCreate(0, "rl Sellstop Lot", 0, 190, Y, 40, 20, DoubleToString(LotS, 2), "Arial", 8, ALIGN_CENTER, false);
    ButtonCreate(0, "kn open Sellstop", 0, 85, Y, 80, 20, Text(LANGUAGE, "Predať", "Open Sellstop"));
    GV_kn_B = StringConcatenate(GVn, " Buystop");
    if (GlobalVariableCheck(GV_kn_B)) buystop = GlobalVariableGet(GV_kn_B);
    else GlobalVariableSet(GV_kn_B, buystop);

    GV_kn_S = StringConcatenate(GVn, " Sellstop");
    if (GlobalVariableCheck(GV_kn_S)) sellstop = GlobalVariableGet(GV_kn_S);
    else GlobalVariableSet(GV_kn_S, sellstop);

    ObjectSetInteger(0, "kn open Buystop", OBJPROP_STATE, buystop);
    ObjectSetInteger(0, "kn open Sellstop", OBJPROP_STATE, sellstop);

    return (INIT_SUCCEEDED);
}
//-------------------------------------------------------------------
void OnTick() {
    if (!IsTradeAllowed()) {
        DrawLABEL("rl IsTradeAllowed", Text(LANGUAGE, "Obchodovanie je zakázané", "Trade is disabled"), 100, 30, clrRed, ANCHOR_CENTER);
        return;
    } else {
        DrawLABEL("rl IsTradeAllowed", Text(LANGUAGE, "Obchod povolený", "Trade is enabled"), 100, 30, clrGreen, ANCHOR_CENTER);
    }

    STOPLEVEL = MarketInfo(Symbol(), MODE_STOPLEVEL);
    LotB = StringToDouble(ObjectGetString(0, "rl Buystop Lot", OBJPROP_TEXT));
    LotS = StringToDouble(ObjectGetString(0, "rl Sellstop Lot", OBJPROP_TEXT));
    StepB = (int)StringToInteger(ObjectGetString(0, "rl Buystop Step", OBJPROP_TEXT));
    StepS = (int)StringToInteger(ObjectGetString(0, "rl Sellstop Step", OBJPROP_TEXT));

    DDTarget = StringToDouble(ObjectGetString(0, "rl DD Target", OBJPROP_TEXT));
    ObjectSetString(0, "rl DD Target", OBJPROP_TEXT, DoubleToString(DDTarget, 1));
    DDTargetDaily = StringToDouble(ObjectGetString(0, "rl Daily DD Target", OBJPROP_TEXT));
    ObjectSetString(0, "rl Daily DD Target", OBJPROP_TEXT, DoubleToString(DDTargetDaily, 1));

    CloseProfitB = StringToDouble(ObjectGetString(0, "rl Buystop Auto", OBJPROP_TEXT));
    ObjectSetString(0, "rl Buystop Auto", OBJPROP_TEXT, DoubleToString(CloseProfitB, 2));
    CloseProfitS = StringToDouble(ObjectGetString(0, "rl Sellstop Auto", OBJPROP_TEXT));
    ObjectSetString(0, "rl Sellstop Auto", OBJPROP_TEXT, DoubleToString(CloseProfitS, 2));
    CloseProfit = StringToDouble(ObjectGetString(0, "rl All Auto", OBJPROP_TEXT));
    ObjectSetString(0, "rl All Auto", OBJPROP_TEXT, DoubleToString(CloseProfit, 2));

    if (LotB != GlobalVariableGet(GV_LB)) GlobalVariableSet(GV_LB, LotB);
    if (LotS != GlobalVariableGet(GV_LS)) GlobalVariableSet(GV_LS, LotS);
    if (StepB != GlobalVariableGet(GV_StB)) GlobalVariableSet(GV_StB, StepB);
    if (DDTarget != GlobalVariableGet(GV_DDT)) GlobalVariableSet(GV_DDT, DDTarget);
    if (DDTargetDaily != GlobalVariableGet(GV_DLT)) GlobalVariableSet(GV_DLT, DDTargetDaily);

    ObjectSetDouble(0, "kn Start", OBJPROP_PRICE, Level);
    CountOrders();
    if (AccountEquity() > StartingBalance) StartingBalance = AccountEquity();

    Print(StartingBalance);
    Profit = ProfitB + ProfitS;
    DDPct = (AccountEquity() / StartingBalance - 1) * 100;
    DailyLossPct = CalcDailyLoss();
    DrawLABEL("Profit B", DoubleToStr(ProfitB, 2), 145, 135, Color(ProfitB < 0, clrRed, clrGreen), ANCHOR_RIGHT);
    DrawLABEL("Profit S", DoubleToStr(ProfitS, 2), 145, 157, Color(ProfitS < 0, clrRed, clrGreen), ANCHOR_RIGHT);
    DrawLABEL("Profit A", DoubleToStr(Profit, 2), 145, 179, Color(Profit < 0, clrRed, clrGreen), ANCHOR_RIGHT);
    DrawLABEL("Profit DD", DoubleToStr(DDPct, 2) + "%", 145, 50, Color(DDPct < 0, clrRed, clrGreen), ANCHOR_RIGHT);
    DrawLABEL("Profit Daily Loss Pct", DoubleToStr(DailyLossPct, 2) + "%", 145, 72, Color(DailyLossPct < 0, clrRed, clrGreen), ANCHOR_RIGHT);

    //---
    if (ObjectGetInteger(0, "kn Clear", OBJPROP_STATE)) {
        Level = Bid;
        ObjectsDeleteAll(0, "#");
        ObjectsDeleteAll(0, OBJ_ARROW);
        ObjectsDeleteAll(0, OBJ_TREND);
        ObjectsDeleteAll(0, OBJ_HLINE);
        ObjectSetInteger(0, "kn Clear", OBJPROP_STATE, false);
        HLineCreate("kn Start", Level);
        maxOrders = maxOrdersinp;
    }
    if (b != 0 && ObjectGetInteger(0, "kn close Buystop", OBJPROP_STATE)) {
        if (!CloseAll(OP_BUYSTOP)) Print("Error OrderSend ", GetLastError());
        else ObjectSetInteger(0, "kn close Buystop", OBJPROP_STATE, false);
    }
    //---
    if (s != 0 && ObjectGetInteger(0, "kn close Sellstop", OBJPROP_STATE)) {
        if (!CloseAll(OP_SELLSTOP)) Print("Error OrderSend ", GetLastError());
        else ObjectSetInteger(0, "kn close Sellstop", OBJPROP_STATE, false);
    }
    //---
    if (s + b != 0 && ObjectGetInteger(0, "kn close All", OBJPROP_STATE)) {
        if (!CloseAll(-1)) Print("Error OrderSend ", GetLastError());
        else ObjectSetInteger(0, "kn close All", OBJPROP_STATE, false);
    }
    //---
    if (ObjectGetInteger(0, "kn All Auto", OBJPROP_STATE)) {
        if (GlobalVariableGet(GV_kn_CA) == 0)
            GlobalVariableSet(GV_kn_CA, 1);

        ObjectSetInteger(0, "rl All Auto", OBJPROP_COLOR, clrRed);
        CloseProfit = StringToDouble(ObjectGetString(0, "rl All Auto", OBJPROP_TEXT));
        if (GlobalVariableGet(GV_CPA) != CloseProfit) GlobalVariableSet(GV_CPA, CloseProfit);
        if (Profit >= CloseProfit) {
            CloseAll(-1);
            return;
        }
    } else {
        ObjectSetInteger(0, "rl All Auto", OBJPROP_COLOR, clrLightGray);
        GlobalVariableDel(GV_kn_CA);
    }

    //--- Draw Down Auto
    if (ObjectGetInteger(0, "kn close Drawdown", OBJPROP_STATE)) {
        if (GlobalVariableGet(GV_kn_DD) == 0) GlobalVariableSet(GV_kn_DD, 1);

        ObjectSetInteger(0, "rl DD Target", OBJPROP_COLOR, clrRed);
        DDTarget = StringToDouble(ObjectGetString(0, "rl DD Target", OBJPROP_TEXT));
        if (GlobalVariableGet(GV_DDT) != DDTarget) GlobalVariableSet(GV_DDT, DDTarget);
        if (DDPct <= -DDTarget) {
            DeleteAllPending();
            maxOrders = 0;
            Alert("Stopped Trading due to Drawdown");
        }
    } else {
        ObjectSetInteger(0, "rl DD Target", OBJPROP_COLOR, clrBlack);
        GlobalVariableDel(GV_kn_DD);
    }

    //--- Daily Loss Auto
    if (ObjectGetInteger(0, "rl Loss Rec", OBJPROP_STATE)) {
        if (GlobalVariableGet(GV_kn_DD) == 0) GlobalVariableSet(GV_kn_DD, 1);

        ObjectSetInteger(0, "rl Daily DD Target", OBJPROP_COLOR, clrRed);
        DDTargetDaily = StringToDouble(ObjectGetString(0, "rl Daily DD Target", OBJPROP_TEXT));
        if (GlobalVariableGet(GV_DLT) != DDTargetDaily) GlobalVariableSet(GV_DLT, DDTargetDaily);
        if (DailyLossPct <= -DDTargetDaily) {
            maxOrders = 0;
            Alert("Stopped trading due to Daily Loss Amount");
        }
    } else {
        ObjectSetInteger(0, "rl Daily DD Target", OBJPROP_COLOR, clrBlack);
        GlobalVariableDel(GV_kn_DD);
    }

    //---sell stop auto
    if (ObjectGetInteger(0, "kn Sellstop Auto", OBJPROP_STATE)) {
        if (GlobalVariableGet(GV_kn_CS) == 0) GlobalVariableSet(GV_kn_CS, 1);

        ObjectSetInteger(0, "rl Sellstop Auto", OBJPROP_COLOR, clrRed);
        CloseProfitS = StringToDouble(ObjectGetString(0, "rl Sellstop Auto", OBJPROP_TEXT));
        if (GlobalVariableGet(GV_CPS) != CloseProfitS) GlobalVariableSet(GV_CPS, CloseProfitS);
        if (ProfitS >= CloseProfitS) {
            CloseAll(OP_SELLSTOP);
            return;
        }
    } else {
        ObjectSetInteger(0, "rl Sellstop Auto", OBJPROP_COLOR, clrLightGray);
        GlobalVariableDel(GV_kn_CS);
    }
    //---
    if (ObjectGetInteger(0, "kn Buystop Auto", OBJPROP_STATE)) {
        if (GlobalVariableGet(GV_kn_CB) == 0) GlobalVariableSet(GV_kn_CB, 1);

        ObjectSetInteger(0, "rl Buystop Auto", OBJPROP_COLOR, clrRed);
        CloseProfitB = StringToDouble(ObjectGetString(0, "rl Buystop Auto", OBJPROP_TEXT));
        if (GlobalVariableGet(GV_CPB) != CloseProfitB) GlobalVariableSet(GV_CPB, CloseProfitB);
        if (ProfitB >= CloseProfitB) {
            CloseAll(OP_BUYSTOP);
            return;
        }
    } else {
        ObjectSetInteger(0, "rl Buystop Auto", OBJPROP_COLOR, clrLightGray);
        GlobalVariableDel(GV_kn_CB);
    }
    //---
    if (buystop != ObjectGetInteger(0, "kn open Buystop", OBJPROP_STATE)) {
        buystop = ObjectGetInteger(0, "kn open Buystop", OBJPROP_STATE);
        if (GlobalVariableGet(GV_kn_B) != buystop) GlobalVariableSet(GV_kn_B, buystop);
    }
    if (buystop) {
        ObjectSetInteger(0, "rl Buystop Step", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "rl Buystop Lot", OBJPROP_COLOR, clrRed);
    } else {
        ObjectSetInteger(0, "rl Buystop Step", OBJPROP_COLOR, clrLightGray);
        ObjectSetInteger(0, "rl Buystop Lot", OBJPROP_COLOR, clrLightGray);
    }
    //---
    if (sellstop != ObjectGetInteger(0, "kn open Sellstop", OBJPROP_STATE)) {
        sellstop = ObjectGetInteger(0, "kn open Sellstop", OBJPROP_STATE);
        if (GlobalVariableGet(GV_kn_S) != sellstop) GlobalVariableSet(GV_kn_S, sellstop);
    }
    if (sellstop) {
        ObjectSetInteger(0, "rl Sellstop Step", OBJPROP_COLOR, clrRed);
        ObjectSetInteger(0, "rl Sellstop Lot", OBJPROP_COLOR, clrRed);
    } else {
        ObjectSetInteger(0, "rl Sellstop Step", OBJPROP_COLOR, clrLightGray);
        ObjectSetInteger(0, "rl Sellstop Lot", OBJPROP_COLOR, clrLightGray);
    }

    // Count current active orders
    if (Bid <= Level - StepB * Point && Level != 0) {
        if (b >= maxOrders && !RemovePending) {
            Print("Maximum number of active Buys (", maxOrders, ") reached. No new Buys will be placed.");
            return;
        } else if (b >= maxOrders && RemovePending) {
            DeletePending(OP_BUYSTOP);
        }
        if (b < maxOrders && buystop && AccountFreeMarginCheck(Symbol(), OP_BUY, LotB) > 0) {
            adjustedBuyStopPrice = Ask + Offset * Point; // Use the global variable
            int ticket = OrderSend(Symbol(), OP_BUYSTOP, LotB, adjustedBuyStopPrice, slippage, 0, 0, "Buy Stop Order", Magic, 0, clrGreen);
            if (ticket < 0) {
                Print("Error opening Buy Stop order: ", ErrorDescription(GetLastError()));
            } else Level = Bid;
        }
    }
    if (Bid >= Level + StepS * Point && Level != 0) {
        if (s >= maxOrders && !RemovePending) {
            Print("Maximum number of active Sells(", maxOrders, ") reached. No new Sells will be placed.");
            return;
        } else if (s >= maxOrders && RemovePending) {
            DeletePending(OP_SELLSTOP);
        }
        if (s < maxOrders && sellstop && AccountFreeMarginCheck(Symbol(), OP_SELL, LotS) > 0) {
            adjustedSellStopPrice = Bid - Offset * Point; // Use the global variable
            int ticket = OrderSend(Symbol(), OP_SELLSTOP, LotS, adjustedSellStopPrice, slippage, 0, 0, "Sell Stop Order", Magic, 0, clrDarkOrange);
            if (ticket < 0) {
                Print("Error opening Sell Stop order: ", ErrorDescription(GetLastError()));
            } else Level = Bid;
        }
    }

    // Logika pre uzamykanie pozícií
    if (Start_Lock_Orders_ != 0) {
        if (TiketLockBuy == 0 && b >= Start_Lock_Orders_) {
            if (TralLockBuy == 0) {
                if (TREND_1 == 1)
                    TralLockBuy = Bid + Level_Lock * Point;
                if (TREND_1 == -1)
                    TralLockBuy = Ask - Level_Lock * Point;
            } else {
                if (TREND_1 < 0) {
                    if (Ask + Level_Lock * Point < TralLockBuy)
                        TralLockBuy = Ask + Level_Lock * Point;
                    else if (Ask >= TralLockBuy)
                        LOCK_BUY = 1;
                    if (TralLockBuy < MaxOOP1)
                        TralLockBuy = MaxOOP1;
                }
                if (TREND_1 > 0) {
                    if (Bid - Level_Lock * Point > TralLockBuy)
                        TralLockBuy = Bid - Level_Lock * Point;
                    else if (Bid <= TralLockBuy)
                        LOCK_BUY = -1;
                    if (TralLockBuy > MinOOP1)
                        TralLockBuy = MinOOP1;
                }
            }
        } else {
            TralLockBuy = 0;
        }
        if (TiketLockSell == 0 && s >= Start_Lock_Orders_) {
            if (TralLockSell == 0) {
                if (TREND_2 == 1)
                    TralLockSell = Bid + Level_Lock * Point;
                if (TREND_2 == -1)
                    TralLockSell = Ask - Level_Lock * Point;
            } else {
                if (TREND_2 < 0) {
                    if (Ask + Level_Lock * Point < TralLockSell)
                        TralLockSell = Ask + Level_Lock * Point;
                    else if (Ask >= TralLockSell)
                        LOCK_SELL = 1;
                    if (TralLockSell < MaxOOP2)
                        TralLockSell = MaxOOP2;
                }
                if (TREND_2 > 0) {
                    if (Bid - Level_Lock * Point > TralLockSell)
                        TralLockSell = Bid - Level_Lock * Point;
                    else if (Bid <= TralLockSell)
                        LOCK_SELL = -1;
                    if (TralLockSell > MinOOP2)
                        TralLockSell = MinOOP2;
                }
            }
        } else {
            TralLockSell = 0;
        }

        // Otváranie lock príkazov
        if (LOCK_BUY != 0 && TiketLockBuy == 0) {
            lot1 = NormalizeDouble(LotB / 100 * PercentLock_, 2);
            if (lot1 > MaxOOP1)
                lot1 = MaxOOP1;
            if (SendOrder(Symbol(), LOCK_BUY, lot1, StrCon("(", IntegerToString(Magic), ") Lock")))
                LOCK_BUY = 0;
        }
        if (LOCK_SELL != 0 && TiketLockSell == 0) {
            lot2 = NormalizeDouble(LotS / 100 * PercentLock_, 2);
            if (lot2 > MaxOOP2)
                lot2 = MaxOOP2;
            if (SendOrder(Symbol(), LOCK_SELL, lot2, StrCon("(", IntegerToString(Magic), ") Lock")))
                LOCK_SELL = 0;
        }

        // Zatváranie lock príkazov
        if (TiketLockBuy != 0 && ProfitB + ProfitLockBuy >= MinProfitLock_) {
            CloseTiket(TiketFirst1);
            CloseTiket(TiketLockBuy);
            if (Visual) {
                string txt = StrCon(TimeToString(iTime(NULL, 0, 0)), " Lock");
                TextCreate(0, txt, 0, iTime(NULL, 0, 0), Bid, DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE) - AB, 2), "Arial", 8, clrRed, 45, ANCHOR_LEFT_LOWER, true, true);
                txt = StrCon("Lock ", IntegerToString(TiketLockBuy), " + ", IntegerToString(TiketFirst1), " Profit ", DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE) - AB, 2), AC);
                ALERT(txt);
            }
            return;
        }
        if (TiketLockSell != 0 && ProfitS + ProfitLockSell >= MinProfitLock_) {
            CloseTiket(TiketFirst2);
            CloseTiket(TiketLockSell);
            if (Visual) {
                string txt = StrCon(TimeToString(iTime(NULL, 0, 0)), " Lock");
                TextCreate(0, txt, 0, iTime(NULL, 0, 0), Bid, DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE) - AB, 2), "Arial", 8, clrRed, 45, ANCHOR_LEFT_LOWER, true, true);
                txt = StrCon("Lock ", IntegerToString(TiketLockSell), " + ", IntegerToString(TiketFirst2), " Profit ", DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE) - AB, 2), AC);
                ALERT(txt);
            }
            return;
        }

        // Vizualizácia lock príkazov
        if (Visual) {
            if (TiketLockBuy != 0) {
                string txt = StrCon(DoubleToString(ProfitLockBuy, 2), " ", DoubleToString(ProfitFirst1, 2), "=", DoubleToString(ProfitFirst1 + ProfitLockBuy, 2));
                if (ObjectFind(0, "cm Tiket Lock1") == -1) {
                    EditCreate(0, "cm Tiket Lock1 S", 0, 125, 127, 120, 20, StrCon("Lock ", Symbol()), "Arial", 8, ALIGN_CENTER, false, CORNER_RIGHT_UPPER, clrBlack, color_fon);
                    EditCreate(0, "cm Tiket Lock1 0", 0, 125, 146, 120, 20, txt, "Arial", 8, ALIGN_CENTER, false, CORNER_RIGHT_UPPER);
                }
                ObjectSetString(0, "cm Tiket Lock1 0", OBJPROP_TEXT, txt);
            } else {
                ObjectsDeleteAll(0, "cm Tiket Lock1");
            }
            if (TiketLockSell != 0) {
                string txt = StrCon(DoubleToString(ProfitLockSell, 2), " ", DoubleToString(ProfitFirst2, 2), "=", DoubleToString(ProfitFirst2 + ProfitLockSell, 2));
                if (ObjectFind(0, "cm Tiket Lock2") == -1) {
                    EditCreate(0, "cm Tiket Lock2 S", 0, 125, 165, 120, 20, StrCon("Lock ", Symbol()), "Arial", 8, ALIGN_CENTER, false, CORNER_RIGHT_UPPER, clrBlack, color_fon);
                    EditCreate(0, "cm Tiket Lock2 0", 0, 125, 184, 120, 20, txt, "Arial", 8, ALIGN_CENTER, false, CORNER_RIGHT_UPPER);
                }
                ObjectSetString(0, "cm Tiket Lock2 0", OBJPROP_TEXT, txt);
            } else {
                ObjectsDeleteAll(0, "cm Tiket Lock2");
            }

            // Kreslenie liniek pre lock príkazov
            if (TralLockBuy != 0) {
                HLineCreate(0, StrCon("cm Lock1 ", Symbol()), 0, TralLockBuy, clrRed, STYLE_DOT, 1, true, false);
                TextCreate(0, StrCon("cm Lock1 ", Symbol(), " 1"), 0, iTime(NULL, 0, (int)index), TralLockBuy, StrCon("Lock ", (TREND_1 > 0 ? "Sell " : "Buy "), Symbol()), "Arial", 10, clrRed, 0, ANCHOR_LOWER);
            } else {
                ObjectsDeleteAll(0, "cm Lock1");
            }

            if (TralLockSell != 0) {
                double price = (TralLockSell - L) / (H - L) * (High_Win - Low_Win) + Low_Win;
                if (!correlation)
                    price = High_Win - price + Low_Win;
                HLineCreate(0, StrCon("cm Lock2 ", Symbol()), 0, price, clrRed, STYLE_DOT, 1, true, false);
                TextCreate(0, StrCon("cm Lock2 ", Symbol(), " 2"), 0, iTime(NULL, 0, (int)index), price, StrCon("Lock ", (TREND_2 > 0 ? "Sell " : "Buy "), Symbol()), "Arial", 10, clrRed, 0, ANCHOR_LOWER);
            } else {
                ObjectsDeleteAll(0, "cm Lock2");
            }
        }
    }

    // Calculate and display drawdown and profits
    CountOrders();
    double profitTotal = CalcTotalLoss();
    double dailyLoss = CalcDailyLoss();
    Print("Total Profit: ", profitTotal, " | Daily Loss: ", dailyLoss);
}

// Calculate Total Loss
double CalcTotalLoss() {
    double profit = 0;
    int j;

    // open orders
    for (j = 0; j < OrdersTotal(); j++) {
        if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && Magic == OrderMagicNumber()) {
                profit += OrderProfit() + OrderCommission() + OrderSwap();
            }
        }
    }
    // closed orders
    for (j = 0; j < OrdersHistoryTotal(); j++) {
        if (OrderSelect(j, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && Magic == OrderMagicNumber()) {
                if (TimeMonth(OrderCloseTime()) == TimeMonth(TimeCurrent()) && TimeYear(OrderCloseTime()) == TimeYear(TimeCurrent())) {
                    profit += OrderProfit() + OrderCommission() + OrderSwap();
                }
            }
        }
    }
    profit = profit / AccountBalance() * 100;
    return (profit);
}

// Calculate Daily Loss
double CalcDailyLoss() {
    double profit = 0;
    int j;

    // open orders
    for (j = 0; j < OrdersTotal(); j++) {
        if (OrderSelect(j, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && Magic == OrderMagicNumber()) {
                profit += OrderProfit() + OrderCommission() + OrderSwap();
            }
        }
    }
    // closed orders
    for (j = 0; j < OrdersHistoryTotal(); j++) {
        if (OrderSelect(j, SELECT_BY_POS, MODE_HISTORY)) {
            if (OrderSymbol() == Symbol() && Magic == OrderMagicNumber()) {
                if (TimeDay(OrderCloseTime()) ==  TimeDay(TimeCurrent()) && TimeMonth(OrderCloseTime()) ==  TimeMonth(TimeCurrent())
                    && TimeYear(OrderCloseTime()) ==  TimeYear(TimeCurrent())) {
                    profit += OrderProfit() + OrderCommission() + OrderSwap();
                }
            }
        }
    }
    profit = profit / AccountBalance() * 100;
    return (profit);
}

void CountOrders() {
    b = 0;
    s = 0;
    ProfitB = 0;
    ProfitS = 0;
    DDPct = 0;
    for (i = 0; i < OrdersTotal(); i++) {
        if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {
            if (OrderSymbol() == Symbol() && Magic == OrderMagicNumber()) {
                tip = OrderType();
                OOP = NormalizeDouble(OrderOpenPrice(), Digits);
                Profit = OrderProfit() + OrderSwap() + OrderCommission();
                if (tip == OP_BUY || tip == OP_BUYSTOP) {
                    ProfitB += Profit;
                    b++;
                }
                if (tip == OP_SELL || tip == OP_SELLSTOP) {
                    ProfitS += Profit;
                    s++;
                }
            }
        }
    }
}

bool DeletePending(int type) {
    bool error = true;
    int j, OT, ticket = 0;
    double prc = 0;

    for (j = OrdersTotal() - 1; j >= 0; j--) {
        if (OrderSelect(j, SELECT_BY_POS)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
                OT = OrderType();
                if (OT == OP_BUYSTOP && type == OT) {
                    if (prc == 0) {
                        prc = OrderOpenPrice();
                        ticket = OrderTicket();
                    }
                    if (OrderOpenPrice() > prc) {
                        prc = OrderOpenPrice();
                        ticket = OrderTicket();
                    }
                }
                if (OT == OP_SELLSTOP && type == OT) {
                    if (prc == 0) {
                        prc = OrderOpenPrice();
                        ticket = OrderTicket();
                    }
                    if (OrderOpenPrice() < prc) {
                        prc = OrderOpenPrice();
                        ticket = OrderTicket();
                    }
                }
            }
        }
    }
    if (ticket == 0) {
        Print("No Pending Orders to Delete");
    }
    if (ticket > 0) {
        error = OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES);
        if (error) {
            if (OrderType() == OP_BUYSTOP) {
                error = OrderDelete(OrderTicket(), clrBlue);
            }
            if (OrderType() == OP_SELLSTOP) {
                error = OrderDelete(OrderTicket(), clrRed);
            }
        } else {
            Print("Error selecting order for deletion: ", ErrorDescription(GetLastError()));
        }
    }
    CountOrders();

    Sleep(1000);
    RefreshRates();
    return (true); // Vráti 'true' ak všetko prebehlo úspešne
}

//+------------------------------------------------------------------+
bool DeleteAllPending() {
    bool error = true;
    int j;

    for (j = OrdersTotal() - 1; j >= 0; j--) {
        if (OrderSelect(j, SELECT_BY_POS)) {
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic) {
                if (OrderType() == OP_BUYSTOP) {
                    error = OrderDelete(OrderTicket(), clrBlue);
                }
                if (OrderType() == OP_SELLSTOP) {
                    error = OrderDelete(OrderTicket(), clrRed);
                }
            }
        }
    }

    CountOrders();

    return (true); // Vráti 'true' ak všetko prebehlo úspešne
}

// Function to create an error description
string ErrorDescription(const int code) {
    switch (code) {
        case 1: return "No error returned.";
        case 2: return "Common error.";
        case 3: return "Invalid trade parameters.";
        case 4: return "Trade server is busy.";
        case 5: return "Old version of the client terminal.";
        case 6: return "No connection with trade server.";
        case 7: return "Not enough rights.";
        case 8: return "Too frequent requests.";
        case 9: return "Malfunctional trade operation.";
        case 64: return "Account disabled.";
        case 65: return "Invalid account.";
        case 128: return "Trade timeout.";
        case 129: return "Invalid price.";
        case 130: return "Invalid stops.";
        case 131: return "Invalid trade volume.";
        case 132: return "Market is closed.";
        case 133: return "Trade is disabled.";
        case 134: return "Not enough money.";
        case 135: return "Price changed.";
        case 136: return "Off quotes.";
        case 137: return "Broker is busy.";
        case 138: return "Requote.";
        case 139: return "Order is locked.";
        case 140: return "Long positions only allowed.";
        case 141: return "Too many requests.";
        case 142: return "Order or position frozen.";
        case 143: return "Invalid order filling type.";
        case 144: return "Unknown symbol.";
        default: return "Unknown error.";
    }
}


//--------------------------------------------------------------------
bool RectLabelCreate(const long chart_ID = 0, // ID графика
    const string name = "RectLabel", // имя метки
    const int sub_window = 0, // номер подокна
    const long x = 0, // координата по оси X
    const long y = 0, // координата по оси y
    const int width = 50, // ширина
    const int height = 18, // высота
    const color back_clr = clrWhite, // цвет фона
    const color clr = clrBlack, // цвет плоской границы (Flat)
    const ENUM_LINE_STYLE style = STYLE_SOLID, // стиль плоской границы
    const int line_width = 1, // толщина плоской границы
    const bool back = false, // на заднем плане
    const bool selection = false, // выделить для перемещений
    const bool hidden = true, // скрыт в списке объектов
    const long z_order = 0) // приоритет на нажатие мышью
{
    ResetLastError();
    if (ObjectFind(chart_ID, name) == -1) {
        ObjectCreate(chart_ID, name, OBJ_RECTANGLE_LABEL, sub_window, 0, 0);
        ObjectSetInteger(chart_ID, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, CORNER_RIGHT_UPPER);
        ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
        ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, line_width);
        ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
        ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
        ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
        ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
        ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
        // ObjectSetInteger(chart_ID,name,OBJPROP_ALIGN,ALIGN_RIGHT); 
    }
    ObjectSetInteger(chart_ID, name, OBJPROP_BGCOLOR, back_clr);
    ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width);
    ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height);
    ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x);
    ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y);
    return (true);
}
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const string name = "HLine", // line name 
    double price = 0 // line price 
) // priority for mouse click 
{
    //--- reset the error value 
    ResetLastError();
    //--- create a horizontal line 
    if (!ObjectCreate(0, name, OBJ_HLINE, 0, 0, price)) {
        Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ", GetLastError());
        return (false);
    }
    //--- set line color 
    ObjectSetInteger(0, name, OBJPROP_COLOR, clrYellow);
    //--- set line display style 
    ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
    //--- successful execution 
    return (true);
}

//+------------------------------------------------------------------+ 
string Text(bool P, string c, string d) {
    if (P) return (d);
    else return (c);
}
