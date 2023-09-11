# Greenland_polarbears
Example codes for analyses carried out

## Sequencing read filtering and mapping
## Populations genomics
 - PCA
   `angsd -minind 81 -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -SNP_pval 1e-6 -skipTriallelic 1 -doMaf 1 -doGlf 2 -b Greenlandonly_bams -out PCA/Greenland_only_PCA -ref ~/data/References/Polar_bear/Pseudochromo/Polar_reference.fasta -rf ~/data/References/Polar_bear/Pseudochromo/regions.18chr.txt -docounts 1  -domajorminor 4 -nthreads 10 -minmaf 0.05`
 - FST (https://github.com/simonhmartin/genomics_general)
 - angsd -minind 50 -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -skipTriallelic 1 -b Greenlandonly_bams -out PI-FST/Greenland_only -ref ~/data/References/Polar_bear/Pseudochromo/Polar_reference.fasta -rf ~/data/References/Polar_bear/Pseudochromo/regions.18chr.txt -docounts 1 -domajorminor 4 -nthreads 10 -minminor 0 -dohaplocall 2 -setMinDepthInd 3
~/Scripts/genomics_general_simonhmartin/popgenWindows.py -f haplo -g PI-FST/Greenland_only.haplo.gz -o PI-FST/Greenland_only_pi_fst_1mb.txt --popsFile PI-FST/Pops.txt -p East_Greenland -p West_Greenland  -w 1000000 -T 10 --roundTo 7 -m 1000
## Diversity
 - Heterozygosity
   atlas task=downsample bam=BGI-polarbear-PB_105.polarBear.realigned_RG.bam prob=0.647,0.485,0.388,0.324,0.243,0.162,0.097,0.065,0.032
   atlas task=recal bam=$file chr=polarCanada_NC003428 equalBaseFreq minQual=20 maxQual=100 verbose ; done

Add minQual https://bitbucket.org/WegmannLab/atlas/wiki/Engine%20Parameters
## Theta estimates
for file in *_downsampled*.bam ; do bn=`basename $file .bam`; echo xsbatch -c 2 --mem-per-cpu 100G --Force -- atlas task=estimateTheta bam=$file recal=${bn}_recalibrationEM.txt window=Chromosomes.bed minQual=20 maxQual=100 verbose; done

 - Nucleotide diversity
angsd -minind 50 -uniqueOnly 1 -GL 2 -remove_bads 1 -only_proper_pairs 1 -minMapQ 20 -minQ 20 -skipTriallelic 1 -b Greenlandonly_bams -out PI-FST/Greenland_only -ref ~/data/References/Polar_bear/Pseudochromo/Polar_reference.fasta -rf ~/data/References/Polar_bear/Pseudochromo/regions.18chr.txt -docounts 1 -domajorminor 4 -nthreads 10 -minminor 0 -dohaplocall 2 -setMinDepthInd 3 
 - Inbreeding
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
#prepare the fst for easy window analysis etc
#~/Software/angsd-0.921/bin/realSFS fst index East_SBanc_18.saf.idx West_SBanc_18.saf.idx -P 5 -sfs East.West.ml -fstout East.West_18
#get the global estimate
#~/Software/angsd-0.921/bin/realSFS fst stats East.West_18.fst.idx
#below is not tested that much, but seems to work
#~/Software/angsd-0.921/bin/realSFS fst stats2 East.West_18.fst.idx -win 50000 -step 10000 >slidingwindow


   
## Selection analysis
 - FST same as above but smaller windows
 - PCAdapt
pcangsd -b Greenland_only_PCA.beagle.gz --pcadapt -o Greenland_only_PCadapt --threads 5 --snp_weights --selection
Rscript pcadapt.R Greenland_only_PCadapt.pcadapt.zscores.npy Greenland_only_PCadapt


## Stable isotopes
The R script SI_data_plot.R can be used on the data file PB_WG.txt to generate the stable isotope data biplot presented in Supplementary figure 5.

The R script SI_stats_regions.R can be used on the data file PB_WG.txt to statistically compare the stable isotope values from Baffin Bay and Kane Basin.



