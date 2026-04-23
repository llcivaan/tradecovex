# ============================================================
# TRADECOVEX - CTR TITLE REWRITE BATCH 2 (OPTION B) - v2
# Uses here-strings (@'...'@) so apostrophes don't break parsing
# ============================================================

cd D:\Tradecovex\website

function Update-Page {
    param(
        [string]$File,
        [string]$OldTitle,
        [string]$NewTitle,
        [string]$OldDesc,
        [string]$NewDesc
    )
    
    if (-not (Test-Path $File)) {
        Write-Host "  SKIP: $File not found" -ForegroundColor Yellow
        return
    }
    
    $c = [System.IO.File]::ReadAllText($File, [System.Text.Encoding]::UTF8)
    $original = $c
    
    # Title tag (HTML)
    $c = $c.Replace("<title>$OldTitle</title>", "<title>$NewTitle</title>")
    # og:title
    $c = $c.Replace('property="og:title" content="' + $OldTitle + '"', 'property="og:title" content="' + $NewTitle + '"')
    # twitter:title
    $c = $c.Replace('name="twitter:title" content="' + $OldTitle + '"', 'name="twitter:title" content="' + $NewTitle + '"')
    
    # Meta description
    $c = $c.Replace('name="description" content="' + $OldDesc + '"', 'name="description" content="' + $NewDesc + '"')
    # og:description
    $c = $c.Replace('property="og:description" content="' + $OldDesc + '"', 'property="og:description" content="' + $NewDesc + '"')
    # twitter:description
    $c = $c.Replace('name="twitter:description" content="' + $OldDesc + '"', 'name="twitter:description" content="' + $NewDesc + '"')
    
    if ($c -eq $original) {
        Write-Host "  WARNING: No changes made to $File" -ForegroundColor Yellow
        return
    }
    
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($File, $c, $utf8NoBom)
    Write-Host "  OK: $File" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== CTR Title Rewrite Batch (Option B) ===" -ForegroundColor Cyan
Write-Host ""

# ---------- 1. pass-topstep-combine ----------
$old = @'
How to Pass a Topstep Trading Combine 2026
'@
$new = @'
How to Pass Topstep 2026: The 7 Rules That Kill Most Traders
'@
$oldDesc = @'
Pass the Topstep Trading Combine in 2026. The trailing MLL trap, the 90/10 split, the 7-step pass plan funded traders use. Updated April 2026.
'@
$newDesc = @'
Why 83% fail the Topstep Combine in 2026 — and the 7-step plan funded traders actually use. Trailing MLL trap, 90/10 split, daily playbook. [Updated April]
'@
Update-Page -File "guides\pass-topstep-combine.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 2. topstep-combine-rules-2026 ----------
$old = @'
Topstep Trading Combine Rules 2026 Guide
'@
$new = @'
Topstep 2026: Every Rule That Kills Combines [April Update]
'@
$oldDesc = @'
Every Topstep Trading Combine rule in 2026 explained — profit targets, trailing MLL, 90/10 split, Standard vs Consistency Path. Updated April 2026.
'@
$newDesc = @'
All 12 Topstep rules for 2026 — including the 4 changes most traders miss. Trailing MLL, 90/10 split, Standard vs Consistency Path. [Updated April]
'@
Update-Page -File "guides\topstep-combine-rules-2026.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 3. myfundedfutures-rules ----------
$old = @'
MyFundedFutures Rules 2026: Core, Rapid, Pro
'@
$new = @'
MyFundedFutures 2026: The Rule That Kills Funded Accounts
'@
$oldDesc = @'
MyFundedFutures (MFFU) rules 2026: Core vs Rapid vs Pro plans, EOD vs intraday drawdown, Tier 1 news rule, payouts, consistency. Updated April 2026.
'@
$newDesc = @'
Why MFFU Rapid blows funded accounts most — EOD vs intraday drawdown, Tier 1 news trap, Core vs Rapid vs Pro. [Updated April 2026]
'@
Update-Page -File "guides\myfundedfutures-rules.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 4. topstep-combine-account-sizes-profit-targets-2026 ----------
$old = @'
Topstep Account Sizes &amp; Profit Targets 2026
'@
$new = @'
Topstep 50K vs 100K vs 150K: Which Combine to Pick 2026
'@
$oldDesc = @'
Every Topstep Trading Combine account size with exact profit targets, drawdown limits, contract caps, and monthly pricing for 2026.
'@
$newDesc = @'
50K vs 100K vs 150K Topstep Combine — which one actually pays off? Full profit target, drawdown, and pricing breakdown. [Updated April 2026]
'@
Update-Page -File "guides\topstep-combine-account-sizes-profit-targets-2026.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 5. best-times-day-trade-futures ----------
$old = @'
Best Times to Day Trade Futures (Hour by Hour)
'@
$new = @'
Best Times to Day Trade Futures: The 3-Hour Rule 2026
'@
$oldDesc = @'
Hour-by-hour guide to the best times to trade NQ and ES futures. Opening range, European overlap, dead zones, and when to stop.
'@
$newDesc = @'
Only 3 hours of the day matter for futures day traders — and most lose money in the other 6. Hour-by-hour NQ/ES guide. [2026]
'@
Update-Page -File "guides\best-times-day-trade-futures.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 6. canadian-prop-firm-tax-guide ----------
$old = @'
Prop Firm Tax Guide for Canadians (2026)
'@
$new = @'
Prop Firm Taxes Canada 2026: What the CRA Actually Wants
'@
$oldDesc = @'
How prop firm income is taxed by the CRA. Ontario focus. Business vs personal income, deductions, HST, and reporting explained.
'@
$newDesc = @'
How the CRA taxes prop firm income in 2026 — business vs personal, HST, deductions, and the 3 mistakes that trigger audits. [Ontario Focus]
'@
Update-Page -File "guides\canadian-prop-firm-tax-guide.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 7. apex-trader-funding-rules-2026 ----------
$old = @'
Apex Trader Funding Rules 2026 (Complete Guide)
'@
$new = @'
Apex 4.0 Rules 2026: The 5 Changes That Fail Traders
'@
$oldDesc = @'
Every Apex rule after the March 2026 update. EOD vs intraday drawdown, 50% consistency, bracket orders, payout ladder, and DCA ban explained.
'@
$newDesc = @'
The 5 Apex 4.0 changes nobody warned you about — bracket order mandate, DCA ban, 50% consistency rule, new payout ladder. [Updated April 2026]
'@
Update-Page -File "guides\apex-trader-funding-rules-2026.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 8. myfundedfutures-rules-2026 ----------
$old = @'
MyFundedFutures Rules 2026: Core, Rapid &amp; Pro
'@
$new = @'
MFFU Rules 2026: Every Trap in Core, Rapid &amp; Pro Plans
'@
$oldDesc = @'
Every MFFU rule in 2026. Core, Rapid, and Pro plans. Drawdown, consistency, payouts, and the path to live trading explained.
'@
$newDesc = @'
Every MFFU rule in 2026 — plus the drawdown trap in Rapid that kills funded accounts fastest. Core vs Rapid vs Pro fully compared. [April Update]
'@
Update-Page -File "guides\myfundedfutures-rules-2026.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 9. pass-apex-evaluation ----------
$old = @'
How to Pass an Apex Evaluation in 2026
'@
$new = @'
How to Pass Apex 2026: The Rule Change That Breaks 70%
'@
$oldDesc = @'
Complete guide to passing the Apex Trader Funding evaluation under the new 4.0 rules. EOD vs intraday, bracket orders, and profit strategy.
'@
$newDesc = @'
The Apex 4.0 rule change that blew up 70% of funded accounts — and the exact strategy that still works. Bracket orders, drawdown, DCA ban. [2026]
'@
Update-Page -File "guides\pass-apex-evaluation.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 10. trade-copier-pricing ----------
$old = @'
Trade Copier Pricing 2026: Every Tool Compared
'@
$new = @'
Trade Copier Pricing 2026: The Real Cost (All 7 Compared)
'@
$oldDesc = @'
Complete pricing comparison of every NinjaTrader trade copier in 2026. Monthly, annual, and one-time costs for all major tools.
'@
$newDesc = @'
What every NinjaTrader trade copier actually costs in 2026 — including the hidden fees. 7 tools compared on monthly, annual, lifetime pricing.
'@
Update-Page -File "compare\trade-copier-pricing.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 11. prop-firm-rules-2026 ----------
$old = @'
Prop Firm Rules 2026: Complete Comparison Hub
'@
$new = @'
Prop Firm Rules 2026: 6 Firms Compared (The Honest Version)
'@
$oldDesc = @'
Side-by-side comparison of every major futures prop firm's 2026 rules. Topstep, Apex, MFFU, TPT, Bulenox, and Tradeify in one place.
'@
$newDesc = @'
6 futures prop firms compared on every 2026 rule — Topstep, Apex, MFFU, TPT, Bulenox, Tradeify. Drawdown, splits, consistency, payouts. [April]
'@
Update-Page -File "guides\prop-firm-rules-2026.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 12. how-many-combines-passed-express-topstep-2025 ----------
$old = @'
Topstep Pass Rates: How Many Made Express? (2025)
'@
$new = @'
Topstep Pass Rate 2025: Only 16.8% Make It (Real Data)
'@
$oldDesc = @'
Topstep's official funnel stats: 16.8% of Combines completed into Express. 51.8% of Express traders got a payout. Full data breakdown.
'@
$newDesc = @'
Topstep official data: only 16.8% pass the Combine, 51.8% of funded get paid. Full funnel breakdown and what separates winners.
'@
Update-Page -File "guides\how-many-combines-passed-express-topstep-2025.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 13. apex-vs-topstep-vs-myfundedfutures ----------
$old = @'
Apex vs Topstep vs MFFU: Best Prop Firm 2026?
'@
$new = @'
Apex vs Topstep vs MFFU 2026: Which Actually Pays Best?
'@
$oldDesc = @'
Three-way comparison of Apex, Topstep, and MyFundedFutures. Rules, pricing, drawdown, profit splits, and payouts compared side by side.
'@
$newDesc = @'
The 2026 prop firm you should pick — Apex vs Topstep vs MFFU on rules, pricing, drawdown, profit splits, and real payout speed. [Verdict Inside]
'@
Update-Page -File "compare\apex-vs-topstep-vs-myfundedfutures.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 14. tradesyncer-pricing-2026 ----------
$old = @'
TradeSyncer Pricing 2026: All Plans Explained
'@
$new = @'
TradeSyncer Pricing 2026: Is It Worth $99/mo?
'@
$oldDesc = @'
Every TradeSyncer pricing plan in 2026. Basic $49, Pro $99, Flex $149. Connection limits, annual discounts, and hidden fees explained.
'@
$newDesc = @'
TradeSyncer 2026 pricing breakdown — Basic $49, Pro $99, Flex $149. Connection limits, annual discounts, and the hidden fees nobody mentions.
'@
Update-Page -File "compare\tradesyncer-pricing-2026.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 15. variance-futures-trading-hours ----------
$old = @'
Variance Futures Trading Hours 2026 (VA Sessions)
'@
$new = @'
Variance Futures Hours 2026: Full Session Schedule (VA)
'@
$oldDesc = @'
Cboe S&amp;P 500 Variance Futures (VA) trade Mon-Fri, 8:30 AM to 3:15 PM CT. Full 2026 session reference with holidays and half-days.
'@
$newDesc = @'
Cboe S&amp;P 500 Variance Futures (VA) 2026 hours — Mon-Fri 8:30am-3:15pm CT. Complete holiday + half-day schedule inside. [Updated April]
'@
Update-Page -File "guides\variance-futures-trading-hours.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 16. trailing-drawdown ----------
$old = @'
Trailing Drawdown Explained for Prop Firm Traders
'@
$new = @'
Trailing Drawdown Explained: The Rule That Kills 80% [2026]
'@
$oldDesc = @'
Complete guide to trailing drawdown. EOD vs intraday trailing, how the floor locks in, why it matters, and which prop firms use which type.
'@
$newDesc = @'
Why trailing drawdown kills 80% of prop firm traders — EOD vs intraday, how the floor locks, and which firms use which type. [2026 Update]
'@
Update-Page -File "guides\trailing-drawdown.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 17. ninjatrader-trade-copier ----------
$old = @'
NinjaTrader Trade Copier: Complete 2026 Guide
'@
$new = @'
NinjaTrader Trade Copier 2026: The 4 That Actually Work
'@
$oldDesc = @'
How NinjaTrader trade copiers work, what to look for, and how to set one up across multiple prop firm accounts. Updated for 2026.
'@
$newDesc = @'
4 NinjaTrader trade copiers that actually work in 2026 — local vs cloud, prop firm compatibility, pricing, and setup guide. [April Update]
'@
Update-Page -File "guides\ninjatrader-trade-copier.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 18. copy-trades-apex-accounts ----------
$old = @'
Copy Trades Across Apex Accounts (2026 Guide)
'@
$new = @'
Copy Trades Across Apex Accounts 2026: The 4.0 Workaround
'@
$oldDesc = @'
How to copy trades across multiple Apex Trader Funding accounts on NinjaTrader. Updated for Apex 4.0 bracket order rules.
'@
$newDesc = @'
How to copy trades across Apex accounts under the new 4.0 bracket rule — the workaround that keeps your accounts compliant. [2026]
'@
Update-Page -File "guides\copy-trades-apex-accounts.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

# ---------- 19. projectx-trade-copier ----------
$old = @'
ProjectX Trade Copier 2026: What Works
'@
$new = @'
ProjectX Trade Copier 2026: What Works and What Fails
'@
$oldDesc = @'
Which trade copiers work with ProjectX in 2026. Topstep, Tradeify, and Luckyday on the ProjectX API. Workarounds and limitations.
'@
$newDesc = @'
Which copiers work with ProjectX in 2026 — Topstep, Tradeify, Luckyday API. Real limitations and workarounds inside. [Updated April]
'@
Update-Page -File "guides\projectx-trade-copier.html" -OldTitle $old.Trim() -NewTitle $new.Trim() -OldDesc $oldDesc.Trim() -NewDesc $newDesc.Trim()

Write-Host ""
Write-Host "=== Done. 19 pages processed. ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next: git add . ; git commit ; git push ; Netlify deploy" -ForegroundColor Yellow
Write-Host ""
