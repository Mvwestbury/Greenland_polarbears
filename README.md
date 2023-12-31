# Greenland_polarbears
Example codes for analyses carried out in the manuscript Impact of Holocene environmental change on the evolutionary ecology of an Arctic top predator

## Sequencing read filtering and mapping
 - We used paleomix and all the documentation can be found here https://paleomix.readthedocs.io/en/stable/

## Populations genomics
### PCA
- Create Genotype likelihoods using ANGSD (http://www.popgen.dk/angsd/index.php/ANGSD)

`angsd -minind 81 -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -SNP_pval 1e-6 -skipTriallelic 1 -doMaf 1 -doGlf 2 -b Greenlandonly_bams -out PCA/Greenland_only_PCA -ref Polar_reference.fasta -rf regions.18chr.txt -docounts 1  -domajorminor 4 -nthreads 10 -minmaf 0.05`

- Create covariance matrix using PCAngsd (http://www.popgen.dk/software/index.php/PCAngsd)

`pcangsd -b Greenland_only_PCA.beagle.gz -o Greenland_only_PCadapt --threads 5`
   
### FST (https://github.com/simonhmartin/genomics_general)
- Create pseudohaploid calls using ANGSD
  
`angsd -minind 50 -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -skipTriallelic 1 -b Greenlandonly_bams -out PI-FST/Greenland_only -ref Polar_reference.fasta -rf regions.18chr.txt -docounts 1 -domajorminor 4 -nthreads 10 -minminor 0 -dohaplocall 2 -setMinDepthInd 3`
  
 - Get sliding window FST from pseudohaploid file

`~/Scripts/genomics_general_simonhmartin/popgenWindows.py -f haplo -g PI-FST/Greenland_only.haplo.gz -o PI-FST/Greenland_only_pi_fst_1mb.txt --popsFile PI-FST/Pops.txt -p East_Greenland -p West_Greenland  -w 1000000 -T 10 --roundTo 7 -m 1000`

## Diversity
### Heterozygosity using ATLAS https://bitbucket.org/wegmannlab/atlas/wiki/Home

 - Calculate error rates based on the mitochondria

`atlas task=recal bam=BGI-polarbear-PB_105.polarBear.realigned_RG.bam chr=polarCanada_NC003428 equalBaseFreq minQual=20 maxQual=100 verbose`

 - Theta estimates

`atlas task=estimateTheta bam=BGI-polarbear-PB_105.polarBear.realigned_RG.bam recal=BGI-polarbear-PB_105.polarBear.realigned_RG_recalibrationEM.txt window=Chromosomes.bed minQual=20 maxQual=100 verbose`

### Calculate equation to correct for low coverage
 - Downsample individual 

`atlas task=downsample bam=BGI-polarbear-PB_105.polarBear.realigned_RG.bam prob=0.647`

 - Repeat theta estimates above for multiple downsamplings and compare that to the original (we used 20x as the baseline) as seen in the following table 

| Coverage  | Heterozygosity | Proportion of 20x |
| ------------- | ------------- | ------------- |
| 20  | 0.000819111  | 1  | 
| 15  | 0.00078182  | 0.954  |
| 12  | 0.000752601  | 0.919  |
| 10  | 0.000729013  | 0.890  |
| 7.5  | 0.000694065  | 0.847  |
| 5  | 0.000657317  | 0.802  |
| 3  | 0.00063877  | 0.780  |

 - We then plotted the proportion of 20x vs coverage in excel and calculated a trend line in excel which we used to correct for low coverage (see paper for details)
   
### Nucleotide diversity
 
 - The above FST command also outputs pi for each population 

### Inbreeding
 - Calculate GL in ANGSD as for the PCA but use doglf 3 instead of doglf 2 to get the correct format
  
`angsd -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -SNP_pval 1e-6 -skipTriallelic 1 -doMaf 1 -doGlf 3 -b All_bams -out Inbreeding/All_wsouth_Glf3 -ref Polar_reference.fasta -rf regions.18chr.txt -docounts 1  -domajorminor 4 -nthreads 10 -minmaf 0.05`

  - Extract the allele frequencies

`zcat Inbreeding/All_wsouth_Glf3.mafs.gz | tail -n +2 | cut -f 6 > Inbreeding/All_wsouth_Glf3.freq`

 - Run the GL and allele frequencies through NGSrelatev2 https://github.com/ANGSD/NgsRelate

`/home/zhc860/apps/ngsRelate/ngsRelate -g Inbreeding/All_wsouth_Glf3.glf.gz -n 116 -p 10 -f Inbreeding/All_wsouth_Glf3.freq -O Inbreeding/All_wsouth_Glf3.relatedness -z Inbreeding/Names_all.txt`

## Demographic history
### PSMC
 - Create the PSMC input psmcfa file using ATLAS (Tomask.bed file contains the regions not of interest, i.e. the inverse of Chromosomes.bed, this was done as specifying the chromosomes/regions of interest took a lot of memory)
   
`atlas task=PSMC bam=BGI-polarbear-PB_105.polarBear.realigned_RG.bam recal=BGI-polarbear-PB_105.polarBear.realigned_RG_recalibrationEM.txt mask=Tomask.bed minQual=20 maxQual=100 theta=0.00083 verbose`
   
  - Run the psmcfa through psmc

`psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o BGI-polarbear-PB_105.polarBear.realigned_RG_recalibrationEM.txt.psmc BGI-polarbear-PB_105.polarBear.realigned_RG_recalibrationEM.txt.psmcfa`

### Stairway plots
 - Calculate sample allele frequencies in ANGSD (bamlist contains only the individuals in the selected population)
 
`angsd -b ../bamlist_EG -anc ../Outgroups/Spectacled_bear.fa -docounts 1 -ref Polar_reference.fasta -dosaf 1 -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -doMajorMinor 4 -doMaf 1 -skipTriallelic 1 -GL 2 -minind 9 -out East_SBanc_18 -rf regions.18chr.txt -nthreads 10`
   
 - Convert saf into SFS for input to stairway plots
   
`~/apps/bin/winsfs East_SBanc_18.saf.idx > East_SBanc_18.sfs`

 - Instructions on using stairway plots are found here https://github.com/xiaoming-liu/stairway-plot-v2 and an example of the blueprint file is included here and is called Greenland-PB_ESB_18.blueprint

### Tajima's D
 - We used the same approach to calculate the SFS as above above with more individuals
 - We then used the SFS as input to calculate sliding window Tajima's D using realSFS in ANGSD
 
`~/Software/angsd-0.921/bin/realSFS saf2theta East_SBanc_3x.saf.idx -outname East_SBanc_3x -sfs East_SBanc_3x_nohead.sfs -P 10`

`~/Software/angsd-0.921/bin/thetaStat do_stat East_SBanc_3x.thetas.idx -win 10000000 -step 10000000 -outnames East_SBanc_3x.thetasWindow.gz`

   
## Selection analysis
### FST same as above but smaller windows
### PCAdapt
 - Add the pcadapt parameter to PCAngsd and use the same GL (from the PCA step) as input

`pcangsd -b Greenland_only_PCA.beagle.gz --pcadapt -o Greenland_only_PCadapt --threads 5`

 - Convert the output into p-values using the script provided with PCAngsd

`Rscript pcadapt.R Greenland_only_PCadapt.pcadapt.zscores.npy Greenland_only_PCadapt`

### Annotate the polar bear genome
 - Use miniprot and published polar bear protein sequences to annotate the pseudochromosome polar bear assembly
   
`~/Software/miniprot-0.7/bin/miniprot --gff -t 10 ../Polar_reference.fasta GCF_017311325.1_ASM1731132v1_protein.faa.gz > Polarbear_annotations.gff`

 - Find the protein names that occur in the top 1% of Fst windows and contain 2 SNPs in the top 1% of PCAdapt results using bedtools

`bedtools intersect -a ../PI-FST/Top1.txt -b PCAdapt_top1.bed | uniq -d | bedtools intersect -a Polarbear_annotations.gff -b - | cut -f 9 | cut -f 1 -d " " | sed 's/Target=/ /g' | cut -f 2 -d " "`
   
## Stable isotopes
 - The R script SI_data_plot.R can be used on the data file PB_WG.txt to generate the stable isotope data biplot presented in Supplementary figure 5.
 - The R script SI_stats_regions.R can be used on the data file PB_WG.txt to statistically compare the stable isotope values from Baffin Bay and Kane Basin.

## Habitat modelling
 - The data and scripts needed to replicate the habitat modelling can be found on zenodo at https://doi.org/10.5281/zenodo.8349059



