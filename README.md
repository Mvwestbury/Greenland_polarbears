# Greenland_polarbears
Example codes for analyses carried out

## Sequencing read filtering and mapping
## Populations genomics
### PCA
- Create Genotype likelihoods using ANGSD
  
   `angsd -minind 81 -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -SNP_pval 1e-6 -skipTriallelic 1 -doMaf 1 -doGlf 2 -b Greenlandonly_bams -out PCA/Greenland_only_PCA -ref Polar_reference.fasta -rf regions.18chr.txt -docounts 1  -domajorminor 4 -nthreads 10 -minmaf 0.05`

- Create covariance matrix using PCAngsd

   `pcangsd -b Greenland_only_PCA.beagle.gz -o Greenland_only_PCadapt --threads 5`
   
### FST (https://github.com/simonhmartin/genomics_general)
- Create pseudohaploid calls using ANGSD
  
  `angsd -minind 50 -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -skipTriallelic 1 -b Greenlandonly_bams -out PI-FST/Greenland_only -ref Polar_reference.fasta -rf regions.18chr.txt -docounts 1 -domajorminor 4 -nthreads 10 -minminor 0 -dohaplocall 2 -setMinDepthInd 3`
  
  - Get sliding window FST from pseudohaploid file
`~/Scripts/genomics_general_simonhmartin/popgenWindows.py -f haplo -g PI-FST/Greenland_only.haplo.gz -o PI-FST/Greenland_only_pi_fst_1mb.txt --popsFile PI-FST/Pops.txt -p East_Greenland -p West_Greenland  -w 1000000 -T 10 --roundTo 7 -m 1000`

## Diversity
### Heterozygosity
 - Downsample individual using ATLAS https://bitbucket.org/wegmannlab/atlas/wiki/Home

`atlas task=downsample bam=BGI-polarbear-PB_105.polarBear.realigned_RG.bam prob=0.647`

   - Calculate error rates based on the mitochondria
     
   `atlas task=recal bam=BGI-polarbear-PB_105.polarBear.realigned_RG.bam chr=polarCanada_NC003428 equalBaseFreq minQual=20 maxQual=100 verbose`

 - Theta estimates

`atlas task=estimateTheta bam=BGI-polarbear-PB_105.polarBear.realigned_RG.bam recal=BGI-polarbear-PB_105.polarBear.realigned_RG_recalibrationEM.txt window=Chromosomes.bed minQual=20 maxQual=100 verbose`

### Nucleotide diversity
 
 - The above FST command also outputs pi for each population 

### Inbreeding
 - angsd -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -SNP_pval 1e-6 -skipTriallelic 1 -doMaf 1 -doGlf 3 -b All_bams -out Inbreeding/All_wsouth_Glf3 -ref ~/data/References/Polar_bear/Pseudochromo/Polar_reference.fasta -rf ~/data/References/Polar_bear/Pseudochromo/regions.18chr.txt -docounts 1  -domajorminor 4 -nthreads 10 -minmaf 0.05
#zcat Inbreeding/All_wsouth_Glf3.mafs.gz | tail -n +2 | cut -f 6 > Inbreeding/All_wsouth_Glf3.freq
#/home/zhc860/apps/ngsRelate/ngsRelate -g Inbreeding/All_wsouth_Glf3.glf.gz -n 116 -p 10 -f Inbreeding/All_wsouth_Glf3.freq -O Inbreeding/All_wsouth_Glf3.relatedness -z Inbreeding/Names_all.txt

## Demographic history
 - PSMC
 - atlas task=PSMC bam=$file recal=${bn}_recalibrationEM.txt mask=/groups/hologenomics/westbury/data/Polar_bear/Modern/Het_norm/Tomask.bed minQual=20 maxQual=100 theta=0.00083 verbose; done

atlas task=PSMC bam=file fasta=example.fasta pmdFile=example_pmd_input.txt recal=example_recalibrationEM.txt verbose

for file in *.psmcfa ; do bn=`basename $file .psmcfa`; xsbatch -c 1 --mem-per-cpu 10G -- psmc -N25 -t15 -r5 -p "4+25*2+4+6" -o ${bn}.psmc ${bn}.psmcfa; done
 - Stairway plots
angsd -b ../bamlist_EG -anc ../Outgroups/Spectacled_bear.fa -docounts 1 -ref ~/data/References/Polar_bear/Pseudochromo/Polar_reference.fasta -dosaf 1 -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -doMajorMinor 4 -doMaf 1 -skipTriallelic 1 -GL 2 -minind 9 -out East_SBanc_18 -rf ~/data/References/Polar_bear/Pseudochromo/regions.18chr.txt -nthreads 10
~/apps/bin/winsfs East_SBanc_18.saf.idx > East_SBanc_18.sfs
   
 - Tajima's D
~/Software/angsd-0.921/bin/realSFS East_SBanc_18.saf.idx West_SBanc_18.saf.idx -P 5 -nsites 20000000 > East.West_20Mb.ml
#awk '{for(i=1;i<=NF;i++){sum[i]+=$i}}END{for(i=1;i<=NF;i++){printf sum[i]" "}}' East.West_20Mb.ml > East.West.ml



   
## Selection analysis
 - FST same as above but smaller windows
 - PCAdapt
pcangsd -b Greenland_only_PCA.beagle.gz --pcadapt -o Greenland_only_PCadapt --threads 5 --snp_weights --selection
Rscript pcadapt.R Greenland_only_PCadapt.pcadapt.zscores.npy Greenland_only_PCadapt


## Stable isotopes
The R script SI_data_plot.R can be used on the data file PB_WG.txt to generate the stable isotope data biplot presented in Supplementary figure 5.

The R script SI_stats_regions.R can be used on the data file PB_WG.txt to statistically compare the stable isotope values from Baffin Bay and Kane Basin.



