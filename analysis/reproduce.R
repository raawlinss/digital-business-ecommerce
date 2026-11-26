# Run from the repository root: Rscript analysis/reproduce.R
# All figure and table outputs are written from original public inputs.

raw_dir <- file.path("data", "raw")
dir.create("results", showWarnings = FALSE)
dir.create("figures", showWarnings = FALSE)

read_survey <- function(filename, scales, expected_n) {
  path <- file.path(raw_dir, filename)
  if (!file.exists(path)) {
    stop("Missing ", path, ". See data/README.md for the original download.")
  }
  data <- read.csv(path, check.names = FALSE)
  stopifnot(nrow(data) == expected_n)
  items <- data[unique(unlist(scales))]
  stopifnot(!anyNA(items), all(as.matrix(items) %in% 1:5))
  data
}

write_result <- function(data, filename) {
  write.csv(data, file.path("results", filename), row.names = FALSE)
}

scale_statistics <- function(data, scales) {
  rows <- lapply(names(scales), function(scale) {
    items <- data[scales[[scale]]]
    scores <- rowMeans(items)
    k <- ncol(items)
    alpha <- k / (k - 1) * (1 - sum(vapply(items, var, numeric(1))) / var(rowSums(items)))
    data.frame(scale, items = k, n = length(scores), mean = mean(scores),
               sd = sd(scores), cronbach_alpha = alpha)
  })
  do.call(rbind, rows)
}

pearson <- function(x, y) {
  fit <- cor.test(x, y, method = "pearson")
  data.frame(n = length(x), r = unname(fit$estimate),
             low = fit$conf.int[1], high = fit$conf.int[2])
}

qatar_scales <- list(
  PSI = c("PSI2", "PSI3", "PSI4", "PSI6"),
  INT = paste0("Int", 1:5)
)
qatar <- read_survey("Final Data.csv", qatar_scales, expected_n = 574)
stopifnot(all(qatar$gender %in% 1:2), all(qatar$age %in% 1:5))
closeness <- rowMeans(qatar[qatar_scales$PSI])
intention <- rowMeans(qatar[qatar_scales$INT])
groups <- list(
  "All respondents" = rep(TRUE, nrow(qatar)),
  Women = qatar$gender == 2,
  Men = qatar$gender == 1,
  "Ages 18-24" = qatar$age == 1,
  "Ages 25 and up" = qatar$age >= 2
)
qatar_correlations <- do.call(rbind, lapply(names(groups), function(group) {
  keep <- groups[[group]]
  cbind(group, pearson(closeness[keep], intention[keep]))
}))
write_result(qatar_correlations, "qatar_correlations.csv")
write_result(scale_statistics(qatar, qatar_scales), "qatar_scale_statistics.csv")

qatar_checks <- data.frame(
  n = nrow(qatar),
  covariance = cov(closeness, intention),
  sd_closeness = sd(closeness),
  sd_intention = sd(intention),
  pearson_from_covariance = cov(closeness, intention) / (sd(closeness) * sd(intention)),
  pearson_without_int5 = cor(closeness, rowMeans(qatar[paste0("Int", 1:4)])),
  spearman = cor(closeness, intention, method = "spearman")
)
write_result(qatar_checks, "qatar_sensitivity.csv")

trust_scales <- list(
  FN = paste0("FN", 1:4),
  CC = paste0("CC", 1:3),
  NWOM = paste0("NWOM", 1:4),
  TIA = paste0("TIA", 1:3),
  TSMA = paste0("TSMA", 1:3)
)
trust <- read_survey("Dataset PUBLIC.csv", trust_scales, expected_n = 497)
trust_scores <- lapply(trust_scales, function(items) rowMeans(trust[items]))
pairs <- data.frame(x = c("FN", "CC", "TIA", "TSMA"), y = c("CC", "NWOM", "CC", "CC"))
trust_correlations <- do.call(rbind, lapply(seq_len(nrow(pairs)), function(i) {
  x <- trust_scores[[pairs$x[i]]]
  y <- trust_scores[[pairs$y[i]]]
  cbind(pairs[i, ], pearson(x, y), spearman = cor(x, y, method = "spearman"))
}))
write_result(trust_correlations, "advertising_trust_correlations.csv")
write_result(scale_statistics(trust, trust_scales), "advertising_trust_scale_statistics.csv")

instagram <- read.csv(file.path("data", "instagram_reactions.csv"))
revenue <- read.csv(file.path("data", "influencer_revenue.csv"))

ink <- "#142940"
muted <- "#415569"
old <- "#61758B"
teal <- "#007773"
rule <- "#D8E3EC"

chart <- function(filename, draw, height = 620) {
  png(file.path("figures", filename), width = 1320, height = height,
      res = 145, bg = "white")
  on.exit(dev.off())
  par(family = "sans", col = ink, col.axis = muted, col.lab = ink,
      col.main = ink, las = 1, bty = "n", mgp = c(2, 0.65, 0))
  draw()
}

forest <- function(data, labels, limits, ticks, heading) {
  par(mar = c(4.5, 1.2, 3.0, 1.2))
  y <- rev(seq_len(nrow(data)))
  span <- diff(limits)
  left <- limits[1] - 0.73 * span
  right <- limits[2] + 0.37 * span
  plot(NA, xlim = c(left, right), ylim = c(0.3, max(y) + 0.7),
       xaxs = "i", axes = FALSE, ann = FALSE)
  text(left, max(y) + .55, heading, adj = c(0, 0.5), font = 2, cex = 1.13)
  segments(ticks, .55, ticks, max(y) + .25, col = rule)
  if (limits[1] < 0) {
    segments(0, .55, 0, max(y) + .25, col = old, lwd = 1.2)
  }
  segments(data$low, y, data$high, y, col = old, lwd = 3)
  points(data$r, y, pch = 16, col = teal, cex = 1.25)
  text(left, y, labels, adj = c(0, 0.5), cex = 0.82)
  text(right, y, sprintf("%.3f [%0.3f, %0.3f]", data$r, data$low, data$high),
       adj = c(1, 0.5), cex = 0.82, col = muted)
  axis(1, at = ticks, labels = sprintf("%.1f", round(ticks, 1)), col = rule,
       cex.axis = .84)
  mtext("Pearson correlation (r) and 95% confidence interval", side = 1, line = 2.35,
        cex = .91, col = muted)
}

chart("qatar-purchase-intention.png", function() {
  forest(qatar_correlations,
         paste0(qatar_correlations$group, "  |  n = ", qatar_correlations$n),
         c(0, .8), seq(0, .8, .2), "Influencer closeness and purchase intention")
})

chart("advertising-trust.png", function() {
  forest(trust_correlations, c(
    "False product news response\nand company cynicism",
    "Company cynicism\nand negative word of mouth",
    "Trust in influencer ads\nand company cynicism",
    "Trust in social media ads\nand company cynicism"
  ), c(-.6, .6), seq(-.6, .6, .2), "Advertising trust and consumer reactions")
})

chart("instagram-reactions.png", function() {
  par(mfrow = c(1, 3), mar = c(4.1, 3.2, 2.8, 0.8), oma = c(0, 0, 3.0, 0))
  ceilings <- c(460, 31, 52)
  ticks <- list(c(0, 200, 400), c(0, 10, 20, 30), c(0, 20, 40))
  for (i in seq_len(nrow(instagram))) {
    values <- c(instagram$year_2024[i], instagram$year_2025[i])
    plot(c(.5, 2.5), c(0, ceilings[i]), type = "n", axes = FALSE, ann = FALSE,
         xaxs = "i", yaxs = "i")
    abline(h = ticks[[i]], col = rule)
    rect(c(.72, 1.72), 0, c(1.28, 2.28), values, col = c(old, teal), border = NA)
    text(1:2, values + .055 * ceilings[i], values, cex = .95, font = 2)
    axis(1, at = 1:2, labels = c("2024", "2025"), tick = FALSE, cex.axis = .91)
    axis(2, at = ticks[[i]], tick = FALSE, cex.axis = .85)
    title(main = instagram$metric[i], line = .55)
  }
  mtext("Average Instagram reactions per post", outer = TRUE, side = 3,
        line = .85, font = 2, cex = 1.18, col = ink)
}, height = 550)

chart("revenue-per-follower.png", function() {
  par(mar = c(4.5, 6.0, 3.3, 2.0))
  y <- rev(seq_len(nrow(revenue)))
  values <- revenue$revenue_eur_per_follower
  ticks <- seq(0, .3, .1)
  plot(NA, xlim = c(0, .32), ylim = c(.45, 3.55), axes = FALSE, ann = FALSE, xaxs = "i")
  abline(v = ticks, col = rule)
  rect(0, y - .22, values, y + .22, col = teal, border = NA)
  text(values + .008, y, sprintf("%.3f", values), adj = 0, font = 2)
  axis(2, at = y, labels = revenue$follower_group, tick = FALSE, cex.axis = .92)
  axis(1, at = ticks, labels = sprintf("%.2f", ticks), col = rule, cex.axis = .85)
  title("Attributed revenue by influencer follower group", line = 1.1)
  mtext("Mean euros per follower", side = 1, line = 2.35, cex = .91, col = muted)
}, height = 520)

writeLines(trimws(capture.output(sessionInfo()), which = "right"),
           file.path("results", "r_session_info.txt"))
message("Recreated five statistical tables and four figures.")
