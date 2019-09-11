/**
 * @copyright   2019, pipbolt.io
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

//--- Include some constants
#include <PipboltFramework\Constants.mqh>

#define NAME "Moving Average EA"
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
input string Moving_Average = "----------";           // ---------- Moving Average ----------
input int ma_period = 10;                             // Period
int ma_shift = 0;                                     // Shift
input ENUM_MA_METHOD ma_method = MODE_SMA;            // Method
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE; // Applied Price

#include <PipboltFramework\Params\MaFilter.mqh>
#include <PipboltFramework\Params\BreakEven.mqh>
#include <PipboltFramework\Params\TrailingStop.mqh>
#include <PipboltFramework\Params\TimeFilter.mqh>

//-- Indicators
CiMA MA;
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
  MA.Init(ma_period, ma_shift, ma_method, applied_price);

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
  // Close prices
  double close0 = iClose(NULL, NULL, _indicatorShift + 0);
  double close1 = iClose(NULL, NULL, _indicatorShift + 1);

  // Buy Entry Strategy
  bool openBuy = (close0 > MA.Main(0) && close1 <= MA.Main(1));

  // Sell Entry Strategy
  bool openSell = (close0 < MA.Main(0) && close1 >= MA.Main(1));

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
  // Close price
  double close0 = iClose(NULL, NULL, _indicatorShift + 0);

  // Buy Exit Strategy
  bool closeBuy = (close0 < MA.Main(0));

  // Sell Exit Strategy
  bool closeSell = (close0 > MA.Main(0));

  // Close Positions
  Main.CloseByExitStrategy(closeBuy, closeSell);
}
//+------------------------------------------------------------------+
