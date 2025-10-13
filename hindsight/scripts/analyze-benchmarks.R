#!/usr/bin/env Rscript

# PostgreSQL Performance Benchmark Analysis
# Statistical regression analysis for Hindsight event sourcing system
# Usage: Rscript analyze-benchmarks.R benchmark-file.csv [output-dir]

library(ggplot2)
library(dplyr)
library(readr)
library(broom)
library(gridExtra)
library(scales)
library(tidyr)  # For gather() function in advanced plots

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  cat("Usage: Rscript analyze-benchmarks.R <csv-file> [output-directory]\n")
  cat("Example: Rscript analyze-benchmarks.R results.csv ./analysis\n")
  quit(status = 1)
}

csv_file <- args[1]
output_dir <- if (length(args) >= 2) args[2] else "analysis-output"

# Create output directory
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

cat("PostgreSQL Performance Analysis\n")
cat("===============================\n")
cat("Input file:", csv_file, "\n")
cat("Output directory:", output_dir, "\n\n")

# Load and preprocess data
tryCatch({
  data <- read_csv(csv_file, show_col_types = FALSE)
  cat("✓ Loaded", nrow(data), "benchmark records\n")
}, error = function(e) {
  cat("✗ Failed to load CSV file:", e$message, "\n")
  quit(status = 1)
})

# OUTLIER DETECTION AND DATA VALIDATION
cat("\n=== Data Validation and Outlier Detection ===\n")

# Function to detect outliers using IQR method
detect_outliers <- function(data, column_name) {
  values <- data[[column_name]]
  values <- values[!is.na(values) & is.finite(values)]
  
  if (length(values) < 4) {
    return(data.frame())  # Need at least 4 points for IQR
  }
  
  Q1 <- quantile(values, 0.25)
  Q3 <- quantile(values, 0.75)
  IQR <- Q3 - Q1
  
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  outlier_mask <- data[[column_name]] < lower_bound | data[[column_name]] > upper_bound
  outlier_mask[is.na(outlier_mask)] <- FALSE
  
  outliers <- data[outlier_mask, ]
  return(outliers)
}

# Detect outliers in throughput data
throughput_outliers <- detect_outliers(data, "insertion_throughput_eps")

if (nrow(throughput_outliers) > 0) {
  cat("⚠️  Detected", nrow(throughput_outliers), "throughput outliers:\n")
  for (i in 1:nrow(throughput_outliers)) {
    row <- throughput_outliers[i, ]
    cat("  -", round(row$insertion_throughput_eps), "eps at", 
        row$tx_count, "tx,", row$sub_count, "subs (", row$scenario, ")\n")
  }
  cat("\n")
} else {
  cat("✓ No throughput outliers detected\n")
}

# Data validation checks
validation_issues <- c()

# Check for impossible values
negative_throughput <- sum(data$insertion_throughput_eps < 0, na.rm = TRUE)
if (negative_throughput > 0) {
  validation_issues <- c(validation_issues, paste(negative_throughput, "records with negative throughput"))
}

# Check for extremely high values (>100k eps seems unrealistic for this system)
extreme_throughput <- sum(data$insertion_throughput_eps > 100000, na.rm = TRUE)
if (extreme_throughput > 0) {
  validation_issues <- c(validation_issues, paste(extreme_throughput, "records with >100k eps throughput"))
}

# Check for missing critical data
missing_throughput <- sum(is.na(data$insertion_throughput_eps))
if (missing_throughput > 0) {
  validation_issues <- c(validation_issues, paste(missing_throughput, "records with missing throughput"))
}

if (length(validation_issues) > 0) {
  cat("⚠️  Data validation issues:\n")
  for (issue in validation_issues) {
    cat("  -", issue, "\n")
  }
  cat("\n")
} else {
  cat("✓ Data validation passed\n")
}

# Clean data by removing invalid records
clean_data <- data %>%
  filter(!is.na(insertion_throughput_eps), 
         is.finite(insertion_throughput_eps),
         insertion_throughput_eps > 0,
         insertion_throughput_eps < 100000)

removed_records <- nrow(data) - nrow(clean_data)
if (removed_records > 0) {
  cat("🧹 Removed", removed_records, "invalid records\n")
  data <- clean_data
}

# Data validation
required_cols <- c("tx_count", "sub_count", "insertion_throughput_eps", "scenario")
missing_cols <- setdiff(required_cols, colnames(data))
if (length(missing_cols) > 0) {
  cat("✗ Missing required columns:", paste(missing_cols, collapse = ", "), "\n")
  quit(status = 1)
}

# Check for Phase 3 advanced metrics columns
phase3_cols <- c("latency_p50_ms", "latency_p95_ms", "latency_p99_ms", "latency_p999_ms",
                "initial_memory_mb", "peak_memory_mb", "final_memory_mb", "gc_count", "gc_time_ms",
                "avg_queue_depth", "subscription_lag_ms", "queue_overflow_count")
available_phase3_cols <- intersect(phase3_cols, colnames(data))
missing_phase3_cols <- setdiff(phase3_cols, colnames(data))

if (length(available_phase3_cols) > 0) {
  cat("✓ Found", length(available_phase3_cols), "Phase 3 advanced metrics columns\n")
}
if (length(missing_phase3_cols) > 0) {
  cat("ℹ️  Missing", length(missing_phase3_cols), "Phase 3 columns (likely older data):", 
      paste(head(missing_phase3_cols, 3), collapse = ", "), 
      if (length(missing_phase3_cols) > 3) "..." else "", "\n")
}

# Summary statistics
cat("\n=== Data Summary ===\n")
cat("Transaction range:", min(data$tx_count), "to", max(data$tx_count), "\n")
cat("Subscription range:", min(data$sub_count), "to", max(data$sub_count), "\n")
cat("Scenarios:", length(unique(data$scenario)), "-", paste(unique(data$scenario), collapse = ", "), "\n")

# Check for replicated data
replicated_scenarios <- data %>%
  filter(grepl("rep [0-9]+", scenario)) %>%
  nrow()

if (replicated_scenarios > 0) {
  cat("Replicated measurements:", replicated_scenarios, "records\n")
  
  # Calculate variance statistics for replicated data
  variance_stats <- data %>%
    filter(grepl("rep [0-9]+", scenario)) %>%
    # Extract base scenario name (remove replication info)
    mutate(base_scenario = gsub(" \\(rep [0-9]+\\)", "", scenario)) %>%
    group_by(base_scenario, tx_count, sub_count) %>%
    summarise(
      n_reps = n(),
      mean_throughput = mean(insertion_throughput_eps, na.rm = TRUE),
      sd_throughput = sd(insertion_throughput_eps, na.rm = TRUE),
      cv_percent = (sd_throughput / mean_throughput) * 100,  # Coefficient of variation
      .groups = "drop"
    ) %>%
    filter(n_reps > 1)  # Only configs with multiple measurements
  
  if (nrow(variance_stats) > 0) {
    cat("Replication variance analysis:\n")
    cat("  Configurations with replications:", nrow(variance_stats), "\n")
    cat("  Mean coefficient of variation:", round(mean(variance_stats$cv_percent, na.rm = TRUE), 2), "%\n")
    cat("  Max coefficient of variation:", round(max(variance_stats$cv_percent, na.rm = TRUE), 2), "%\n")
    
    # Flag high-variance configurations  
    high_variance <- variance_stats %>% filter(cv_percent > 10)
    if (nrow(high_variance) > 0) {
      cat("⚠️  High-variance configurations (CV > 10%):\n")
      for (i in 1:nrow(high_variance)) {
        row <- high_variance[i, ]
        cat("  -", row$tx_count, "tx,", row$sub_count, "subs: CV =", round(row$cv_percent, 1), "%\n")
      }
    } else {
      cat("✓ All replications show low variance (CV ≤ 10%)\n")
    }
  }
} else {
  cat("No replicated measurements detected\n")
}

# 1. LINEAR REGRESSION ANALYSIS
cat("\n=== Linear Regression Analysis ===\n")

# Transaction scaling analysis
tx_scaling_data <- data %>% 
  filter(sub_count == 1) %>%  # Fix subscriptions to isolate tx effect
  filter(!is.na(insertion_throughput_eps))

if (nrow(tx_scaling_data) > 2) {
  tx_model <- lm(insertion_throughput_eps ~ tx_count, data = tx_scaling_data)
  tx_summary <- summary(tx_model)
  
  cat("Transaction Scaling Model:\n")
  cat("  R-squared:", round(tx_summary$r.squared, 4), "\n")
  cat("  p-value:", format.pval(tx_summary$coefficients[2, 4]), "\n")
  cat("  Slope:", round(tx_summary$coefficients[2, 1], 6), "eps per transaction\n")
  
  if (tx_summary$coefficients[2, 4] < 0.05) {
    if (abs(tx_summary$coefficients[2, 1]) < 0.01) {
      cat("  → Throughput is CONSTANT with transaction count (good scaling)\n")
    } else if (tx_summary$coefficients[2, 1] > 0) {
      cat("  → Throughput INCREASES with transaction count (super-linear scaling)\n")
    } else {
      cat("  → Throughput DECREASES with transaction count (sub-linear scaling)\n")
    }
  } else {
    cat("  → No significant relationship detected\n")
  }
} else {
  cat("Insufficient data for transaction scaling analysis\n")
}

# Subscription scaling analysis
# Find the most common transaction count for subscription scaling tests
sub_tx_counts <- data %>% 
  filter(sub_count > 1) %>% 
  count(tx_count, sort = TRUE)

if (nrow(sub_tx_counts) > 0) {
  most_common_tx <- sub_tx_counts$tx_count[1]
  sub_scaling_data <- data %>%
    filter(tx_count == most_common_tx) %>%  # Use most common tx count for sub scaling
    filter(!is.na(insertion_throughput_eps))
} else {
  sub_scaling_data <- data.frame()  # No subscription scaling data
}

if (nrow(sub_scaling_data) > 2) {
  sub_model <- lm(insertion_throughput_eps ~ sub_count, data = sub_scaling_data)
  sub_summary <- summary(sub_model)
  
  cat("\nSubscription Scaling Model:\n")
  cat("  R-squared:", round(sub_summary$r.squared, 4), "\n")
  cat("  p-value:", format.pval(sub_summary$coefficients[2, 4]), "\n")
  cat("  Slope:", round(sub_summary$coefficients[2, 1], 6), "eps per subscription\n")
  
  if (sub_summary$coefficients[2, 4] < 0.05) {
    overhead_pct <- abs(sub_summary$coefficients[2, 1]) / mean(sub_scaling_data$insertion_throughput_eps) * 100
    cat("  → Subscription overhead:", round(overhead_pct, 2), "% per subscription\n")
  } else {
    cat("  → No significant subscription overhead detected\n")
  }
} else {
  cat("Insufficient data for subscription scaling analysis\n")
}

# 2. BIVARIATE REGRESSION ANALYSIS
cat("\n=== Bivariate Regression Analysis ===\n")

multi_data <- data %>%
  filter(!is.na(insertion_throughput_eps), tx_count > 100, sub_count > 0)

if (nrow(multi_data) > 5) {
  # Multiple regression: throughput ~ transactions + subscriptions
  bivariate_model <- lm(insertion_throughput_eps ~ tx_count + sub_count, data = multi_data)
  biv_summary <- summary(bivariate_model)
  
  cat("Bivariate Model (throughput ~ tx_count + sub_count):\n")
  cat("  R-squared:", round(biv_summary$r.squared, 4), "\n")
  cat("  Adjusted R-squared:", round(biv_summary$adj.r.squared, 4), "\n")
  cat("  F-statistic p-value:", format.pval(pf(biv_summary$fstatistic[1], 
                                               biv_summary$fstatistic[2],
                                               biv_summary$fstatistic[3], 
                                               lower.tail = FALSE)), "\n")
  
  # Coefficient interpretation
  tx_coeff <- biv_summary$coefficients[2, ]
  sub_coeff <- biv_summary$coefficients[3, ]
  
  cat("  Transaction coefficient:", round(tx_coeff[1], 6), 
      "(p =", format.pval(tx_coeff[4]), ")\n")
  cat("  Subscription coefficient:", round(sub_coeff[1], 6), 
      "(p =", format.pval(sub_coeff[4]), ")\n")
  
  # Model equation
  intercept <- round(biv_summary$coefficients[1, 1], 2)
  tx_term <- round(tx_coeff[1], 6)
  sub_term <- round(sub_coeff[1], 6)
  cat("  Model: throughput =", intercept, "+", tx_term, "* tx_count +", sub_term, "* sub_count\n")
  
} else {
  cat("Insufficient data for bivariate analysis\n")
}

# 3. PHASE 3 ADVANCED METRICS ANALYSIS
if (length(available_phase3_cols) > 0) {
  cat("\n=== Phase 3 Advanced Metrics Analysis ===\n")
  
  # 3.1 LATENCY PERCENTILE ANALYSIS
  latency_cols <- c("latency_p50_ms", "latency_p95_ms", "latency_p99_ms", "latency_p999_ms")
  available_latency_cols <- intersect(latency_cols, available_phase3_cols)
  
  if (length(available_latency_cols) > 0) {
    cat("\nLatency Percentile Analysis:\n")
    
    # Filter data with latency measurements
    latency_data <- data %>% 
      filter(!is.na(latency_p50_ms), latency_p50_ms > 0)
    
    if (nrow(latency_data) > 0) {
      cat("  Records with latency data:", nrow(latency_data), "\n")
      
      # Calculate latency statistics
      if ("latency_p50_ms" %in% available_latency_cols) {
        p50_stats <- summary(latency_data$latency_p50_ms)
        cat("  P50 latency (median):", sprintf("%.2f", p50_stats["Median"]), "ms\n")
      }
      if ("latency_p95_ms" %in% available_latency_cols) {
        p95_stats <- summary(latency_data$latency_p95_ms)
        cat("  P95 latency:", sprintf("%.2f", p95_stats["Median"]), "ms (median across runs)\n")
      }
      if ("latency_p99_ms" %in% available_latency_cols) {
        p99_stats <- summary(latency_data$latency_p99_ms)
        cat("  P99 latency:", sprintf("%.2f", p99_stats["Median"]), "ms (median across runs)\n")
      }
      
      # Latency vs throughput correlation
      if ("latency_p50_ms" %in% available_latency_cols) {
        latency_throughput_cor <- cor(latency_data$latency_p50_ms, latency_data$insertion_throughput_eps, 
                                     use = "complete.obs")
        cat("  Latency-Throughput correlation:", sprintf("%.3f", latency_throughput_cor))
        if (abs(latency_throughput_cor) > 0.3) {
          cat(" (", if (latency_throughput_cor > 0) "positive" else "negative", " relationship)\n")
        } else {
          cat(" (weak relationship)\n")
        }
      }
    } else {
      cat("  No latency measurement data available\n")
    }
  }
  
  # 3.2 MEMORY PROFILING ANALYSIS  
  memory_cols <- c("initial_memory_mb", "peak_memory_mb", "final_memory_mb", "gc_count", "gc_time_ms")
  available_memory_cols <- intersect(memory_cols, available_phase3_cols)
  
  if (length(available_memory_cols) > 0) {
    cat("\nMemory Profiling Analysis:\n")
    
    # Filter data with memory measurements
    memory_data <- data %>% 
      filter(!is.na(initial_memory_mb) | !is.na(peak_memory_mb))
    
    if (nrow(memory_data) > 0) {
      cat("  Records with memory data:", nrow(memory_data), "\n")
      
      if ("peak_memory_mb" %in% available_memory_cols) {
        memory_stats <- summary(memory_data$peak_memory_mb[!is.na(memory_data$peak_memory_mb)])
        cat("  Peak memory usage:", sprintf("%.1f", memory_stats["Median"]), "MB (median)\n")
        cat("  Memory usage range:", sprintf("%.1f", memory_stats["Min."]), "-", 
            sprintf("%.1f", memory_stats["Max."]), "MB\n")
        
        # Memory vs load correlation
        if (sum(!is.na(memory_data$peak_memory_mb)) > 3) {
          memory_load_cor <- cor(memory_data$peak_memory_mb, memory_data$tx_count, use = "complete.obs")
          if (!is.na(memory_load_cor)) {
            cat("  Memory-Load correlation:", sprintf("%.3f", memory_load_cor))
            if (abs(memory_load_cor) > 0.5) {
              cat(" (", if (memory_load_cor > 0) "scales with load" else "inverse scaling", ")\n")
            } else {
              cat(" (load-independent)\n")
            }
          } else {
            cat("  Memory-Load correlation: N/A (no variance in load)\n")
          }
        }
      }
      
      if ("gc_count" %in% available_memory_cols && "gc_time_ms" %in% available_memory_cols) {
        gc_data <- memory_data %>% filter(!is.na(gc_count), !is.na(gc_time_ms), gc_count > 0)
        if (nrow(gc_data) > 0) {
          avg_gc_time <- mean(gc_data$gc_time_ms / gc_data$gc_count, na.rm = TRUE)
          total_gc_time <- mean(gc_data$gc_time_ms, na.rm = TRUE)
          cat("  GC overhead: ~", sprintf("%.1f", total_gc_time), "ms per benchmark (", 
              sprintf("%.1f", avg_gc_time), "ms per GC)\n")
        }
      }
    } else {
      cat("  No memory profiling data available\n")
    }
  }
  
  # 3.3 QUEUE METRICS ANALYSIS
  queue_cols <- c("avg_queue_depth", "subscription_lag_ms", "queue_overflow_count") 
  available_queue_cols <- intersect(queue_cols, available_phase3_cols)
  
  if (length(available_queue_cols) > 0) {
    cat("\nQueue Metrics Analysis:\n")
    
    # Filter data with queue measurements
    queue_data <- data %>% 
      filter(!is.na(avg_queue_depth) | !is.na(subscription_lag_ms))
    
    if (nrow(queue_data) > 0) {
      cat("  Records with queue data:", nrow(queue_data), "\n")
      
      if ("avg_queue_depth" %in% available_queue_cols) {
        queue_stats <- summary(queue_data$avg_queue_depth[!is.na(queue_data$avg_queue_depth)])
        if (length(queue_stats) > 0) {
          cat("  Average queue depth:", sprintf("%.1f", queue_stats["Median"]), 
              "(range:", sprintf("%.1f", queue_stats["Min."]), "-", sprintf("%.1f", queue_stats["Max."]), ")\n")
        }
      }
      
      if ("subscription_lag_ms" %in% available_queue_cols) {
        lag_stats <- summary(queue_data$subscription_lag_ms[!is.na(queue_data$subscription_lag_ms)])
        if (length(lag_stats) > 0) {
          cat("  Subscription lag:", sprintf("%.1f", lag_stats["Median"]), "ms (median)\n")
          
          # High lag warning
          high_lag_threshold <- 1000  # 1 second
          high_lag_count <- sum(queue_data$subscription_lag_ms > high_lag_threshold, na.rm = TRUE)
          if (high_lag_count > 0) {
            cat("  ⚠️  ", high_lag_count, "measurements with >", high_lag_threshold, "ms lag\n")
          }
        }
      }
      
      if ("queue_overflow_count" %in% available_queue_cols) {
        overflow_data <- queue_data %>% filter(!is.na(queue_overflow_count))
        if (nrow(overflow_data) > 0) {
          total_overflows <- sum(overflow_data$queue_overflow_count, na.rm = TRUE)
          if (total_overflows > 0) {
            cat("  ⚠️  Queue overflows detected:", total_overflows, "total events\n")
          } else {
            cat("  ✓ No queue overflows detected\n")
          }
        }
      }
    } else {
      cat("  No queue metrics data available\n")
    }
  }
}

# CONFIDENCE INTERVALS AND ROBUST STATISTICS
if (exists("tx_summary") || exists("sub_summary")) {
  cat("\n=== Confidence Intervals ===\n")
  
  # Transaction scaling confidence intervals
  if (exists("tx_summary") && nrow(tx_scaling_data) > 3) {
    tx_confint <- confint(tx_model, level = 0.95)
    cat("Transaction scaling (95% CI):\n")
    cat("  Slope:", sprintf("%.6f", tx_summary$coefficients[2, 1]), 
        "[", sprintf("%.6f", tx_confint[2, 1]), ",", sprintf("%.6f", tx_confint[2, 2]), "]\n")
    
    # R-squared confidence using Fisher transformation (approximate)
    if (tx_summary$r.squared > 0.1) {
      r <- sqrt(tx_summary$r.squared)
      n <- nrow(tx_scaling_data)
      fisher_z <- 0.5 * log((1 + r) / (1 - r))
      se_z <- 1 / sqrt(n - 3)
      z_lower <- fisher_z - 1.96 * se_z
      z_upper <- fisher_z + 1.96 * se_z
      r_lower <- (exp(2 * z_lower) - 1) / (exp(2 * z_lower) + 1)
      r_upper <- (exp(2 * z_upper) - 1) / (exp(2 * z_upper) + 1)
      rsq_lower <- r_lower^2
      rsq_upper <- r_upper^2
      cat("  R-squared:", sprintf("%.4f", tx_summary$r.squared),
          "[", sprintf("%.4f", max(0, rsq_lower)), ",", sprintf("%.4f", min(1, rsq_upper)), "]\n")
    }
  }
  
  # Subscription scaling confidence intervals
  if (exists("sub_summary") && nrow(sub_scaling_data) > 3) {
    sub_confint <- confint(sub_model, level = 0.95)
    cat("Subscription scaling (95% CI):\n")
    cat("  Slope:", sprintf("%.6f", sub_summary$coefficients[2, 1]),
        "[", sprintf("%.6f", sub_confint[2, 1]), ",", sprintf("%.6f", sub_confint[2, 2]), "]\n")
  }
}

# 3. PERFORMANCE MODEL FITTING
cat("\n=== Performance Model Fitting ===\n")

if (nrow(tx_scaling_data) > 3) {
  # Test different models: constant, linear, logarithmic
  tx_data_clean <- tx_scaling_data %>% 
    filter(tx_count > 0, insertion_throughput_eps > 0)
  
  models <- list(
    constant = lm(insertion_throughput_eps ~ 1, data = tx_data_clean),
    linear = lm(insertion_throughput_eps ~ tx_count, data = tx_data_clean),
    log = lm(insertion_throughput_eps ~ log(tx_count), data = tx_data_clean)
  )
  
  # Compare models using AIC
  model_comparison <- data.frame(
    model = names(models),
    aic = sapply(models, AIC),
    r_squared = sapply(models, function(m) summary(m)$r.squared)
  )
  model_comparison <- model_comparison[order(model_comparison$aic), ]
  
  cat("Model Comparison (lower AIC is better):\n")
  print(model_comparison, row.names = FALSE)
  
  best_model <- model_comparison$model[1]
  cat("\nBest model:", best_model, "\n")
  
  if (best_model == "constant") {
    cat("→ Performance is CONSTANT - O(1) scaling\n")
  } else if (best_model == "linear") {
    cat("→ Performance scales LINEARLY - O(n) scaling\n")
  } else if (best_model == "log") {
    cat("→ Performance scales LOGARITHMICALLY - O(log n) scaling\n")
  }
}

# 4. GENERATE VISUALIZATIONS
cat("\n=== Generating Visualizations ===\n")

# Plot 1: Transaction Scaling
if (nrow(tx_scaling_data) > 1) {
  p1 <- ggplot(tx_scaling_data, aes(x = tx_count, y = insertion_throughput_eps)) +
    geom_point(size = 3, alpha = 0.7) +
    geom_smooth(method = "lm", se = TRUE, color = "red") +
    scale_x_continuous(labels = comma_format()) +
    scale_y_continuous(labels = comma_format()) +
    labs(
      title = "Transaction Scaling Performance",
      x = "Number of Transactions", 
      y = "Insertion Throughput (events/sec)",
      subtitle = paste("R² =", round(summary(lm(insertion_throughput_eps ~ tx_count, data = tx_scaling_data))$r.squared, 3))
    ) +
    theme_minimal()
  
  ggsave(file.path(output_dir, "transaction_scaling.png"), p1, width = 10, height = 6, dpi = 300)
  cat("✓ Saved transaction_scaling.png\n")
}

# Plot 2: Subscription Scaling
if (nrow(sub_scaling_data) > 1) {
  p2 <- ggplot(sub_scaling_data, aes(x = sub_count, y = insertion_throughput_eps)) +
    geom_point(size = 3, alpha = 0.7) +
    geom_smooth(method = "lm", se = TRUE, color = "blue") +
    labs(
      title = "Subscription Scaling Performance", 
      x = "Number of Subscriptions",
      y = "Insertion Throughput (events/sec)",
      subtitle = paste("R² =", round(summary(lm(insertion_throughput_eps ~ sub_count, data = sub_scaling_data))$r.squared, 3))
    ) +
    theme_minimal()
  
  ggsave(file.path(output_dir, "subscription_scaling.png"), p2, width = 10, height = 6, dpi = 300)
  cat("✓ Saved subscription_scaling.png\n")
}

# Plot 3: 3D Surface Plot (if enough data)
if (nrow(multi_data) > 10) {
  p3 <- ggplot(multi_data, aes(x = tx_count, y = sub_count, fill = insertion_throughput_eps)) +
    geom_tile() +
    scale_fill_gradient2(low = "red", mid = "yellow", high = "green", 
                        midpoint = median(multi_data$insertion_throughput_eps),
                        name = "Throughput\n(eps)") +
    scale_x_continuous(labels = comma_format()) +
    labs(
      title = "Performance Heat Map",
      x = "Transaction Count",
      y = "Subscription Count",
      subtitle = "Insertion throughput across different load combinations"
    ) +
    theme_minimal()
  
  ggsave(file.path(output_dir, "performance_heatmap.png"), p3, width = 12, height = 8, dpi = 300)
  cat("✓ Saved performance_heatmap.png\n")
}

# Plot 4: Scenario Comparison
scenario_summary <- data %>%
  group_by(scenario) %>%
  summarise(
    mean_throughput = mean(insertion_throughput_eps, na.rm = TRUE),
    sd_throughput = sd(insertion_throughput_eps, na.rm = TRUE),
    n = n(),
    .groups = "drop"
  ) %>%
  filter(n > 1)

if (nrow(scenario_summary) > 1) {
  p4 <- ggplot(scenario_summary, aes(x = reorder(scenario, mean_throughput), y = mean_throughput)) +
    geom_col(fill = "steelblue", alpha = 0.7) +
    geom_errorbar(aes(ymin = mean_throughput - sd_throughput, 
                     ymax = mean_throughput + sd_throughput), 
                  width = 0.2) +
    coord_flip() +
    scale_y_continuous(labels = comma_format()) +
    labs(
      title = "Performance by Scenario",
      x = "Benchmark Scenario", 
      y = "Mean Insertion Throughput (events/sec)"
    ) +
    theme_minimal()
  
  ggsave(file.path(output_dir, "scenario_comparison.png"), p4, width = 12, height = 8, dpi = 300)
  cat("✓ Saved scenario_comparison.png\n")
}

# Plot 5: Phase 3 Advanced Metrics Visualizations
if (length(available_phase3_cols) > 0) {
  cat("Generating Phase 3 advanced metrics plots...\n")
  
  # Plot 5A: Latency Percentiles Distribution
  if ("latency_p50_ms" %in% available_phase3_cols && "latency_p99_ms" %in% available_phase3_cols) {
    latency_plot_data <- data %>%
      filter(!is.na(latency_p50_ms), !is.na(latency_p99_ms), latency_p50_ms > 0) %>%
      select(tx_count, sub_count, latency_p50_ms, latency_p95_ms, latency_p99_ms, latency_p999_ms) %>%
      gather(key = "percentile", value = "latency_ms", latency_p50_ms:latency_p999_ms, na.rm = TRUE) %>%
      mutate(percentile = factor(percentile, 
                                levels = c("latency_p50_ms", "latency_p95_ms", "latency_p99_ms", "latency_p999_ms"),
                                labels = c("P50", "P95", "P99", "P99.9")))
    
    if (nrow(latency_plot_data) > 0) {
      p5a <- ggplot(latency_plot_data, aes(x = tx_count, y = latency_ms, color = percentile)) +
        geom_point(size = 2, alpha = 0.7) +
        geom_smooth(method = "loess", se = FALSE) +
        scale_x_continuous(labels = comma_format()) +
        scale_color_viridis_d() +
        labs(
          title = "Latency Percentiles vs Transaction Count",
          x = "Number of Transactions",
          y = "Latency (ms)",
          color = "Percentile",
          subtitle = "Event delivery latency distribution across load levels"
        ) +
        theme_minimal()
      
      ggsave(file.path(output_dir, "latency_percentiles.png"), p5a, width = 12, height = 8, dpi = 300)
      cat("✓ Saved latency_percentiles.png\n")
    }
  }
  
  # Plot 5B: Memory Usage Scaling
  if ("peak_memory_mb" %in% available_phase3_cols && "initial_memory_mb" %in% available_phase3_cols) {
    memory_plot_data <- data %>%
      filter(!is.na(peak_memory_mb), !is.na(initial_memory_mb)) %>%
      mutate(memory_growth_mb = peak_memory_mb - initial_memory_mb,
             memory_growth_pct = (memory_growth_mb / initial_memory_mb) * 100)
    
    if (nrow(memory_plot_data) > 0) {
      p5b <- ggplot(memory_plot_data, aes(x = tx_count, y = peak_memory_mb)) +
        geom_point(aes(size = memory_growth_mb, color = sub_count), alpha = 0.7) +
        geom_smooth(method = "lm", se = TRUE, color = "red") +
        scale_x_continuous(labels = comma_format()) +
        scale_color_viridis_c(name = "Subscriptions") +
        scale_size_continuous(name = "Memory\nGrowth (MB)") +
        labs(
          title = "Memory Usage Scaling",
          x = "Number of Transactions",
          y = "Peak Memory Usage (MB)",
          subtitle = "Memory consumption vs load (bubble size = memory growth)"
        ) +
        theme_minimal()
      
      ggsave(file.path(output_dir, "memory_scaling.png"), p5b, width = 12, height = 8, dpi = 300)
      cat("✓ Saved memory_scaling.png\n")
    }
  }
  
  # Plot 5C: GC Overhead Analysis
  if ("gc_count" %in% available_phase3_cols && "gc_time_ms" %in% available_phase3_cols) {
    gc_plot_data <- data %>%
      filter(!is.na(gc_count), !is.na(gc_time_ms), gc_count > 0) %>%
      mutate(avg_gc_time = gc_time_ms / gc_count,
             total_events = tx_count * events_per_tx,
             gc_overhead_pct = (gc_time_ms / insertion_time_ms) * 100)
    
    if (nrow(gc_plot_data) > 0 && "insertion_time_ms" %in% colnames(gc_plot_data)) {
      p5c <- ggplot(gc_plot_data, aes(x = total_events, y = gc_overhead_pct)) +
        geom_point(aes(color = gc_count), size = 3, alpha = 0.7) +
        geom_smooth(method = "lm", se = TRUE, color = "red") +
        scale_x_continuous(labels = comma_format()) +
        scale_color_viridis_c(name = "GC Count") +
        labs(
          title = "Garbage Collection Overhead",
          x = "Total Events Processed",
          y = "GC Time as % of Total Runtime",
          subtitle = "Memory management overhead scaling with load"
        ) +
        theme_minimal()
      
      ggsave(file.path(output_dir, "gc_overhead.png"), p5c, width = 12, height = 8, dpi = 300)
      cat("✓ Saved gc_overhead.png\n")
    }
  }
  
  # Plot 5D: Queue Depth and Subscription Lag
  if ("avg_queue_depth" %in% available_phase3_cols && "subscription_lag_ms" %in% available_phase3_cols) {
    queue_plot_data <- data %>%
      filter(!is.na(avg_queue_depth), !is.na(subscription_lag_ms), sub_count > 0)
    
    if (nrow(queue_plot_data) > 0) {
      p5d <- ggplot(queue_plot_data, aes(x = avg_queue_depth, y = subscription_lag_ms)) +
        geom_point(aes(color = sub_count, size = tx_count), alpha = 0.7) +
        geom_smooth(method = "lm", se = TRUE, color = "red") +
        scale_color_viridis_c(name = "Subscriptions") +
        scale_size_continuous(name = "Transactions", labels = comma_format()) +
        labs(
          title = "Queue Depth vs Subscription Lag",
          x = "Average Queue Depth",
          y = "Subscription Lag (ms)",
          subtitle = "Event processing backlog relationship"
        ) +
        theme_minimal()
      
      ggsave(file.path(output_dir, "queue_lag_analysis.png"), p5d, width = 12, height = 8, dpi = 300)
      cat("✓ Saved queue_lag_analysis.png\n")
    }
  }
}

# 5. GENERATE ANALYSIS REPORT
cat("\n=== Generating Analysis Report ===\n")

report_file <- file.path(output_dir, "analysis_report.txt")
sink(report_file)

cat("Hindsight PostgreSQL Performance Analysis Report\n")
cat("===============================================\n")
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("Input file:", csv_file, "\n")
cat("Records analyzed:", nrow(data), "\n\n")

cat("SUMMARY STATISTICS\n")
cat("------------------\n")
cat("Transaction range:", min(data$tx_count), "to", max(data$tx_count), "\n")
cat("Subscription range:", min(data$sub_count), "to", max(data$sub_count), "\n")
cat("Throughput range:", round(min(data$insertion_throughput_eps, na.rm=TRUE)), "to", 
    round(max(data$insertion_throughput_eps, na.rm=TRUE)), "events/sec\n")
cat("Mean throughput:", round(mean(data$insertion_throughput_eps, na.rm=TRUE)), "events/sec\n\n")

if (exists("tx_summary")) {
  cat("TRANSACTION SCALING\n")
  cat("------------------\n")
  cat("R-squared:", round(tx_summary$r.squared, 4), "\n")
  cat("Slope:", round(tx_summary$coefficients[2, 1], 6), "eps per transaction\n")
  cat("P-value:", format.pval(tx_summary$coefficients[2, 4]), "\n\n")
}

if (exists("sub_summary")) {
  cat("SUBSCRIPTION SCALING\n") 
  cat("-------------------\n")
  cat("R-squared:", round(sub_summary$r.squared, 4), "\n")
  cat("Slope:", round(sub_summary$coefficients[2, 1], 6), "eps per subscription\n")
  cat("P-value:", format.pval(sub_summary$coefficients[2, 4]), "\n\n")
}

if (exists("biv_summary")) {
  cat("BIVARIATE MODEL\n")
  cat("---------------\n")
  cat("R-squared:", round(biv_summary$r.squared, 4), "\n")
  cat("Adjusted R-squared:", round(biv_summary$adj.r.squared, 4), "\n")
  cat("Transaction coefficient:", round(biv_summary$coefficients[2, 1], 6), "\n")
  cat("Subscription coefficient:", round(biv_summary$coefficients[3, 1], 6), "\n\n")
}

if (exists("model_comparison")) {
  cat("MODEL COMPARISON\n")
  cat("---------------\n")
  print(model_comparison, row.names = FALSE)
  cat("\nBest model:", model_comparison$model[1], "\n")
}

# Phase 3 Advanced Metrics Summary
if (length(available_phase3_cols) > 0) {
  cat("\nADVANCED METRICS (PHASE 3)\n")
  cat("--------------------------\n")
  cat("Available metrics:", length(available_phase3_cols), "of", length(phase3_cols), "columns\n")
  
  # Latency Summary
  if ("latency_p50_ms" %in% available_phase3_cols) {
    latency_summary_data <- data %>% filter(!is.na(latency_p50_ms), latency_p50_ms > 0)
    if (nrow(latency_summary_data) > 0) {
      cat("\nLatency Analysis:\n")
      cat("  Records with latency data:", nrow(latency_summary_data), "\n")
      
      p50_summary <- summary(latency_summary_data$latency_p50_ms)
      cat("  Median P50 latency:", sprintf("%.2f", p50_summary["Median"]), "ms\n")
      
      if ("latency_p99_ms" %in% available_phase3_cols) {
        p99_summary <- summary(latency_summary_data$latency_p99_ms)
        cat("  Median P99 latency:", sprintf("%.2f", p99_summary["Median"]), "ms\n")
      }
      
      # Latency-throughput correlation
      lat_thr_cor <- cor(latency_summary_data$latency_p50_ms, latency_summary_data$insertion_throughput_eps, use = "complete.obs")
      cat("  Latency-Throughput correlation:", sprintf("%.3f", lat_thr_cor), "\n")
    }
  }
  
  # Memory Summary
  if ("peak_memory_mb" %in% available_phase3_cols) {
    memory_summary_data <- data %>% filter(!is.na(peak_memory_mb))
    if (nrow(memory_summary_data) > 0) {
      cat("\nMemory Analysis:\n")
      cat("  Records with memory data:", nrow(memory_summary_data), "\n")
      
      mem_summary <- summary(memory_summary_data$peak_memory_mb)
      cat("  Median peak memory:", sprintf("%.1f", mem_summary["Median"]), "MB\n")
      cat("  Memory range:", sprintf("%.1f", mem_summary["Min."]), "-", sprintf("%.1f", mem_summary["Max."]), "MB\n")
      
      if ("gc_time_ms" %in% available_phase3_cols) {
        gc_summary_data <- memory_summary_data %>% filter(!is.na(gc_time_ms), gc_time_ms > 0)
        if (nrow(gc_summary_data) > 0) {
          avg_gc_time <- mean(gc_summary_data$gc_time_ms, na.rm = TRUE)
          cat("  Average GC overhead:", sprintf("%.1f", avg_gc_time), "ms per benchmark\n")
        }
      }
    }
  }
  
  # Queue Summary  
  if ("avg_queue_depth" %in% available_phase3_cols || "subscription_lag_ms" %in% available_phase3_cols) {
    queue_summary_data <- data %>% filter(!is.na(avg_queue_depth) | !is.na(subscription_lag_ms))
    if (nrow(queue_summary_data) > 0) {
      cat("\nQueue Metrics Analysis:\n")
      cat("  Records with queue data:", nrow(queue_summary_data), "\n")
      
      if ("avg_queue_depth" %in% available_phase3_cols) {
        depth_summary <- summary(queue_summary_data$avg_queue_depth[!is.na(queue_summary_data$avg_queue_depth)])
        if (length(depth_summary) > 0) {
          cat("  Median queue depth:", sprintf("%.1f", depth_summary["Median"]), "\n")
        }
      }
      
      if ("subscription_lag_ms" %in% available_phase3_cols) {
        lag_summary <- summary(queue_summary_data$subscription_lag_ms[!is.na(queue_summary_data$subscription_lag_ms)])
        if (length(lag_summary) > 0) {
          cat("  Median subscription lag:", sprintf("%.1f", lag_summary["Median"]), "ms\n")
          
          # High lag warnings
          high_lag_count <- sum(queue_summary_data$subscription_lag_ms > 1000, na.rm = TRUE)
          if (high_lag_count > 0) {
            cat("  HIGH LAG WARNING:", high_lag_count, "measurements >1000ms\n")
          }
        }
      }
      
      if ("queue_overflow_count" %in% available_phase3_cols) {
        total_overflows <- sum(queue_summary_data$queue_overflow_count, na.rm = TRUE)
        cat("  Total queue overflows:", total_overflows, "\n")
      }
    }
  }
}

sink()

cat("✓ Saved analysis_report.txt\n")

cat("\n=== Analysis Complete ===\n")
cat("Files generated in:", output_dir, "\n")
cat("- analysis_report.txt (detailed statistical results)\n") 
cat("- *.png (visualization plots)\n")

# List available plots based on what was generated
cat("\nGenerated visualizations:\n")
cat("- transaction_scaling.png (throughput vs transaction count)\n")
cat("- subscription_scaling.png (throughput vs subscription count)\n") 
cat("- performance_heatmap.png (2D performance surface)\n")
cat("- scenario_comparison.png (performance by scenario)\n")

if (length(available_phase3_cols) > 0) {
  cat("- Phase 3 Advanced Metrics Plots:\n")
  if ("latency_p50_ms" %in% available_phase3_cols) {
    cat("  • latency_percentiles.png (P50/P95/P99 latency analysis)\n")
  }
  if ("peak_memory_mb" %in% available_phase3_cols) {
    cat("  • memory_scaling.png (memory usage vs load)\n")
  }
  if ("gc_count" %in% available_phase3_cols) {
    cat("  • gc_overhead.png (garbage collection overhead analysis)\n")
  }
  if ("avg_queue_depth" %in% available_phase3_cols) {
    cat("  • queue_lag_analysis.png (queue depth vs subscription lag)\n")
  }
}

cat("\nTo view plots, open the PNG files in", output_dir, "\n")
cat("For detailed metrics interpretation, see the analysis_report.txt\n")