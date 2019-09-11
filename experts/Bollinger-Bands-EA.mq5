/**
 * @copyright   2019, pipbolt.io
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

//--- Include some constants
#include <PipboltFramework\Constants.mqh>

#define NAME "Bollinger Bands EA"
#define VERSION "0.008"

#property copyright COPYRIGHT
#property link LINK
#property icon ICON
#property description DESCRIPTION
#property version VERSION

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

#include <PipboltFramework\Params\MaFilter.mqh>
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

  // Init Functions
  InitMainSettings();
  InitMaFilter();
  InitTrailingStop(MagicNumber);
  InitBreakEven(MagicNumber);
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
  Main.Deinit();
}
//+------------------------------------------------------------------+
//| Expert timer function                                            |
//+------------------------------------------------------------------+
void OnTimer()
{
  Main.Timer();
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
  closeBuy = (close > BBands.Upper(0));

  // Sell Exit Strategy
  closeSell = close < BBands.Lower(0);

  // Close Positions
  Main.CloseByExitStrategy(closeBuy, closeSell);
}
//+------------------------------------------------------------------+
