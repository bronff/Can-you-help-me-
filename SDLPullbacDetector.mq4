//+------------------------------------------------------------------+
//|                                          SDLPullbackDetector.mq4 |
//|                                   Copyright 2024, Zdeno Brontvay |
//|                                                                  |
//+------------------------------------------------------------------+

#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Orange
#property indicator_color4 Blue
#property indicator_color5 DarkOrange

//--- input parameters
extern int Stochastic_Period = 14;
extern double Overbought_Level = 80.0;
extern double Oversold_Level = 20.0;
extern int VQ_Length = 9; // Length for VQ indicator
extern double VQ_Threshold = 0.0005; // Threshold for VQ indicator
extern int SDL_Period = 32;
extern double SDL_FilterNumber = 2;
extern int SDL_Method = 3;
extern int SDL_Applied_Price = 0;

//--- buffers
double UpArrowBuffer[];
double DownArrowBuffer[];
double VQBuffer[];
double SDL_Buffer[];
double StochBuffer[];
double B0[];
double B1[];
double K[];
double D[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    SetIndexStyle(0, DRAW_ARROW);
    SetIndexArrow(0, 233); // Up arrow symbol
    SetIndexBuffer(0, UpArrowBuffer);

    SetIndexStyle(1, DRAW_ARROW);
    SetIndexArrow(1, 234); // Down arrow symbol
    SetIndexBuffer(1, DownArrowBuffer);

    SetIndexBuffer(2, VQBuffer); // Buffer for VQ indicator
    SetIndexBuffer(3, SDL_Buffer); // Buffer for SDL indicator
    SetIndexBuffer(4, StochBuffer); // Buffer for Stochastic
    SetIndexBuffer(5, B0);
    SetIndexBuffer(6, B1);
    SetIndexBuffer(7, K);
    SetIndexBuffer(8, D);

    ArraySetAsSeries(UpArrowBuffer, true);
    ArraySetAsSeries(DownArrowBuffer, true);
    ArraySetAsSeries(VQBuffer, true);
    ArraySetAsSeries(SDL_Buffer, true);
    ArraySetAsSeries(StochBuffer, true);
    ArraySetAsSeries(B0, true);
    ArraySetAsSeries(B1, true);
    ArraySetAsSeries(K, true);
    ArraySetAsSeries(D, true);

    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
    int begin = MathMax(MathMax(Stochastic_Period, (int)MathSqrt(SDL_Period) + SDL_Period + 1), VQ_Length);
    if (rates_total < begin) return(0);

    int limit = rates_total - begin;

    // Calculate SDL
    for (int i = limit; i >= 0; i--) {
        B0[i] = 2 * MA(i, (int)MathRound((double)SDL_Period / SDL_FilterNumber)) - MA(i, SDL_Period);
    }

    for (int i = limit; i >= 0; i--) {
        B1[i] = iMAOnArray(B0, rates_total, (int)MathRound(MathSqrt(SDL_Period)), 0, SDL_Method, i);
    }

    for (int i = limit; i >= 1; i--) {
        SDL_Buffer[i] = (B1[i] > B1[i - 1]) ? B1[i] : EMPTY_VALUE;
    }

    // Calculate Stochastic
    for (int i = 0; i <= rates_total - Stochastic_Period; i++) {
        double highestHigh = high[iHighest(NULL, 0, MODE_HIGH, Stochastic_Period, i)];
        double lowestLow = low[iLowest(NULL, 0, MODE_LOW, Stochastic_Period, i)];
        K[i] = 100 * (close[i] - lowestLow) / (highestHigh - lowestLow);
    }

    for (int i = 0; i <= rates_total - 3; i++) {
        D[i] = iMAOnArray(K, rates_total, 3, 0, MODE_SMA, i);
    }

    for (int i = 0; i < rates_total; i++) {
        StochBuffer[i] = D[i];
    }

    // Calculate VQ
    for (int i = 0; i <= rates_total - VQ_Length; i++) {
        VQBuffer[i] = MathAbs(close[i] - close[i + VQ_Length]);
    }

    int upPullbackDetected = -1;
    int downPullbackDetected = -1;

    for (int i = prev_calculated - 1; i < rates_total - begin; i++) {
        if (i < 0 || i >= rates_total) continue;  // Boundary check
        double stochasticCurrent = StochBuffer[i];
        double vqCurrent = VQBuffer[i];

        // Dynamic pullback candles calculation based on VQ
        int dynamicPullbackCandles = CalculateDynamicPullbackCandles(vqCurrent);

        // Detect uptrend pullback for long positions
        if (i + 1 < rates_total && SDL_Buffer[i] != EMPTY_VALUE && SDL_Buffer[i] > SDL_Buffer[i + 1] && upPullbackDetected < 0) {
            if (IsPullbackUp(close, rates_total, i, dynamicPullbackCandles)) {
                UpArrowBuffer[i] = low[i] - (4 * Point);
                upPullbackDetected = i;
            }
        }

        // Detect downtrend pullback for short positions
        if (i + 1 < rates_total && SDL_Buffer[i] != EMPTY_VALUE && SDL_Buffer[i] < SDL_Buffer[i + 1] && downPullbackDetected < 0) {
            if (IsPullbackDown(close, rates_total, i, dynamicPullbackCandles)) {
                DownArrowBuffer[i] = high[i] + (4 * Point);
                downPullbackDetected = i;
            }
        }

        // VQBuffer is used to display the VQ indicator value
        VQBuffer[i] = vqCurrent;
    }

    return(rates_total);
}

// Function to calculate dynamic number of pullback candles
int CalculateDynamicPullbackCandles(double vqCurrent) {
    if (vqCurrent < VQ_Threshold) {
        return 1; // Lower volatility, smaller number of candles
    } else if (vqCurrent < VQ_Threshold * 2) {
        return 2; // Medium volatility, medium number of candles
    } else {
        return 3; // Higher volatility, larger number of candles
    }
}

// Function to calculate MA
double MA(int shift, int p) {
    if (shift < 0 || shift >= Bars) return 0;  // Boundary check
    return (iMA(NULL, 0, p, 0, SDL_Method, SDL_Applied_Price, shift));
}

// Function to detect upward pullback
bool IsPullbackUp(const double &close[], int rates_total, int index, int pullbackCandles) {
    bool isPullback = true;
    for (int j = 1; j <= pullbackCandles && index + j < rates_total; j++) {
        if (index + j < 0 || index + j >= rates_total) continue;  // Boundary check
        if (close[index + j] > close[index + j - 1]) {
            isPullback = false;
            break;
        }
    }
    return isPullback;
}

// Function to detect downward pullback
bool IsPullbackDown(const double &close[], int rates_total, int index, int pullbackCandles) {
    bool isPullback = true;
    for (int j = 1; j <= pullbackCandles && index + j < rates_total; j++) {
        if (index + j < 0 || index + j >= rates_total) continue;  // Boundary check
        if (close[index + j] < close[index + j - 1]) {
            isPullback = false;
            break;
        }
    }
    return isPullback;
}
