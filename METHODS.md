# Statistical methods

[Main report](README.md) · [Data guide](data/README.md) · [Executable R script](analysis/reproduce.R)

## Survey scoring

The analysis uses two separate public survey datasets. Scores are equally weighted means of the specified 1–5 items for each participant. The code checks the source row counts and verifies that the selected items contain valid, complete responses. All 574 Qatar rows and 497 advertising-trust rows enter their respective analyses. No weighting or imputation is applied.

| Dataset | Scale | Source columns |
| --- | --- | --- |
| Qatar | Parasocial closeness (PSI) | PSI2, PSI3, PSI4, PSI6 |
| Qatar | Purchase intention (INT) | Int1–Int5 |
| Advertising trust | Reaction to false product news (FN) | FN1–FN4 |
| Advertising trust | Company cynicism (CC) | CC1–CC3 |
| Advertising trust | Negative word of mouth (NWOM) | NWOM1–NWOM4 |
| Advertising trust | Trust in influencer advertising (TIA) | TIA1–TIA3 |
| Advertising trust | Trust in social media advertising (TSMA) | TSMA1–TSMA3 |

The four PSI items follow the item selection described in the Qatar data article. The observed item averages used here differ from latent scores used for structural models. Source gender and age groups are retained for descriptive analysis. [Qatar data article](https://doi.org/10.1016/j.dib.2024.110128) · [Advertising-trust article](https://doi.org/10.1016/j.chb.2025.108842)

## How the estimates are calculated

- **Scale mean and standard deviation.** Compute one average per participant, then take the sample mean and sample standard deviation of those averages.
- **Cronbach’s alpha.** Multiply `1 − sum(item variances) / variance(total item score)` by `k / (k − 1)`, where `k` is the number of items. Alpha summarizes internal consistency under this scoring procedure. Other evidence is needed to establish construct validity.
- **Pearson’s r.** Divide the sample covariance of the two scores by the product of their sample standard deviations. For the full Qatar sample, the rounded inputs are `0.518461 / (1.015063 × 1.016375) ≈ 0.502538`.
- **95% confidence interval.** R’s `cor.test()` applies Fisher’s transformation. It computes `atanh(r)`, adds and subtracts `qnorm(0.975) / sqrt(n − 3)`, and applies `tanh()` to return to the correlation scale. The intervals are conditional on the sampling model. The Qatar recruitment method limits population inference.
- **Sensitivity checks.** The Qatar analysis repeats the Pearson calculation with Int1–Int4 because Int5 also asks about satisfaction. The script reports Spearman rank correlations for the full Qatar sample and for all four advertising-trust pairs as a check on monotonic association.

The Qatar age and gender estimates are exploratory subsets of the same sample. The script reports each estimate and interval individually. It does not test differences between those subgroups or adjust for potential confounders. Both datasets measure survey responses, and the analysis estimates associations between observed composites. [Correlation interpretation](https://doi.org/10.1213/ANE.0000000000002864)

## What the revenue and engagement metrics count

- **Session conversion** is purchase sessions divided by all sessions. The proposed experiment instead uses purchasing users divided by all assigned users, which matches the unit of random assignment.
- **Attributed revenue per follower** is code-attributed gross sales revenue divided by the creator’s follower count. The published bars are means for three follower-count groups in one commercial sample.
- **Return on influencer spend** is `(attributed revenue − estimated endorsement cost) / estimated endorsement cost`. Beichert et al. report this separately from revenue per follower. The metric leaves other business costs outside the calculation.
- **Incremental purchases** are estimated from the difference between randomized groups. A creative-to-creative test answers which format performed better. An ad/no-ad test addresses the effect of running the campaign itself.

[Beichert et al. (2024)](https://doi.org/10.1177/00222429231217471) · [Gordon et al. (2019)](https://doi.org/10.1287/mksc.2018.1135)
