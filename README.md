# melanogaster-pergola-reproduce.nf

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1400728.svg)](https://doi.org/10.5281/zenodo.1400728)
![CircleCI status](https://circleci.com/gh/cbcrg/melanogaster-pergola-reproduce.png?style=shield)
[![nextflow](https://img.shields.io/badge/nextflow-%E2%89%A50.20.0-brightgreen.svg)](http://nextflow.io)

This repository contains the software, scripts and data to reproduce the results corresponding to the *D. melanogaster* experiment of the Pergola paper.

If you have not install yet [docker](https://www.docker.com/) and [nextflow](https://www.nextflow.io/), follow this [intructions](https://github.com/cbcrg/pergola-reproduce/blob/master/README.md)

## Clone the repository

```bash
git clone --recursive https://github.com/cbcrg/melanogaster-pergola-reproduce.git
cd melanogaster-pergola-reproduce
```

## Data

Data is publicly available in [Zenodo](https://zenodo.org/) as a compressed tarball [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1067835.svg)](https://doi.org/10.5281/zenodo.1067835).

Data can be downloaded and uncompressed using the following command:

```bash
mkdir data
wget -O- https://zenodo.org/record/1400728/files/melanogaster_dataset.tar.gz | tar xz -C data
```

#### Original Data Sources
The original data can be downloaded from the following [source](https://sourceforge.net/projects/jaaba/files/Sample%20Data/sampledata_v0.1.zip/download). This data has to be processes using 
[Jaaba](http://jaaba.sourceforge.net/) to annotated chase behavior from the video recordings available on this link.
 
## Pull docker image
Pull the Docker image use for processing data with Pergola (Pergola and its dependencies installed)

```bash
docker pull pergola/pergola-reproduce@sha256:02bf3e701175104a488f40761b856efa1f97e2f2f82af8adae63b24ac2517326
```

## Run nextflow pipeline
Once data is downloaded, it is possible to reproduce all the results using this command:

```bash
NXF_VER=0.30.2 nextflow run melanogaster-pergola-reproduce.nf \
    --scores='data/scores/scores_chase_*.mat' \
    --var_dir='data/perframe_*' \
    --variables="all" \
    --mappings='data/mappings/jaaba2pergola.txt' \
    --output='results' \
    --image_format='png' \
    -with-docker
```

##  Results

The previous command generates a results folder that contains the plots used in the paper figure:

* A boxplot comparing the fraction of time performing chase behavior of the GAL4 mutant and the control group   
* Two figures created using [Gviz](https://bioconductor.org/packages/release/bioc/html/Gviz.html) displaying the intervals annotated as chasing behavior from the GAL4 and the pBDPGAL4 groups. 
* Two figures created using [Sushi](https://bioconductor.org/packages/release/bioc/html/Sushi.html) displaying the intervals annotated as chasing behavior from the GAL4 and the pBDPGAL4 groups. 
* A folder containing all the necessary files to render the intervals annotated as chasing behavior from the GAL4 and the pBDPGAL4 groups using [IGV](http://software.broadinstitute.org/software/igv/)
* A volcano plot place on the folder with the same name displaying which variables were more different between periods 
labeled and not labeled as chase behavior by JAABA.  
