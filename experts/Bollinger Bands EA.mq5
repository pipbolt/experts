/**
 * @copyright 	2019, pipbolt.io
 * @license	    https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#property copyright "Copyright 2019, pipbolt.io"
#property link "https://pipbolt.io"
#property icon "/include/PipboltFramework/favicon.ico"
#property description "Visit pipbolt.io for more EAs for Metatrader 5."
#property version "0.001"

//--- Include the main functions
#include <PipboltFramework\Params\MainSettings.mqh>

//--- Entry Strategy
input string Entry_Strategy = "----------"; // ---------- Entry Strategy ----------

//--- Exit Strategy
input string Exit_Strategy = "----------"; // ---------- Exit Strategy ----------
input bool UseExitStrategy = false;        // Use Exit Strategy

//--- Indicator Settings
input string Bollinger_Bands = "----------";                // ---------- Bollinber Bands ----------
input int Bands_Period = 20;                                // Period
input double Bands_Deviation = 2;                           // Deviation
input ENUM_APPLIED_PRICE Bands_Applied_Price = PRICE_CLOSE; // Applied Price

#include <PipboltFramework\Params\BreakEven.mqh>
#include <PipboltFramework\Params\TrailingStop.mqh>
#include <PipboltFramework\Params\TimeFilter.mqh>

//-- Indicators
CiBollinger BBands;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
{
  // Checks
  if (!cLicense.CheckLicense() || !Main.OnInitChecks())
    return (INIT_FAILED);

  // Init Main Functions
  InitMainSettings();

  // Init TrailingStop
  InitTrailingStop(MagicNumber);

  // Init BreakEven
  InitBreakEven(MagicNumber);

  // Init Timer Filter
  InitTimerFilter(MagicNumber);

  // Indicators
  BBands.Init(NULL, NULL, Bands_Period, 0, Bands_Deviation, Bands_Applied_Price);

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

  // Define bool
  bool openBuy = false, openSell = false;

  // Close variable
  double close = iClose(NULL, NULL, _indicatorShift);

  // Buy Entry Strategy
  if (close < BBands.Lower(0))
    openBuy = true;

  // Sell Entry Strategy
  else if (close > BBands.Upper(0))
    openSell = true;

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
  closeBuy = (close > BBands.Upper(0));

  // Sell Exit Strategy
  closeSell = close < BBands.Lower(0);

  // Close Positions
  Main.CloseByExitStrategy(closeBuy, closeSell);
}
//+------------------------------------------------------------------+
