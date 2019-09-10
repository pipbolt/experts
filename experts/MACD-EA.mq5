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
sinput string Entry_Strategy = "----------"; // ---------- Entry Strategy ----------

//--- Exit Strategy
sinput string Exit_Strategy = "----------"; // ---------- Exit Strategy ----------
input bool UseExitStrategy = false;         // Use Exit Strategy

//--- Indicator Settings
sinput string MACDSettings = "----------";        // ---------- MACD ----------
input int MACDFastPeriod = 12;                    // Fast Period
input int MACDSlowPeriod = 26;                    // Slow Period
input int MACDSignalPeriod = 9;                   // Signal Period
input ENUM_APPLIED_PRICE MACDPrice = PRICE_CLOSE; // Applied Price

#include <PipboltFramework\Params\MaFilter.mqh>
#include <PipboltFramework\Params\BreakEven.mqh>
#include <PipboltFramework\Params\TrailingStop.mqh>
#include <PipboltFramework\Params\TimeFilter.mqh>

//-- Indicators
CiMACD MACD;
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
  MACD.Init(NULL, NULL, MACDFastPeriod, MACDSlowPeriod, MACDSignalPeriod, MACDPrice);

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
  bool openBuy = (MACD.Main(0) <= 0 && MACD.Signal(0) < MACD.Main(0) && MACD.Signal(1) >= MACD.Main(1));

  // Sell Entry Strategy
  bool openSell = (MACD.Main(0) >= 0 && MACD.Signal(0) > MACD.Main(0) && MACD.Signal(1) <= MACD.Main(1));

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
  // Buy Exit Strategy
  bool closeBuy = (MACD.Signal(0) > MACD.Main(0));

  // Sell Exit Strategy
  bool closeSell = (MACD.Signal(0) < MACD.Main(0));

  // Close Positions
  Main.CloseByExitStrategy(closeBuy, closeSell);
}
//+------------------------------------------------------------------+
