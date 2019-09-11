/**
 * @copyright   2019, pipbolt.io
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#property copyright "Copyright 2019, pipbolt.io"
#property link "https://pipbolt.io"
#property icon "/include/PipboltFramework/favicon.ico"
#property description "Visit pipbolt.io for more EAs for Metatrader 5."
#property version "0.008"

//--- Include the main functions
#include <PipboltFramework\Params\MainSettings.mqh>

//--- Entry Strategy
input string Entry_Strategy = "----------"; // ---------- Entry Strategy ----------

//--- Exit Strategy
input string Exit_Strategy = "----------"; // ---------- Exit Strategy ----------
input bool UseExitStrategy = false;        // Use Exit Strategy

//--- Indicator Settings
input string Relative_Strength_Index = "----------";      // ---------- Relative Strength Index ----------
input int RSI_Period = 14;                                // Period
input ENUM_APPLIED_PRICE RSI_Applied_Price = PRICE_CLOSE; // Applied Price
input int RSI_Buy_Level = 30;                             // Buy Level
input int RSI_Sell_Level = 70;                            // Sell Level

#include <PipboltFramework\Params\MaFilter.mqh>
#include <PipboltFramework\Params\BreakEven.mqh>
#include <PipboltFramework\Params\TrailingStop.mqh>
#include <PipboltFramework\Params\TimeFilter.mqh>

//-- Indicators
CiRSI RSI;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
{
  // Checks
  if (!cLicense.CheckLicense() || !Main.OnInitChecks())
    return (INIT_FAILED);

  // Init Functions
  InitMainSettings();
  InitMaFilter();
  InitTrailingStop(MagicNumber);
  InitBreakEven(MagicNumber);
  InitTimerFilter(MagicNumber);

  // Indicators
  RSI.Init(NULL, NULL, RSI_Period, RSI_Applied_Price);

  //--- ok
  return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(void)
{

  // Checks and Updates
  if (!Main.OnTickChecksAndUpdates())
    return;

  //Execute only if a open position exists
  if (Main.PositionExists())
  {
    cTrailingStop.Trail();
    cBreakEven.Trail();
    cTimeFilter.ExitOnTimer();

    if (UseExitStrategy && Main.IsNewBar())
      CheckForClose();
  }

  // Execute only on a new bar
  if (Main.NewPositionAllowed() && cTimeFilter.TimeFilter() && Main.IsNewBar())
    CheckForOpen();
}
//+------------------------------------------------------------------+
//| Check for open position conditions                               |
//+------------------------------------------------------------------+
void CheckForOpen(void)
{
  // Buy Entry Strategy
  bool openBuy = (RSI.Main(0) <= RSI_Buy_Level && RSI.Main(1) > RSI_Buy_Level);

  // Sell Entry Strategy
  bool openSell = (RSI.Main(0) >= RSI_Sell_Level && RSI.Main(1) < RSI_Sell_Level);

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);

  // Open Positions
  Main.OpenByEntryStrategy(openBuy, openSell);
}
//+------------------------------------------------------------------+
//| Check for close position conditions                              |
//+------------------------------------------------------------------+
void CheckForClose(void)
{
  // Define bool
  bool closeBuy = false, closeSell = false;

  // Close variable
  double close = iClose(NULL, NULL, _indicatorShift);

  // Buy Exit Strategy
  closeBuy = RSI.Main(0) > RSI_Sell_Level;

  // Sell Exit Strategy
  closeSell = (RSI.Main(0) < RSI_Buy_Level);

  // Close Positions
  Main.CloseByExitStrategy(closeBuy, closeSell);
}
//+------------------------------------------------------------------+
