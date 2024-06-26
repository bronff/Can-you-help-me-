//+------------------------------------------------------------------+
//|                                                 R insurer en MQ4 |
//|            Zatvára všetky príkazy pri určitom zisku              |
//+------------------------------------------------------------------+

#property description "The advisor places opposite stop orders at a distance delta from the most losing order of a certain volume. After their activation and achieving profit of orders, the advisor closes all order positions."
#property strict

extern double PercentProfitClose = 0.001;   // Close all orders when a profit in percentage of the deposit is reached
extern double Lot                = 0.50;    // Size of the insurance stop order
extern int    delta              = 25;      // Distance from the order ceiling from the extreme position
extern int    TrailingStep       = 1;       // Trailing stop stepping

extern int    MaxLossOrders      = 1;       // Maximum number of losing orders
extern int    MaxPendingOrders   = 3;       // Maximum number of pending orders

double MaxLoss = 0;                         // Maximum loss
double LossOrderPrice = 0;                  // Price of the order with the largest loss
int    LossOrderType = -1;                  // Type of order with the largest loss
// Global variables for tracking losing positions
int lossOrderTickets[];

int start()
{
   double Profit = 0;
   double CurrentLoss = 0;
   int LossOrdersCount = 0;
   ArrayResize(lossOrderTickets, MaxLossOrders); // Set the array size to the maximum number of losing order contracts.

   // Prehodnoťte všetky obchody a nájdite najstratovejšie do limitu MaxLossOrders
   for (int i = OrdersTotal() - 1; i >= 0 && LossOrdersCount < MaxLossOrders; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol())
      {
         CurrentLoss = OrderProfit();
         Profit += CurrentLoss;
         if (CurrentLoss < 0)
         {
            lossOrderTickets[LossOrdersCount] = OrderTicket(); // Save the ticket of the losing order
            LossOrdersCount++;
         }
      }
   }

   // Only close the losing positions that have reached PercentProfitClose
   if (Profit >= AccountBalance() * PercentProfitClose / 100)
   {
      for (int i = 0; i < LossOrdersCount; i++)
      {
         int ticket = lossOrderTickets[i];
         if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
         {
            double orderProfit = OrderProfit();
            double orderProfitPercent = orderProfit / AccountBalance() * 100;
            
            if (orderProfitPercent >= PercentProfitClose)
            {
               int orderType = OrderType();
               if (orderType == OP_BUY || orderType == OP_SELL)
               {
                  // Zatvorenie obchodnej pozície
                  bool result = OrderClose(ticket, OrderLots(), (orderType == OP_BUY) ? Bid : Ask, 3, Violet);
                  if(!result)
                  {
                     Print("OrderClose failed with error ", GetLastError());
                  }
               }
            }
         }
      }
   }
   
   if (Profit >= AccountBalance() / 100 * PercentProfitClose)
   {
      CloseAll();
   }

   if (LossOrderType != -1)
   {
      if (LossOrderType == OP_BUY)
      {
         ModifyPendingOrder(OP_SELLSTOP, LossOrderPrice - delta * Point);
      }
      else if (LossOrderType == OP_SELL)
      {
         ModifyPendingOrder(OP_BUYSTOP, LossOrderPrice + delta * Point);
      }
   }

   return(0);
}

void ModifyPendingOrder(int orderType, double price)
{
   int ticket = -1;
   int pendingOrdersCount = 0;

   // Spočítajte existujúce pending ordery
   for (int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES) && OrderSymbol() == Symbol() && OrderType() == orderType)
      {
         pendingOrdersCount++;
         if (pendingOrdersCount >= MaxPendingOrders)
         {
            return; // If we already have the maximum number of pending orders, we don’t add any more
         }
         ticket = OrderTicket();
      }
   }

   // If there are none or few pending orders, open a new one
   if (pendingOrdersCount < MaxPendingOrders)
   {
      int result = OrderSend(Symbol(), orderType, Lot, NormalizeDouble(price, Digits), 30, 0, 0, NULL, 0, 0, (orderType == OP_BUYSTOP) ? Blue : Red);
      if(result < 0)
      {
         Print("OrderSend failed with error ", GetLastError());
      }
   }
   else if (ticket != -1)
   {
      // If a pending order already exists, adjust it.
      if (MathAbs(OrderOpenPrice() - price) >= TrailingStep * Point)
      {
         bool result = OrderModify(ticket, NormalizeDouble(price, Digits), 0, 0, 0, (orderType == OP_BUYSTOP) ? Blue : Red);
         if(!result)
         {
            Print("OrderModify failed with error ", GetLastError());
         }
      }
   }
}

void CloseAll()
{
   for(int i=OrdersTotal()-1; i>=0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol())
         {
            if(OrderType() == OP_BUY || OrderType() == OP_SELL)
            {
               bool result = OrderClose(OrderTicket(), OrderLots(), (OrderType() == OP_BUY) ? Bid : Ask, 3, clrNONE);
               if(!result)
               {
                  Print("OrderClose failed with error ", GetLastError());
               }
            }
         }
      }
   }
}
