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
input string   Parabolic_SAR="----------";      // ---------- Parabolic SAR ----------
input double   PSAR_Step=0.02;                  // Step
input double   PSAR_Maximum=0.2;                // Maximum

#include <PipboltFramework\Params\BreakEven.mqh>
#include <PipboltFramework\Params\TrailingStop.mqh>
#include <PipboltFramework\Params\TimeFilter.mqh>

//-- Indicators 
CiSAR PSAR;
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
   PSAR.Init(NULL,NULL,PSAR_Step,PSAR_Maximum);

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

   double close0 = iClose(NULL,NULL,_indicatorShift);
   double close1 = iClose(NULL,NULL,_indicatorShift+1);

// Buy Entry Strategy
   if(PSAR.Main(1)>close1 && PSAR.Main(0)<close0)
      openBuy=true;

// Sell Entry Strategy
   else if(PSAR.Main(1)<close1 && PSAR.Main(0)>close0)
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

   double close0 = iClose(NULL,NULL,_indicatorShift);
   double close1 = iClose(NULL,NULL,_indicatorShift+1);

// Buy Exit Strategy
   closeBuy=(PSAR.Main(0)>close0 && PSAR.Main(1)<close1);

// Sell Exit Strategy
   closeSell=(PSAR.Main(0)<close0 && PSAR.Main(1)>close1);

// Close Positions
   Main.CloseByExitStrategy(closeBuy,closeSell);

  }
//+------------------------------------------------------------------+
