/**
 * @copyright   2019, pipbolt.io <beta@pipbolt.io>
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "Stochastic Oscillator EA"
#define VERSION "0.021"

#property copyright COPYRIGHT
#property link LINK
#property icon ICON
#property description DESCRIPTION
#property version VERSION

#include <PipboltFramework\Params\MainSettings.mqh>

input group "Entry Strategy";

input group "Exit Strategy";
input bool UseExitStrategy = false; // Use Exit Strategy

input group "Stochastic Oscillator";
input int Stoch_KPeriod = 5;                    // %K Period
input int Stoch_DPeriod = 3;                    // %D Period
input int Stoch_Slowing = 3;                    // Slowing
input ENUM_MA_METHOD Stoch_Method = MODE_SMA;   // Method
input ENUM_STO_PRICE Stoch_Price = STO_LOWHIGH; // Price
input int Stoch_Buy_Level = 20;                 // Buy Level
input int Stoch_Sell_Level = 80;                // Sell Level

#include <PipboltFramework\Experts.mqh>

CiStochastic Stoch;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  Stoch.Init(NULL, NULL, Stoch_KPeriod, Stoch_DPeriod, Stoch_Slowing, Stoch_Method, Stoch_Price);

  return INIT_SUCCEEDED;
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Buy Entry Strategy
  if (Stoch.Signal(1) <= Stoch_Buy_Level && Stoch.Main(1) <= Stoch.Signal(1) &&
      Stoch.Main(0) <= Stoch_Buy_Level && Stoch.Signal(0) <= Stoch.Main(0))
    openBuy = true;

  // Sell Entry Strategy
  else if (Stoch.Signal(1) >= Stoch_Sell_Level && Stoch.Main(1) >= Stoch.Signal(1) &&
           Stoch.Main(0) >= Stoch_Sell_Level && Stoch.Signal(0) >= Stoch.Main(0))
    openSell = true;

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Buy Exit Strategy
  closeBuy = (Stoch.Main(0) >= Stoch_Sell_Level);

  // Sell Exit Strategy
  closeSell = (Stoch.Main(0) <= Stoch_Buy_Level);
}