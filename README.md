# Pinus mugo mapping in the Bavarian Alps — analysis code

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
<!-- After cutting the Zenodo release, replace ZENODO_CODE_DOI below with the minted software DOI -->
[![DOI](https://zenodo.org/badge/DOI/ZENODO_CODE_DOI.svg)](https://doi.org/ZENODO_CODE_DOI)

Research code accompanying the manuscript on Random Forest mapping of mountain pine
(*Pinus mugo*) from Sentinel-2 and UAS imagery in the Bavarian Alps.

This is **research code provided for transparency and reproducibility**, not a packaged
software library. It is organised by processing stage. Notebooks were run on Windows with
Jupyter; paths have been replaced by the placeholders `DATA_DIR` (project data root) and
`OUTPUT_DIR` (writable output folder) — set these at the top of each file before running.

The annual classified maps are archived separately on Zenodo (see the manuscript Data
Availability statement). This repository contains the code that produces them.

## Pipeline stages

| File | Stage | Manuscript section |
|------|-------|--------------------|
| `notebooks/00_gee_export_sentinel2.ipynb` | Sentinel-2 cloud/snow masking, June–October monthly composites, NDVI & NARI, export per mosaic/year (2017–2025) | Methods — S2 acquisition & preprocessing |
| `scripts/01_glcm_textures.R` | GLCM Haralick textures (homogeneity, contrast, entropy, mean, variance; 4 directions; 9×9 window; 32 grey levels) on the NIR stack | Methods — Textural features |
| `notebooks/01b_ndvi_phenology_metrics.ipynb` | Three NDVI phenology metrics (seasonal range, summer mean, autumn decline; F56–F58) from the monthly NDVI stack; B1 (seasonal range) is retained in the final feature set | Methods — NDVI phenology features |
| `notebooks/02_raster_stacking.ipynb` | Tile mosaicking, band extraction/renaming, assembly of the multiband feature stack | Methods — Feature stack construction |
| `notebooks/03_sampling_train_classify_filter_validate.ipynb` | NDVI-guided point sampling, feature extraction at points, mosaic training-table merge, RF training on the selected features, per-mosaic classification, mosaic merge into the annual map, temporal filtering to the permanent layer, map validation | Methods — Sampling, classification, temporal filtering, validation |
| `notebooks/04_feature_selection_leakage_free.ipynb` | Feature selection performed within each CV fold; produces `selected_features_final.csv` | Methods — Feature selection |
| `notebooks/05_spatial_validation.ipynb` | Polygon-grouped split (base method) + spatial-block CV sweep, 1–25 km | Methods — Spatially-independent validation |

## Which files produce the reported numbers

- **Reported model accuracy / uncertainty:** notebooks **04** (feature selection) and
  **05** (spatial validation). These are the numbers in the manuscript.
- **Deployed yearly maps:** notebook **03** trains the Random Forest on the 30-feature set
  fixed by notebook 04 and classifies each mosaic. The in-notebook training accuracy in 03
  is **not** the reported performance — it is only the fit used to generate the rasters.

This separation is deliberate: selection and validation are evaluated within
cross-validation and with spatially independent splits; deployment uses the committed
feature list.

## Order of execution

`00` (GEE export) → `01` (GLCM) + `01b` (NDVI phenology metrics) → `02` (stacking) →
`04` (selection, writes the feature list) → `03` (train/classify/filter/validate using that
list) → `05` (spatial validation, independent of the deployment run).

## Environment

See `environment.yml` (Python) and the header of `scripts/01_glcm_textures.R` (R packages).
Random seeds are fixed (`random_state=42`) where applicable; minor numerical differences
across library versions are expected.

## Not included

- Reference / validation point coordinates — see Data Availability statement
  (`DATA_AVAILABILITY.md`) for access conditions.
- Manual steps: project folder creation and a small number of one-off file moves were done
  by hand and are described in the relevant notebook markdown.
