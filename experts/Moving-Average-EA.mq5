/**
 * @copyright   2019, pipbolt.io <beta@pipbolt.io>
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "Moving Average EA"
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

input group "Moving Average";
input int MaPeriod = 10;                               // Period
input ENUM_MA_METHOD MaMethod = MODE_SMA;              // Method
input ENUM_APPLIED_PRICE MaAppliedPrice = PRICE_CLOSE; // Applied Price

#include <PipboltFramework\Experts.mqh>

CiMA MA;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  MA.Init(MaPeriod, 0, MaMethod, MaAppliedPrice);

  return INIT_SUCCEEDED;
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Close prices
  double close0 = iClose(NULL, NULL, _indicatorShift + 0);
  double close1 = iClose(NULL, NULL, _indicatorShift + 1);

  // Buy Entry Strategy
  openBuy = (close0 > MA.Main(0) && close1 <= MA.Main(1));

  // Sell Entry Strategy
  openSell = (close0 < MA.Main(0) && close1 >= MA.Main(1));

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Close price
  double close0 = iClose(NULL, NULL, _indicatorShift + 0);

  // Buy Exit Strategy
  closeBuy = (close0 < MA.Main(0));

  // Sell Exit Strategy
  closeSell = (close0 > MA.Main(0));
}
