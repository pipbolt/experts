/**
 * @copyright   2019, pipbolt.io <beta@pipbolt.io>
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "Moving Average Cross EA"
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

input group "Moving Averages";
input string Fast_Moving_Average = "----------"; // ---------- Fast Moving Average ----------
input int MovingPeriodFast = 12;                 // Moving Average Period
input string Slow_Moving_Average = "----------"; // ---------- Slow Moving Average ----------
input int MovingPeriodSlow = 30;                 // Moving Average Period

#include <PipboltFramework\Experts.mqh>

CiMA MAFast;
CiMA MASlow;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  MAFast.Init(MovingPeriodFast, 0, MODE_SMA, PRICE_CLOSE);
  MASlow.Init(MovingPeriodSlow, 0, MODE_SMA, PRICE_CLOSE);

  return INIT_SUCCEEDED;
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Buy Entry Strategy
  if (MAFast.Main(1) < MASlow.Main(1) && MAFast.Main(0) >= MASlow.Main(0))
    openBuy = true;

  // Sell Entry Strategy
  else if (MAFast.Main(1) > MASlow.Main(1) && MAFast.Main(0) <= MASlow.Main(0))
    openSell = true;

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Buy Exit Strategy
  closeBuy = (MAFast.Main(1) > MASlow.Main(1) && MAFast.Main(0) <= MASlow.Main(0));

  // Sell Exit Strategy
  closeSell = (MAFast.Main(1) < MASlow.Main(1) && MAFast.Main(0) >= MASlow.Main(0));
}
