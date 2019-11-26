/**
 * @copyright   2019, pipbolt.io <beta@pipbolt.io>
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "Bollinger Bands EA"
#define VERSION "0.022"

#property copyright COPYRIGHT
#property link LINK
#property icon ICON
#property description DESCRIPTION
#property version VERSION

#include <PipboltFramework\Params\MainSettings.mqh>

input group "Entry Strategy";

input group "Exit Strategy";
input bool UseExitStrategy = false; // Use Exit Strategy

input group "Bollinger Bands";
input int Bands_Period = 20;                                // Period
input double Bands_Deviation = 2;                           // Deviation
input ENUM_APPLIED_PRICE Bands_Applied_Price = PRICE_CLOSE; // Applied Price

#include <PipboltFramework\Experts.mqh>

CiBollinger BBands;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  BBands.Init(NULL, NULL, Bands_Period, 0, Bands_Deviation, Bands_Applied_Price);

  return INIT_SUCCEEDED;
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Close variable
  double close = iClose(NULL, NULL, _indicatorShift);

  // Buy Entry Strategy
  openBuy = close < BBands.Lower(0);

  // Sell Entry Strategy
  openSell = close > BBands.Upper(0);

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Close variable
  double close = iClose(NULL, NULL, _indicatorShift);

  // Buy Exit Strategy
  closeBuy = close > BBands.Upper(0);

  // Sell Exit Strategy
  closeSell = close < BBands.Lower(0);
}