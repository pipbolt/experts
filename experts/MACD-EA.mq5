/**
 * @copyright   2019, pipbolt.io <beta@pipbolt.io>
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "MACD EA"
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

input group "MACD";
input int MACDFastPeriod = 12;                    // Fast Period
input int MACDSlowPeriod = 26;                    // Slow Period
input int MACDSignalPeriod = 9;                   // Signal Period
input ENUM_APPLIED_PRICE MACDPrice = PRICE_CLOSE; // Applied Price

#include <PipboltFramework\Experts.mqh>

CiMACD MACD;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  MACD.Init(NULL, NULL, MACDFastPeriod, MACDSlowPeriod, MACDSignalPeriod, MACDPrice);

  return (INIT_SUCCEEDED);
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Buy Entry Strategy
  openBuy = (MACD.Main(0) <= 0 && MACD.Signal(0) < MACD.Main(0) && MACD.Signal(1) >= MACD.Main(1));

  // Sell Entry Strategy
  openSell = (MACD.Main(0) >= 0 && MACD.Signal(0) > MACD.Main(0) && MACD.Signal(1) <= MACD.Main(1));

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Buy Exit Strategy
  closeBuy = (MACD.Signal(0) > MACD.Main(0));

  // Sell Exit Strategy
  closeSell = (MACD.Signal(0) < MACD.Main(0));
}