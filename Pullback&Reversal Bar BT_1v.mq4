//+------------------------------------------------------------------+
//|                                      Custom Indicator for MT4    |
//|                                                                  |
//|               Identifies Reversal Bars and Pullbacks             |
//+------------------------------------------------------------------+
#property copyright "Zdeno Brontvay"
#property link      "http://www.metaquotes.net"
#property version   "1.00"
#property indicator_chart_window
#include <stdlib.mqh>

//+------------------------------------------------------------------+
//| External variables                                               |
//+------------------------------------------------------------------+
extern double MATrendPeriod = 60;
extern int SDL_Period = 32;
extern int SDL_MA_Method = MODE_EMA; // MODE_EMA, MODE_SMA, etc.
extern int SDL_Applied_Price = PRICE_CLOSE; // PRICE_CLOSE, PRICE_OPEN, etc.
extern int RSI_Period = 14; // Typical period for RSI

extern string             button_note1          = "------------------------------";
extern int                btn_Subwindow = 0;
extern ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_UPPER; 
extern string             btn_text              = "Toggle Display";
extern string             btn_Font              = "Arial";
extern int                btn_FontSize          = 10;                            
extern color              btn_text_ON_color     = clrLime;
extern color              btn_text_OFF_color    = clrRed;
extern string             btn_pressed           = "Pullback";            
extern string             btn_unpressed         = "Pullback";
extern color              btn_background_color  = clrDimGray;
extern color              btn_border_color      = clrBlack;
extern int                button_x              = 850;                                 
extern int                button_y              = 20;                                   
extern int                btn_Width             = 90 ;                                 
extern int                btn_Height            = 20;                                
extern string             soundBT               = "tick.wav";  
extern string             button_note2          = "------------------------------";

bool                      show_data             = true;
string IndicatorName, IndicatorObjPrefix, buttonId;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double BuySignalBuffer[];
double SellSignalBuffer[];
double SDL_LineBuffer[];
double SDL_SlopeBuffer[];
double RSI_Buffer[];

//+------------------------------------------------------------------+
//| DrawArrow function                                               |
//+------------------------------------------------------------------+
void DrawArrow(string name, int index, double price, color clr, int arrowCode)
{
   if(!ObjectCreate(0, name, OBJ_ARROW, 0, Time[index], price))
      Print("Error creating arrow object: ", GetLastError());
   else
   {
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrowCode);
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0, BuySignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SellSignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, SDL_LineBuffer);
   SetIndexBuffer(3, SDL_SlopeBuffer);
   SetIndexBuffer(4, RSI_Buffer);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_HISTOGRAM);
   //--- set index arrow codes for pullbacks
   PlotIndexSetInteger(0, PLOT_ARROW, 241); // Blue arrow for Buy pullback
   PlotIndexSetInteger(1, PLOT_ARROW, 242); // Red arrow for Sell pullback
   //--- set index arrow codes for reversal bars
   PlotIndexSetInteger(0, PLOT_ARROW, 233); // Blue arrow for Buy reversal
   PlotIndexSetInteger(1, PLOT_ARROW, 234); // Red arrow for Sell reversal
   //--- set index styles
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, 5); // Shift for Buy arrow
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -5); // Shift for Sell arrow

   // Initialize button
   IndicatorName = GenerateIndicatorName(btn_text);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   buttonId = IndicatorObjPrefix + btn_text;
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);

   double val;
   if (GlobalVariableGet(IndicatorName + "_visibility", val))
       show_data = val != 0;

   ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, 1);
   buttonId = IndicatorObjPrefix+btn_text;
   createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_ON_color);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_YDISTANCE, button_y);
   ObjectSetInteger(ChartID(), buttonId, OBJPROP_XDISTANCE, button_x);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom Indicator Deinitialization Function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0,"Pullback");
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}

//+------------------------------------------------------------------+
//| Custom Indicator Iteration Function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // Fetch and display economic data based on symbol
    FetchEconomicData(Symbol());
    
    //--- calculate the number of bars to calculate
    int bars_to_calculate = rates_total - prev_calculated;
    
    //--- additional variables for trend, volatility, and pivot calculations
    double trendStrength[];
    double volatility[];
    double pivot, resistance, support;
    
    //--- main calculation loop
    if (show_data) {
        for(int j = 0; j < bars_to_calculate; j++)
        {
            int i = rates_total - j - 1; // Calculate from the most recent bar
            // Calculate trend strength and volatility here
            trendStrength[i] = iADX(_Symbol, _Period, 14, PRICE_CLOSE, MODE_MAIN, i);
            volatility[i] = iATR(_Symbol, _Period, 14, i);
            
            // SDL calculation
            SDL_LineBuffer[i] = iMA(_Symbol, _Period, SDL_Period, 0, SDL_MA_Method, SDL_Applied_Price, i);
            if(i < 1) continue; // Skip the first bar
            SDL_SlopeBuffer[i] = SDL_LineBuffer[i] - SDL_LineBuffer[i-1];
            
            // RSI calculation
            RSI_Buffer[i] = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE, i);
            
            // Calculate pivot points, support, and resistance at the beginning of European (8-13) and American (14-20) sessions
            int hour = TimeHour(time[i]);
            if((hour >= 8 && hour < 13) || (hour >= 14 && hour < 20))
            {
                // Calculate the pivot points using the high, low, and close of the previous period
                pivot = (high[i] + low[i] + close[i]) / 3;
                resistance = pivot + (high[i] - low[i]);
                support = pivot - (high[i] - low[i]);
            }
            
            // Pullback and reversal identification logic
            double maCurrent = iMA(_Symbol, _Period, MATrendPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
            double maPrevious = iMA(_Symbol, _Period, MATrendPeriod, 0, MODE_EMA, PRICE_CLOSE, i+1);

            // Now include checks for trend, volatility, RSI, and pivot levels before drawing arrows
            if(trendStrength[i] > 25 && volatility[i] < 50 && RSI_Buffer[i] > 30 && RSI_Buffer[i] < 70)
            {
                // Check for pullback buy
                if( close[i] > open[i] && close[i] > maCurrent && maCurrent > maPrevious && close[i] > support && close[i] < resistance)
                {
                    // Draw a blue arrow for a pullback buy
                    DrawArrow("BuyPullbackArrow"+IntegerToString(i), i, high[i] + 5*Point, clrBlue, 241);
                }
                // Check for reversal buy
                else if( Low[i] < Low[i+1] && High[i] < High[i+1] &&
                    Low[i] < Low[i+1] && High[i] < High[i+1] && 
                    Close[i] > Open[i] && maCurrent > maPrevious && close[i] > support && close[i] < resistance) 
                {
                    // Draw a blue arrow for a reversal buy
                    DrawArrow("BuyReversalArrow"+IntegerToString(i), i, high[i] + 5*Point, clrBlue, 233);
                }
                
                // Check for pullback sell
                if( close[i] < open[i] && close[i] < maCurrent && maCurrent < maPrevious && close[i] < resistance && close[i] > support)
                {
                    // Draw a red arrow for a pullback sell
                    DrawArrow("SellPullbackArrow"+IntegerToString(i), i, low[i] - 5*Point, clrRed, 242);
                }
                // Check for reversal sell
                else if( Low[i] > Low[i+1] && High[i] > High[i+1] && 
                    Low[i] > Low[i+1] && High[i] > High[i+1] && 
                    Close[i] < Open[i] && maCurrent < maPrevious && close[i] < resistance && close[i] > support) 
                {
                    // Draw a red arrow for a reversal sell
                    DrawArrow("SellReversalArrow"+IntegerToString(i), i, low[i] - 5*Point, clrRed, 234);
                }
            }
        }
    } else {
        // Clear the arrows if show_data is false
        for (int k = 0; k < rates_total; k++) {
            ObjectDelete("BuyPullbackArrow" + IntegerToString(k));
            ObjectDelete("BuyReversalArrow" + IntegerToString(k));
            ObjectDelete("SellPullbackArrow" + IntegerToString(k));
            ObjectDelete("SellReversalArrow" + IntegerToString(k));
        }
    }

    return(rates_total);
}

//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
    handleButtonClicks();
    if (id == CHARTEVENT_OBJECT_CLICK && ObjectGet(sparam, OBJPROP_TYPE) == OBJ_BUTTON) {
        if (soundBT != "") PlaySound(soundBT);
    }
}

//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
{
    string name = target;
    int try = 2;
    while (WindowFind(name) != -1) {
        name = target + " #" + IntegerToString(try++);
    }
    return name;
}

void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
{
    ObjectDelete(ChartID(), buttonID);
    ObjectCreate(ChartID(), buttonID, OBJ_BUTTON, btn_Subwindow, 0, 0);
    ObjectSetInteger(ChartID(), buttonID, OBJPROP_COLOR, txtColor);
    ObjectSetInteger(ChartID(), buttonID, OBJPROP_BGCOLOR, bgColor);
    ObjectSetInteger(ChartID(), buttonID, OBJPROP_BORDER_COLOR, borderColor);
    ObjectSetInteger(ChartID(), buttonID, OBJPROP_XSIZE, width);
    ObjectSetInteger(ChartID(), buttonID, OBJPROP_YSIZE, height);
    ObjectSetString(ChartID(), buttonID, OBJPROP_FONT, font);
    ObjectSetString(ChartID(), buttonID, OBJPROP_TEXT, buttonText);
    ObjectSetInteger(ChartID(), buttonID, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(ChartID(), buttonID, OBJPROP_SELECTABLE, 0);
    ObjectSetInteger(ChartID(), buttonID, OBJPROP_CORNER, btn_corner);
}

void handleButtonClicks()
{
    if (ObjectGetInteger(ChartID(), buttonId, OBJPROP_STATE)) {
        ObjectSetInteger(ChartID(), buttonId, OBJPROP_STATE, false);
        show_data = !show_data;
        GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
        
        if (show_data) {
            ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_ON_color);
            ObjectSetString(ChartID(), buttonId, OBJPROP_TEXT, btn_unpressed);
        } else {
            ObjectSetInteger(ChartID(), buttonId, OBJPROP_COLOR, btn_text_OFF_color);
            ObjectSetString(ChartID(), buttonId, OBJPROP_TEXT, btn_pressed);
        }
    }
}
