/**
 * @copyright   2019, pipbolt.io <beta@pipbolt.io>
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "RSI EA (Relative Strength Index)"
#define VERSION "0.022"

#property copyright COPYRIGHT
#property link LINK
#property icon ICON
#property description DESCRIPTION
#property version VERSION

#include <PipboltFramework\Params\MainSettings.mqh>

input group "Entry Strategy";
enum ENUM_ENTRY_STRATEGY
{
  BREAK_IN,  // Break In
  BREAK_OUT, // Break Out
};
input ENUM_ENTRY_STRATEGY EntryStrategy = 0; // Entry Strategy

input group "Exit Strategy";
input bool UseExitStrategy = false; // Use Exit Strategy

input group "Relative Strength Index";
input int RsiPeriod = 14;                               // Period
input ENUM_APPLIED_PRICE RsiAppliedPrice = PRICE_CLOSE; // Applied Price
input int RsiBuyLevel = 30;                             // Buy Level
input int RsiSellLevel = 70;                            // Sell Level

#include <PipboltFramework\Experts.mqh>

CiRSI RSI;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  RSI.Init(NULL, NULL, RsiPeriod, RsiAppliedPrice);

  return INIT_SUCCEEDED;
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Check Entry Strategy
  switch (EntryStrategy)
  {
  case BREAK_IN:
    openBuy = RSI.Main(0) <= RsiBuyLevel && RSI.Main(1) > RsiBuyLevel;
    openSell = RSI.Main(0) >= RsiSellLevel && RSI.Main(1) < RsiSellLevel;
    break;
  case BREAK_OUT:
    openBuy = RSI.Main(0) >= RsiBuyLevel && RSI.Main(1) < RsiBuyLevel;
    openSell = RSI.Main(0) <= RsiSellLevel && RSI.Main(1) > RsiSellLevel;
    break;
  }

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Close variable
  double close = iClose(NULL, NULL, _indicatorShift);

  // Buy Exit Strategy
  closeBuy = RSI.Main(0) > RsiSellLevel;

  // Sell Exit Strategy
  closeSell = RSI.Main(0) < RsiBuyLevel;
}