# Data and provenance

The repository includes published summary values and aggregate R results. Download the two respondent-level inputs from the original archives and retain their original filenames.

## Survey inputs

1. Save [Final Data.csv](https://data.mendeley.com/public-files/datasets/zv6fdn2ysv/files/3deea50a-45de-47bd-993a-9d77dac83feb/file_downloaded) as `data/raw/Final Data.csv`. This is version 3 of Sara AlSulaiti and Mohamed Slim Ben Mimoun’s *Social media usage in Qatar*. The archive includes the English questionnaire and lists a CC BY 4.0 license. [Mendeley Data record](https://doi.org/10.17632/zv6fdn2ysv.3)
2. Save [Dataset PUBLIC.csv](https://osf.io/download/s6dvu/) as `data/raw/Dataset PUBLIC.csv`. This is the response data associated with Moisescu, Sterie and Mican’s article on false product news, cynicism, and advertising trust. Consult the source archive for reuse terms. [OSF project](https://osf.io/vwr3k/) · [Article](https://doi.org/10.1016/j.chb.2025.108842)

Create the `data/raw/` folder if needed. The SHA-256 fingerprints below identify the exact input files used.

| File | Rows | SHA-256 |
| --- | ---: | --- |
| Final Data.csv | 574 | `5a816d99cfc2bd1c1c30d279e4b919b8bedee9553c24d5e810edb3e9983f5189` |
| Dataset PUBLIC.csv | 497 | `471bba71dac65005e810af01defa6ea7adf3fc0f01f2f29ade9037d7d307c975` |

## Benchmark inputs

| File | What it contains | Original source |
| --- | --- | --- |
| [instagram_reactions.csv](instagram_reactions.csv) | Full-year mean likes, comments and shares per Instagram post for 2024 and 2025 | [Socialinsider annual tables](https://www.socialinsider.io/social-media-benchmarks) |
| [instagram_teen_experiences.csv](instagram_teen_experiences.csv) | Four weighted answers to item TIGFEEL for the Instagram-user subgroup | [Pew survey topline, p. 9](https://www.pewresearch.org/wp-content/uploads/sites/20/2026/04/PI_2026.04.15_Teens-Cross-Platforms_TOPLINE.pdf) |
| [influencer_revenue.csv](influencer_revenue.csv) | Mean attributed revenue per follower in euros and mean return on influencer spend for three follower-count groups | [Beichert et al. (2024), Table 2](https://journals.sagepub.com/doi/10.1177/00222429231217471) |

The benchmark CSVs transcribe selected numerical values. Their source populations, definitions, and periods differ. The R script reads the Instagram reaction and influencer revenue CSVs for the two benchmark charts. The Pew CSV documents the numbers quoted in the report.
