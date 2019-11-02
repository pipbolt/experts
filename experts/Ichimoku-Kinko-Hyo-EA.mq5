/**
 * @copyright   2019, pipbolt.io
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "Ichimoku EA"
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

input group "Ichimoku Kynko Hyo";
input int tenkanSen = 9;    // period of Tenkan-sen
input int kijunSen = 26;    // period of Kijun-sen
input int senkouSpanB = 52; // period of Senkou Span B

#include <PipboltFramework\Experts.mqh>

CiIchimoku Ichimoku;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  Ichimoku.Init(NULL, NULL, tenkanSen, kijunSen, senkouSpanB);

  return INIT_SUCCEEDED;
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Buy Entry Strategy
  openBuy = (Ichimoku.TenkanSen(0) > Ichimoku.KijunSen(0) && Ichimoku.TenkanSen(1) <= Ichimoku.KijunSen(1));

  // Sell Entry Stategy
  openSell = (Ichimoku.TenkanSen(0) < Ichimoku.KijunSen(0) && Ichimoku.TenkanSen(1) >= Ichimoku.KijunSen(1));

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Buy Exit Strategy
  closeBuy = (Ichimoku.TenkanSen(0) <= Ichimoku.KijunSen(0));

  // Sell Exit Stategy
  closeSell = (Ichimoku.TenkanSen(0) >= Ichimoku.KijunSen(0));
}
//+------------------------------------------------------------------+
