# STOAT Introduction

## Summary

The Spatiotemporal Observation Annotation Tool (STOAT) is a platform for the annotation of spatiotemporal biodiversity data (e.g. occurrence records) with values from remote sensing and other gridded environmental datasets. Environmental annotation is conducted by retrieving layer values associated with the spatiotemporal coordinates of biodiversity data. STOAT's cloud-based computations simplify and automate the environmental annotation process, eliminating the need for users to download or interface directly with complex environmental layers. STOAT brings versatile environmental annotations to the fingertips of a broader range of scientists, and contributes to analysis workflows for rapidly accumulating biodiversity and environmental data.

STOAT is hosted by Map of Life (https://mol.org) as part of its broader biodiversity informatics platform. Please see the STOAT project homepage at (https://mol.org/stoat).

rstoat is the R package interface to STOAT. rstoat allows for the easy integration of STOAT into existing R-based workflows, and provides all the core functionalities of the STOAT web application, most importantly the submission of annotation tasks, and the retrieval of annotation results. The public repository for rstoat can be found at: https://github.com/MapofLife/rstoat.

## Background

Advances in remote sensing combined with rapidly growing types and amounts of spatiotemporal biodiversity data now enable an unrivaled opportunity for planetary-scale monitoring of biodiversity change. This project builds on earlier developments of global remote-sensing-supported climate and environmental layers for biodiversity assessment, and represents a general workflow that allows for the environmental annotation, visualization, and change assessment for past and future spatiotemporal biodiversity occurrence data.

Observed, in-situ biodiversity data have intrinsic spatiotemporal grains and associated uncertainties based on observation methodology and data collection. Likewise, remotely-sensed environmental data also vary in spatiotemporal grain from meters to kilometers. This tool has the technical infrastructure and software workflows to develop and serve appropriate summaries of environmental data for biodiversity observations. For example, a list of migrating birds observed from one location one afternoon would require a different summary of environmental data than a list of vascular plants known to exist in a 100km2 protected area. This system draws from a near-real-time collection of RS and RS-derived environmental data (such as land surface temperature, precipitation, and vegetation indices) to enable both historical and near-real-time annotation of continuously updating biodiversity data streams.

The generalized software workflows and tools enable characterization and comparison of environmental associations of individuals, populations or species over time, globally. This will allow the quantification of observed environmental niches as well as the detection of change through time in both the environmental associations and geographic distributions of biodiversity.

## Environmental Data

The environmental data available through this tool come from a variety of sources, including remote sensing products (e.g. MODIS), and derived products created for a diversity of ecological purposes. Products are broken into categories depending on their temporal grain. We define dynamic products as those with finer-than-monthly temporal grain. Annual products are those with a layer per year (currently there are no layers in STOAT with a Monthly temporal grain, though that designation may be used in the future). Finally, static products are those with a single layer across all time scales. Layers provided on STOAT launch include:

*Layer, Spatial Grain, Temporal Grain*
* MODIS NDVI/EVI, 250m, 1-day
* MODIS LST Day/Night, 1km, 1-day
* Landsat 7 EVI, 30m, 16-day
* Landsat 8 EVI, 30m, 16-day
* CHELSA/EarthEnv Daily precipitation, 1km, 1-day
* ESA CCI land cover, 300m, Annual
* SRTM variables, 30m, Static
* TNC Global Human Modification, 1000m, Static
* MODIS Winter/Summer EVI, 1000m, Static
* EarthEnv layers (various), 1000m, Static

For a full and up-to-date list of layers available in STOAT, visit https://mol.org/stoat/sources.

### Processing

All derived environmental datasets, unless specified, are unmodified from their original sources. Environmental layers are hosted by [Descartes Labs](https://www.descarteslabs.com), an environmental data repository and refinery, as well as Google Earth Engine, and are accessed through a series of internal API calls. Documentation for all included datasets can be found at (https://mol.org/stoat/sources).

Remote sensing products such as MODIS and Landsat are filtered to keep only high quality observations (removing clouds and other poor quality data). Specific metadata for each product (including the quality control filtering) are provided with downloaded data.

## Biodiversity Data

Using the batch annotator, occurrence data should be first uploaded into an individual's Map of Life account before commencing annotation. Data for upload take the format of a CSV with columns for the species scientific name, latitude, longitude, and date (See https://mol.org/upload/ for more details). Data can come from a variety of sources. Online repositories such as GBIF provide huge quantities of species data free of charge. More frequently, a user may wish to annotate a private or personal dataset. Data uploaded can be marked as private to restrict access to only the data owner.

## Spatial and Temporal Buffers

STOAT provides customizable spatial and temporal buffers around annotated points. These buffers allow for users to control the effective grain size of their biodiversity data, allowing users to accommodate differences in data grain, data uncertainty, and the extents of studied ecological processes. Due to increased computational demands associated with larger buffer sizes, there are hard limits on the maximum buffer sizes: these limits vary by product and scale with the spatial and temporal grain of a product. In R, buffer limits can be viewed with the function get_products(); in the web application they represent the ends of the buffer slider. Tasks with buffer requests beyond limits will be rejected by the annotator. The units of spatial and temporal buffers are meters, and days, respectively. Static layers should be requested with a temporal buffer of 0 days.

## Attribution

STOAT was developed by the Map of Life team at Yale University in collaboration with researchers at the University of Florida and the University at Buffalo. The STOAT team can be contacted at (https://mol.org/contact-us) with any inquiries.

STOAT currently has a manuscript in review. More citation info will follow.

## Funding

Funding for the development of STOAT is provided by NASA grants AIST-16-0092 and AIST-18-0034, as well as NSF grant DEB-1441737.

# STOAT User Guide

For a full demonstration of the package's functionalities as well as example code, please see the Introduction vignette provided.

For answers to Frequently Asked Questions, please refer to the [STOAT website](https://mol.org/stoat/faq).

## Installation
To install rstoat, please run the following line of code (requires remotes package).

```r
remotes::install_github('mapoflife/rstoat', ref='main')
```

## Usage

To use STOAT, one must first [create a Map of Life account](https://auth.mol.org/register). Once an account has been created, a user can upload datasets to be annotated through the [Map of Life uploader](https://mol.org/upload/datasets). *At the current time, data upload must be carried out from the Map of Life website.* All further steps of the annotation process may be carried out either on the web application or in this R package. A list of functions is provided below, most notably "start_annotation_batch()"; see the Introduction vignette for example code.

Additionally, a simple annotation function "start_annotation_simple()"" is provided to allow for limited annotation capacity (1000 records) without the need to use the web interface of the Map of Life Uploader. This function has a significantly lower record limit, nor does it serve the complete set of layers provided by the full annotator, but finds use as a testing tool and convenient means of running a pilot annotation. The simple annotator is distinct in its code from the full annotator, utilizing Google Earth Engine rather than Descartes Labs as a data source. Slight discrepancies in annotations are attributable to this, though any severe discrepancies should be reported to the STOAT team. We strongly recommend use of the full annotator for research applications.

### Package Functions:

Login to your Map of Life account

```r
mol_login("your.email@address"")
```

List your Map of Life datasets:

```r
my_datasets()
```

Start a custom annotation job request: 

```r
start_annotation_batch("<dataset_id>", "My annotation task", layers = c("product-layer-sbuff-tbuff", "product-layer-sbuff-tbuff"))
```

Start a simple annotation request - these do not require use of the uploader, but have a lower limit of occurrences, for use for testing or with pilot data: 
```r
start_annotation_simple("<events_dataframe>", layers = c("product-layer-sbuff-tbuff", "product-layer-sbuff-tbuff"))
```

Get a list of environmental products available for annotation, along with limits to spatial and temporal buffers:

```r
get_products()
```

List your past and current annotation jobs:

```r
my_jobs()
```

Get details on a specific custom annotation job: 

```r
job_details("<annotation_id>")
```

Get a list of species that were annotated in a custom annotation request: 

```r
job_species("<annotation_id>")
```

Download completed results of a custom annotation request: 

```r
download_annotation("<annotation_id>")
```

Read and unpack the downloaded data into a single data.frame:

```r
read_output("path/to/your/extracted/annotation")
```

Download example data (used in vignette)

```r
download_example_data("destination/path")
```

