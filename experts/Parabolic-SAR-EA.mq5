/**
 * @copyright   2019, pipbolt.io <beta@pipbolt.io>
 * @license     https://github.com/pipbolt/experts/blob/master/LICENSE
 */

#include <PipboltFramework\Constants.mqh>

#define NAME "Parabolic SAR EA"
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

input group "Parabolic SAR";
input double PSAR_Step = 0.02;   // Step
input double PSAR_Maximum = 0.2; // Maximum

#include <PipboltFramework\Experts.mqh>

CiSAR PSAR;

int OnInit(void)
{
  if (ONINIT() != INIT_SUCCEEDED)
    return INIT_FAILED;

  PSAR.Init(NULL, NULL, PSAR_Step, PSAR_Maximum);

  return INIT_SUCCEEDED;
}

void OnTick(void) { ONTICK(); }
void OnDeinit(const int reason) { ONDEINIT(reason); }
void OnTimer() { ONTIMER(); }

void CheckForOpen(bool &openBuy, bool &openSell)
{
  // Close variables
  double close0 = iClose(NULL, NULL, _indicatorShift);
  double close1 = iClose(NULL, NULL, _indicatorShift + 1);

  // Buy Entry Strategy
  if (PSAR.Main(1) > close1 && PSAR.Main(0) < close0)
    openBuy = true;

  // Sell Entry Strategy
  else if (PSAR.Main(1) < close1 && PSAR.Main(0) > close0)
    openSell = true;

  // Apply MA Filter
  openBuy = openBuy && MAFilter.Check(DIR_BUY);
  openSell = openSell && MAFilter.Check(DIR_SELL);
}

void CheckForClose(bool &closeBuy, bool &closeSell)
{
  // Close variables
  double close0 = iClose(NULL, NULL, _indicatorShift);
  double close1 = iClose(NULL, NULL, _indicatorShift + 1);

  // Buy Exit Strategy
  closeBuy = (PSAR.Main(0) > close0 && PSAR.Main(1) < close1);

  // Sell Exit Strategy
  closeSell = (PSAR.Main(0) < close0 && PSAR.Main(1) > close1);
}
