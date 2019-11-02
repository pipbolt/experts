/**
 * @copyright   2019, pipbolt.io
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "RSI EA (Relative Strength Index)"
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

input group "Relative Strength Index";
input int RSI_Period = 14;                                // Period
input ENUM_APPLIED_PRICE RSI_Applied_Price = PRICE_CLOSE; // Applied Price
input int RSI_Buy_Level = 30;                             // Buy Level
input int RSI_Sell_Level = 70;                            // Sell Level

#include <PipboltFramework\Experts.mqh>

CiRSI RSI;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  RSI.Init(NULL, NULL, RSI_Period, RSI_Applied_Price);

  return INIT_SUCCEEDED;
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Buy Entry Strategy
  openBuy = (RSI.Main(0) <= RSI_Buy_Level && RSI.Main(1) > RSI_Buy_Level);

  // Sell Entry Strategy
  openSell = (RSI.Main(0) >= RSI_Sell_Level && RSI.Main(1) < RSI_Sell_Level);

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Close variable
  double close = iClose(NULL, NULL, _indicatorShift);

  // Buy Exit Strategy
  closeBuy = RSI.Main(0) > RSI_Sell_Level;

  // Sell Exit Strategy
  closeSell = (RSI.Main(0) < RSI_Buy_Level);
}