#!/usr/bin/env Rscript

# Hindsight Benchmark Analysis v2
# Multi-backend performance analysis for Memory, Filesystem, and PostgreSQL stores
# Usage: Rscript bench-v2/scripts/analyze.R benchmark-file.csv [output-dir]

library(ggplot2)
library(dplyr)
library(readr)
library(broom)
library(gridExtra)
library(scales)
library(tidyr)

# Parse command line arguments
args <- commandArgs(trailingOnly = TRUE)
if (length(args) < 1) {
  cat("Usage: Rscript bench-v2/scripts/analyze.R <csv-file> [output-directory]\n")
  cat("Example: Rscript bench-v2/scripts/analyze.R results.csv ./analysis\n")
  quit(status = 1)
}

csv_file <- args[1]
output_dir <- if (length(args) >= 2) args[2] else "bench-v2-analysis"

# Create output directory
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

cat("Hindsight Benchmark Analysis v2\n")
cat("===============================\n")
cat("Multi-backend performance comparison\n")
cat("Input file:", csv_file, "\n")
cat("Output directory:", output_dir, "\n\n")

# Load and preprocess data
tryCatch({
  data <- read_csv(csv_file, show_col_types = FALSE)
  cat("✓ Loaded", nrow(data), "benchmark records\n")
  
  # Show backend distribution
  backend_counts <- data %>% count(backend, sort = TRUE)
  cat("Backend distribution:\n")
  for (i in 1:nrow(backend_counts)) {
    cat("  -", backend_counts$backend[i], ":", backend_counts$n[i], "records\n")
  }
  cat("\n")
}, error = function(e) {
  cat("✗ Failed to load CSV file:", e$message, "\n")
  quit(status = 1)
})

# OUTLIER DETECTION AND DATA VALIDATION
cat("=== Data Validation and Outlier Detection ===\n")

# Function to detect outliers using IQR method per backend
detect_outliers_by_backend <- function(data, column_name) {
  outliers <- data.frame()
  
  for (backend_name in unique(data$backend)) {
    backend_data <- data[data$backend == backend_name, ]
    values <- backend_data[[column_name]]
    values <- values[!is.na(values) & is.finite(values)]
    
    if (length(values) < 4) next  # Need at least 4 points for IQR
    
    Q1 <- quantile(values, 0.25)
    Q3 <- quantile(values, 0.75)
    IQR <- Q3 - Q1
    
    lower_bound <- Q1 - 1.5 * IQR
    upper_bound <- Q3 + 1.5 * IQR
    
    outlier_mask <- backend_data[[column_name]] < lower_bound | backend_data[[column_name]] > upper_bound
    outlier_mask[is.na(outlier_mask)] <- FALSE
    
    if (any(outlier_mask)) {
      backend_outliers <- backend_data[outlier_mask, ]
      outliers <- rbind(outliers, backend_outliers)
    }
  }
  
  return(outliers)
}

# Detect outliers in throughput data
throughput_outliers <- detect_outliers_by_backend(data, "insertion_throughput_eps")

if (nrow(throughput_outliers) > 0) {
  cat("⚠️  Detected", nrow(throughput_outliers), "throughput outliers:\n")
  for (i in 1:nrow(throughput_outliers)) {
    row <- throughput_outliers[i, ]
    cat("  -", row$backend, ":", round(row$insertion_throughput_eps), "eps at", 
        row$tx_count, "tx,", row$sub_count, "subs (", row$scenario, ")\n")
  }
  cat("\n")
} else {
  cat("✓ No throughput outliers detected\n")
}

# BACKEND COMPARISON ANALYSIS
cat("=== Backend Performance Comparison ===\n")

# Summary statistics by backend
summary_stats <- data %>%
  group_by(backend) %>%
  summarise(
    avg_throughput = mean(insertion_throughput_eps, na.rm = TRUE),
    max_throughput = max(insertion_throughput_eps, na.rm = TRUE),
    min_throughput = min(insertion_throughput_eps, na.rm = TRUE),
    sd_throughput = sd(insertion_throughput_eps, na.rm = TRUE),
    records = n(),
    .groups = 'drop'
  ) %>%
  arrange(desc(avg_throughput))

cat("Backend Performance Summary (by average throughput):\n")
for (i in 1:nrow(summary_stats)) {
  row <- summary_stats[i, ]
  cat(sprintf("  %d. %s: %.0f ± %.0f eps (max: %.0f, records: %d)\n",
              i, row$backend, row$avg_throughput, row$sd_throughput, 
              row$max_throughput, row$records))
}
cat("\n")

# SCALING ANALYSIS
cat("=== Scaling Analysis ===\n")

# Transaction scaling by backend
tx_scaling_data <- data %>%
  filter(scenario %in% c("Transaction Scaling", "Detailed Insertion")) %>%
  filter(!is.na(tx_count) & tx_count > 0)

if (nrow(tx_scaling_data) > 0) {
  cat("Transaction Scaling Analysis:\n")
  
  # Fit regression models for each backend
  for (backend_name in unique(tx_scaling_data$backend)) {
    backend_data <- tx_scaling_data[tx_scaling_data$backend == backend_name, ]
    
    if (nrow(backend_data) < 3) {
      cat("  ", backend_name, ": Insufficient data for scaling analysis\n")
      next
    }
    
    # Fit linear model
    model <- lm(insertion_throughput_eps ~ tx_count, data = backend_data)
    model_summary <- summary(model)
    
    cat(sprintf("  %s: R² = %.3f, slope = %.2f eps/tx (p = %.4f)\n",
                backend_name, 
                model_summary$r.squared,
                coef(model)[2],
                coef(model_summary)[2, 4]))  # p-value for slope
  }
  cat("\n")
}

# VISUALIZATION
cat("=== Generating Visualizations ===\n")

# 1. Backend throughput comparison
p1 <- ggplot(data, aes(x = backend, y = insertion_throughput_eps, fill = backend)) +
  geom_boxplot(alpha = 0.7) +
  scale_y_continuous(labels = comma) +
  labs(
    title = "Throughput Comparison Across Backends",
    subtitle = "Events per second distribution",
    x = "Backend",
    y = "Insertion Throughput (eps)",
    fill = "Backend"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

ggsave(file.path(output_dir, "backend_comparison.png"), p1, width = 10, height = 6, dpi = 300)
cat("✓ Created backend_comparison.png\n")

# 2. Transaction scaling by backend
if (nrow(tx_scaling_data) > 0) {
  p2 <- ggplot(tx_scaling_data, aes(x = tx_count, y = insertion_throughput_eps, color = backend)) +
    geom_point(alpha = 0.6) +
    geom_smooth(method = "lm", se = TRUE) +
    scale_x_log10(labels = comma) +
    scale_y_continuous(labels = comma) +
    labs(
      title = "Transaction Scaling by Backend",
      subtitle = "Throughput vs transaction count (log scale)",
      x = "Transaction Count (log scale)",
      y = "Insertion Throughput (eps)",
      color = "Backend"
    ) +
    theme_minimal()
  
  ggsave(file.path(output_dir, "transaction_scaling.png"), p2, width = 10, height = 6, dpi = 300)
  cat("✓ Created transaction_scaling.png\n")
}

# 3. Memory usage comparison (if available)
memory_data <- data %>% filter(!is.na(peak_memory_mb))
if (nrow(memory_data) > 0) {
  p3 <- ggplot(memory_data, aes(x = backend, y = peak_memory_mb, fill = backend)) +
    geom_boxplot(alpha = 0.7) +
    labs(
      title = "Memory Usage Comparison",
      subtitle = "Peak memory consumption by backend",
      x = "Backend",
      y = "Peak Memory (MB)",
      fill = "Backend"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggsave(file.path(output_dir, "memory_comparison.png"), p3, width = 10, height = 6, dpi = 300)
  cat("✓ Created memory_comparison.png\n")
}

# 4. Scenario performance heatmap
scenario_summary <- data %>%
  group_by(backend, scenario) %>%
  summarise(avg_throughput = mean(insertion_throughput_eps, na.rm = TRUE), .groups = 'drop') %>%
  filter(!is.na(avg_throughput))

if (nrow(scenario_summary) > 0) {
  p4 <- ggplot(scenario_summary, aes(x = scenario, y = backend, fill = avg_throughput)) +
    geom_tile() +
    scale_fill_gradient(low = "white", high = "darkblue", labels = comma) +
    labs(
      title = "Performance Heatmap by Scenario and Backend",
      subtitle = "Average throughput (darker = higher)",
      x = "Scenario",
      y = "Backend", 
      fill = "Throughput\n(eps)"
    ) +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  ggsave(file.path(output_dir, "performance_heatmap.png"), p4, width = 12, height = 6, dpi = 300)
  cat("✓ Created performance_heatmap.png\n")
}

# GENERATE ANALYSIS REPORT
cat("✓ Generating analysis report...\n")

report_file <- file.path(output_dir, "analysis_report.txt")
sink(report_file)

cat("Hindsight Benchmark Analysis Report v2\n")
cat("======================================\n")
cat("Generated:", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
cat("Input file:", csv_file, "\n\n")

cat("DATASET OVERVIEW\n")
cat("----------------\n")
cat("Total records:", nrow(data), "\n")
cat("Backends tested:", paste(unique(data$backend), collapse = ", "), "\n")
cat("Scenarios:", paste(unique(data$scenario), collapse = ", "), "\n")
cat("Date range:", min(data$timestamp, na.rm = TRUE), "to", max(data$timestamp, na.rm = TRUE), "\n\n")

cat("BACKEND PERFORMANCE RANKING\n")
cat("---------------------------\n")
for (i in 1:nrow(summary_stats)) {
  row <- summary_stats[i, ]
  cat(sprintf("%d. %s: %.0f ± %.0f eps (coefficient of variation: %.2f%%)\n",
              i, row$backend, row$avg_throughput, row$sd_throughput,
              (row$sd_throughput / row$avg_throughput) * 100))
}
cat("\n")

# Performance recommendations
cat("PERFORMANCE INSIGHTS\n")
cat("-------------------\n")

best_backend <- summary_stats$backend[1]
worst_backend <- summary_stats$backend[nrow(summary_stats)]
improvement_ratio <- summary_stats$avg_throughput[1] / summary_stats$avg_throughput[nrow(summary_stats)]

cat("• Best performing backend:", best_backend, "\n")
cat("• Lowest performing backend:", worst_backend, "\n")
cat("• Performance gap:", sprintf("%.1fx improvement", improvement_ratio), "\n")

# Memory analysis if available
if (nrow(memory_data) > 0) {
  memory_summary <- memory_data %>%
    group_by(backend) %>%
    summarise(avg_memory = mean(peak_memory_mb, na.rm = TRUE), .groups = 'drop') %>%
    arrange(avg_memory)
  
  cat("• Most memory efficient:", memory_summary$backend[1], 
      sprintf(" (%.0f MB average)", memory_summary$avg_memory[1]), "\n")
  cat("• Highest memory usage:", memory_summary$backend[nrow(memory_summary)],
      sprintf(" (%.0f MB average)", memory_summary$avg_memory[nrow(memory_summary)]), "\n")
}

# Scaling insights
if (nrow(tx_scaling_data) > 0) {
  cat("• Transaction scaling analysis completed for", length(unique(tx_scaling_data$backend)), "backends\n")
}

cat("\nRECOMMendations:\n")
cat("- Use", best_backend, "for maximum throughput\n")
if (nrow(memory_data) > 0) {
  cat("- Consider", memory_summary$backend[1], "for memory-constrained environments\n")
}
cat("- Review outliers for potential performance optimizations\n")

sink()

cat("✓ Analysis complete! Results saved to:", output_dir, "\n")
cat("✓ View analysis_report.txt for detailed insights\n")
cat("✓ Generated", length(list.files(output_dir, pattern = "\\.png$")), "visualization(s)\n")