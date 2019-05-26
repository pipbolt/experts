//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
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
input string Stochastic_Oscillator = "----------"; // ---------- Stochastic Oscillator ----------
input int Stoch_KPeriod = 10;                      // %K Period
input int Stoch_DPeriod = 3;                       // %D Period
input int Stoch_Slowing = 3;                       // Slowing
input ENUM_MA_METHOD Stoch_Method = MODE_SMA;      // Method
input ENUM_STO_PRICE Stoch_Price = STO_LOWHIGH;    // Price
input int Stoch_Buy_Level = 20;                    // Buy Level
input int Stoch_Sell_Level = 80;                   // Sell Level

#include <PipboltFramework\Params\BreakEven.mqh>
#include <PipboltFramework\Params\TrailingStop.mqh>
#include <PipboltFramework\Params\TimeFilter.mqh>

//-- Indicators
CiStochastic Stoch;
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
  Stoch.Init(NULL, NULL, Stoch_KPeriod, Stoch_DPeriod, Stoch_Slowing, Stoch_Method, Stoch_Price);

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

  // Buy Entry Strategy
  if (Stoch.Signal(1) <= Stoch_Buy_Level && Stoch.Main(1) <= Stoch.Signal(1) &&
      Stoch.Main(0) <= Stoch_Buy_Level && Stoch.Signal(0) <= Stoch.Main(0))
    openBuy = true;

  // Sell Entry Strategy
  else if (Stoch.Signal(1) >= Stoch_Sell_Level && Stoch.Main(1) >= Stoch.Signal(1) &&
           Stoch.Main(0) >= Stoch_Sell_Level && Stoch.Signal(0) >= Stoch.Main(0))
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

  // Buy Exit Strategy
  closeBuy = (Stoch.Main(0) >= Stoch_Sell_Level);

  // Sell Exit Strategy
  closeSell = (Stoch.Main(0) <= Stoch_Buy_Level);

  // Close Positions
  Main.CloseByExitStrategy(closeBuy, closeSell);
}
//+------------------------------------------------------------------+
