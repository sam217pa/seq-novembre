## analyses hétérozygotes
analysis/snp_distribution.pdf: scripts/polysnip.R
  Rscript $<

analysis/switch_distrib.pdf: scripts/polysnip.R
  Rscript $<

analysis/mutant-count.pdf: scripts/polysnip.R
  Rscript $<

analysis/mutant-second.pdf: scripts/polysnip.R
  Rscript $<

scripts/polysnip.R: scripts/polysniper.sh       \
  scripts/polysniper-strong.sh                  \
  scripts/polysniper-weak.sh
  bash $<

scripts/polysniper.sh: scripts/extract_raw_data.sh
  bash $<



## analyses des variants
analysis/qualite_distrib.pdf: scripts/variant_analysis.R
  Rscript $<

analysis/bgc_en_action.pdf: scripts/variant_analysis.R
  Rscript $<

analysis/candidats_heterozygotes.pdf: scripts/variant_analysis.R
  Rscript $<

analysis/inside_conv.tex: scripts/variant_analysis.R
  Rscript $<

analysis/mutant_snp_distribution.pdf: scripts/variant_analysis.R
  Rscript $<

analysis/per_base_quality_fastqc_trimmed.png: scripts/

analysis/per_base_quality_fastqc_untrimmed.png: scripts/
