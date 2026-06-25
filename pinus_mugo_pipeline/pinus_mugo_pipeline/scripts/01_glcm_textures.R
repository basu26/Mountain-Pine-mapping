# 01 - GLCM texture features from the NIR composite stack
# Computes 5 Haralick textures (homogeneity, contrast, entropy, mean, variance)
# over 4 directions on each band of the NIR stack, 9x9 window, 32 gray levels.
# Manuscript: Methods - Textural features.
#
# EDIT THESE TWO PATHS before running:
#   OUTPUT_DIR     : folder where GLCM rasters are written
#   nir_stack_path : the merged NIR composite for the mosaic being processed
# ---------------------------------------------------------------

options(warn=-1)  # Suppress warnings

library(glcm)
library(raster)
library(stringr)

options(warn=0)   # Re-enable warnings

# === PARAMETERS ===
window_size <- c(9, 9)
distances <- 1
shifts <- list(c(0, 1), c(1, 1), c(1, 0), c(1, -1))  # 0°, 45°, 90°, 135°
glcm_features <- c("homogeneity", "contrast", "entropy", "mean", "variance")
output_folder <- "OUTPUT_DIR/Sentinel2_GLCM/"   # <-- edit

# === INPUT ===
nir_stack_path <- "DATA_DIR/NIR_stack_mosaicX_YEAR.tif"   # <-- edit per mosaic/year
nir_stack <- stack(nir_stack_path)

# === Create output folder
dir.create(output_folder, showWarnings = FALSE, recursive = TRUE)

# === Track time
start_time <- Sys.time()

# === Process each band in the NIR stack
for (i in 1:nlayers(nir_stack)) {
  cat("\n📦 Processing Band", i, "...\n")
  
  s2_nir <- nir_stack[[i]]
  
  # === PREPROCESSING ===
  cat("🔍 Preprocessing NIR band...\n")
  s2_nir[s2_nir == 0] <- NA                 # Mask invalid 0 values
  s2_nir <- s2_nir / 10000                  # Convert to reflectance (0.0–1.0)
  s2_nir <- round(s2_nir * 31)              # Quantize to 32 gray levels (0–31)
  
  # === GLCM Computation ===
  cat("⚙️  Computing GLCM features...\n")
  s2_nir_glcm <- glcm(
    s2_nir,
    window = window_size,
    shift = shifts,
    statistics = glcm_features,
    na_opt = "center"  # Only compute if center pixel is valid
  )
  
  # === Save each GLCM layer
  for (feature in names(s2_nir_glcm)) {
    output_path <- file.path(output_folder, paste0("NIR_GLCM_T", i, "_", feature, ".tif"))
    writeRaster(s2_nir_glcm[[feature]], filename = output_path, format = "GTiff", overwrite = TRUE)
    cat("✅ Saved:", output_path, "\n")
  }
  
  # === Clear temporary files to free RAM
  unlink(paste0(normalizePath(tempdir()), "/", dir(tempdir())), recursive = TRUE)
  cat("🧹 Cleared temporary files for Band", i, "\n")
}

# === Done
end_time <- Sys.time()
cat("\n✅ All GLCM features computed in", round(end_time - start_time, 2), "seconds.\n")
