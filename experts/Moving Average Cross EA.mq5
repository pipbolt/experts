//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2019, pipbolt.io"
#property link          "https://pipbolt.io"
#property icon          "/include/PipboltFramework/favicon.ico"
#property description   "Visit pipbolt.io for more EAs for Metatrader 5."
#property version       "0.001"

//--- Include the main functions
#include <PipboltFramework\Params\MainSettings.mqh>

//--- Entry Strategy
input string   Entry_Strategy="----------";     // ---------- Entry Strategy ----------

//--- Exit Strategy
input string   Exit_Strategy="----------";      // ---------- Exit Strategy ----------
input bool     UseExitStrategy=false;           // Use Exit Strategy

//--- Indicator Settings
input string   Fast_Moving_Average="----------";// ---------- Fast Moving Average ----------
input int      MovingPeriodFast=12;             // Moving Average Period
input string   Slow_Moving_Average="----------";// ---------- Slow Moving Average ----------
input int      MovingPeriodSlow=30;             // Moving Average Period

#include <PipboltFramework\Params\BreakEven.mqh>
#include <PipboltFramework\Params\TrailingStop.mqh>
#include <PipboltFramework\Params\TimeFilter.mqh>

//-- Indicators 
CiMA MAFast;
CiMA MASlow;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(void)
  {
// Checks
   if(!cLicense.CheckLicense() || !Main.OnInitChecks())return (INIT_FAILED);

// Init Main Functions
   InitMainSettings();

// Init TrailingStop
   InitTrailingStop(MagicNumber);

// Init BreakEven
   InitBreakEven(MagicNumber);

// Init Timer Filter
   InitTimerFilter(MagicNumber);

// Indicators
   MAFast.Init(MovingPeriodFast,0,MODE_SMA,PRICE_CLOSE);
   MASlow.Init(MovingPeriodSlow,0,MODE_SMA,PRICE_CLOSE);

//--- ok
   return(INIT_SUCCEEDED);
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
   if(!Main.OnTickChecksAndUpdates())return;

//Execute only if a open position exists
   if(Main.PositionExists())
     {
      cTrailingStop.Trail();
      cBreakEven.Trail();
      cTimeFilter.ExitOnTimer();

      if(UseExitStrategy && Main.IsNewBar())
         CheckForClose();
     }

// Execute only on a new bar
   if(Main.NewPositionAllowed() && cTimeFilter.TimeFilter() && Main.IsNewBar())
      CheckForOpen();

  }
//+------------------------------------------------------------------+
//| Check for open position conditions                               |
//+------------------------------------------------------------------+
void CheckForOpen(void)
  {
// Define bool
   bool openBuy=false,openSell=false;
   
// Buy Entry Strategy
   if(MAFast.Main(1)<MASlow.Main(1) && MAFast.Main(0)>=MASlow.Main(0))
      openBuy=true;

// Sell Entry Strategy
   else if(MAFast.Main(1)>MASlow.Main(1) && MAFast.Main(0)<=MASlow.Main(0))
                                                            openSell=true;

// Open Positions
   Main.OpenByEntryStrategy(openBuy,openSell);

  }
//+------------------------------------------------------------------+
//| Check for close position conditions                              |
//+------------------------------------------------------------------+
void CheckForClose(void)
  {
// Define bool
   bool closeBuy=false,closeSell=false;

// Buy Exit Strategy
   closeBuy=(MAFast.Main(1)>MASlow.Main(1) && MAFast.Main(0)<=MASlow.Main(0));

// Sell Exit Strategy
   closeSell=(MAFast.Main(1)<MASlow.Main(1) && MAFast.Main(0)>=MASlow.Main(0));

// Close Positions
   Main.CloseByExitStrategy(closeBuy,closeSell);

  }
//+------------------------------------------------------------------+
