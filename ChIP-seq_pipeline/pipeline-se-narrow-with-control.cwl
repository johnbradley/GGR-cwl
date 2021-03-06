#!/usr/bin/env cwl-runner
cwlVersion: "cwl:draft-3"
class: Workflow
description: "ChIP-seq pipeline - reads: SE, region: narrow, samples: treatment and control."
requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: StepInputExpressionRequirement
inputs:
  - id: "#input_treatment_fastq_files"
    type:
      type: array
      items: File
  - id: "#input_control_fastq_files"
    type:
      type: array
      items: File
  - id: "#default_adapters_file"
    type: File
    description: "Adapters file"
  - id: "#genome_ref_first_index_file"
    type: File
    description: |
        "First index file of Bowtie reference genome with extension 1.ebwt. \
        (Note: the rest of the index files MUST be in the same folder)"
  - id: "#genome_sizes_file"
    type: File
    description: "Genome sizes tab-delimited file (used in samtools)"
  - id: "#ENCODE_blacklist_bedfile"
    type: File
    description: "Bedfile containing ENCODE consensus blacklist regions to be excluded."
  - id: "#nthreads_qc"
    type: int
    description: "Number of threads required for the 01-qc step"
  - id: "#nthreads_trimm"
    type: int
    description: "Number of threads required for the 02-trim step"
  - id: "#nthreads_map"
    type: int
    description: "Number of threads required for the 03-map step"
  - id: "#nthreads_peakcall"
    type: int
    description: "Number of threads required for the 04-peakcall step"
  - id: "#nthreads_quant"
    type: int
    description: "Number of threads required for the 05-quantification step"
  - id: "#trimmomatic_jar_path"
    type: string
    description: "Trimmomatic Java jar file"
  - id: "#trimmomatic_java_opts"
    type:
      - 'null'
      - string
    description: "JVM arguments should be a quoted, space separated list (e.g. \"-Xms128m -Xmx512m\")"
  - id: "#picard_jar_path"
    type: string
    description: "Picard Java jar file"
  - id: "#picard_java_opts"
    type:
      - 'null'
      - string
    description: "JVM arguments should be a quoted, space separated list (e.g. \"-Xms128m -Xmx512m\")"
outputs:
  - id: "#qc_treatment_raw_read_counts"
    source: "#qc_treatment.output_raw_read_counts"
    description: "Raw read counts of fastq files after QC for treatment"
    type:
      type: array
      items: File
  - id: "#qc_treatment_fastqc_report_files"
    source: "#qc_treatment.output_fastqc_report_files"
    description: "FastQC reports in zip format"
    type:
      type: array
      items: File
  - id: "#qc_treatment_fastqc_data_files"
    source: "#qc_treatment.output_fastqc_data_files"
    description: "FastQC data files"
    type:
      type: array
      items: File
  - id: "#trimm_treatment_raw_read_counts"
    source: "#trimm_treatment.trimmed_fastq_read_count"
    description: "Raw read counts of fastq files after TRIMM for treatment"
    type:
      type: array
      items: File
  - id: "#trimm_treatment_fastq_files"
    source: "#trimm_treatment.output_data_fastq_trimmed_files"
    description: "FASTQ files after trimming step for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_mark_duplicates_files"
    source: "#map_treatment.output_picard_mark_duplicates_files"
    description: "Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions) for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_dedup_bam_files"
    source: "#map_treatment.output_data_sorted_dedup_bam_files"
    description: "Filtered BAM files (post-processing end point) for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_dedup_bam_index_files"
    source: "#map_treatment.output_index_dedup_bam_files"
    description: "Filtered BAM index files for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_pbc_files"
    source: "#map_treatment.output_pbc_files"
    description: "PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5) for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_preseq_c_curve_files"
    source: "#map_treatment.output_preseq_c_curve_files"
    description: "Preseq c_curve output files for treatment"
    type:
      type: array
      items: File
  - id: "#map_treatment_preseq_percentage_uniq_reads"
    source: "#map_treatment.output_percentage_uniq_reads"
    description: "Preseq percentage of uniq reads"
    type:
      type: array
      items: File
  - id: "#map_treatment_read_count_mapped"
    source: "#map_treatment.output_read_count_mapped"
    description: "Read counts of the mapped BAM files"
    type:
      type: array
      items: File
  - id: "#map_treatment_bowtie_log_files"
    source: "#map_treatment.output_bowtie_log"
    description: "Bowtie log file with mapping stats for treatment"
    type:
      type: array
      items: File
  - id: "#qc_control_raw_read_counts"
    source: "#qc_control.output_raw_read_counts"
    description: "Raw read counts of fastq files after QC for control"
    type:
      type: array
      items: File
  - id: "#qc_control_fastqc_report_files"
    source: "#qc_control.output_fastqc_report_files"
    description: "FastQC reports in zip format"
    type:
      type: array
      items: File
  - id: "#qc_control_fastqc_data_files"
    source: "#qc_control.output_fastqc_data_files"
    description: "FastQC data files"
    type:
      type: array
      items: File
  - id: "#trimm_control_raw_read_counts"
    source: "#trimm_control.trimmed_fastq_read_count"
    description: "Raw read counts of fastq files after TRIMM for control"
    type:
      type: array
      items: File
  - id: "#trimm_control_fastq_files"
    source: "#trimm_control.output_data_fastq_trimmed_files"
    description: "FASTQ files after trimming step for control"
    type:
      type: array
      items: File
  - id: "#map_control_mark_duplicates_files"
    source: "#map_control.output_picard_mark_duplicates_files"
    description: "Summary of duplicates removed with Picard tool MarkDuplicates (for multiple reads aligned to the same positions) for control"
    type:
      type: array
      items: File
  - id: "#map_control_dedup_bam_files"
    source: "#map_control.output_data_sorted_dedup_bam_files"
    description: "Filtered BAM files (post-processing end point) for control"
    type:
      type: array
      items: File
  - id: "#map_control_dedup_bam_index_files"
    source: "#map_control.output_index_dedup_bam_files"
    description: "Filtered BAM index files for control"
    type:
      type: array
      items: File
  - id: "#map_control_pbc_files"
    source: "#map_control.output_pbc_files"
    description: "PCR Bottleneck Coefficient files (used to flag samples when pbc<0.5) for control"
    type:
      type: array
      items: File
  - id: "#map_control_preseq_c_curve_files"
    source: "#map_control.output_preseq_c_curve_files"
    description: "Preseq c_curve output files for control"
    type:
      type: array
      items: File
  - id: "#map_control_preseq_percentage_uniq_reads"
    source: "#map_control.output_percentage_uniq_reads"
    description: "Preseq percentage of uniq reads"
    type:
      type: array
      items: File
  - id: "#map_control_read_count_mapped"
    source: "#map_control.output_read_count_mapped"
    description: "Read counts of the mapped BAM files"
    type:
      type: array
      items: File
  - id: "#map_control_bowtie_log_files"
    source: "#map_control.output_bowtie_log"
    description: "Bowtie log file with mapping stats for control"
    type:
      type: array
      items: File
  - id: "#peak_call_spp_x_cross_corr"
    source: "#peak_call.output_spp_x_cross_corr"
    description: "SPP strand cross correlation summary"
    type:
      type: array
      items: File
  - id: "#peak_call_spp_x_cross_corr_plot"
    source: "#peak_call.output_spp_cross_corr_plot"
    description: "SPP strand cross correlation plot"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_xls_file"
    source: "#peak_call.output_peak_xls_file"
    description: "Peak calling report file"
    type:
      type: array
      items: File
  - id: "#peak_call_filtered_read_count_file"
    source: "#peak_call.output_filtered_read_count_file"
    description: "Filtered read count after peak calling"
    type:
      type: array
      items: File
  - id: "#peak_call_read_in_peak_count_within_replicate"
    source: "#peak_call.output_read_in_peak_count_within_replicate"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#peak_call_peak_count_within_replicate"
    source: "#peak_call.output_peak_count_within_replicate"
    description: "Peak counts within replicate"
    type:
      type: array
      items: File
  - id: "#peak_call_narrowpeak_file"
    source: "#peak_call.output_narrowpeak_file"
    description: "Peaks in narrowPeak file format"
    type:
      type: array
      items: File
  - id: "#peak_call_extended_narrowpeak_file"
    source: "#peak_call.output_extended_narrowpeak_file"
    description: "Extended fragment peaks in narrowPeak file format"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_raw_files"
    source: "#quant.bigwig_raw_files"
    description: "Raw reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_norm_files"
    source: "#quant.bigwig_norm_files"
    description: "Normalized reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_extended_files"
    source: "#quant.bigwig_extended_files"
    description: "Fragment extended reads bigWig (signal) files"
    type:
      type: array
      items: File
  - id: "#quant_bigwig_extended_norm_files"
    source: "#quant.bigwig_extended_norm_files"
    description: "Normalized fragment extended reads bigWig (signal) files"
    type:
      type: array
      items: File
steps:
  - id: "#qc_treatment"
    run: {$import: "01-qc-se.cwl" }
    inputs:
      - { id: "#qc_treatment.input_fastq_files", source: "#input_treatment_fastq_files" }
      - { id: "#qc_treatment.default_adapters_file", source: "#default_adapters_file" }
      - { id: "#qc_treatment.nthreads", source: "#nthreads_qc" }
    outputs:
      - { id: "#qc_treatment.output_raw_read_counts" }
      - { id: "#qc_treatment.output_fastqc_read_counts" }
      - { id: "#qc_treatment.output_fastqc_report_files" }
      - { id: "#qc_treatment.output_fastqc_data_files" }
      - { id: "#qc_treatment.output_custom_adapters" }
  - id: "#trimm_treatment"
    run: {$import: "02-trim-se.cwl" }
    inputs:
      - { id: "#trimm_treatment.input_read1_fastq_files", source: "#input_treatment_fastq_files" }
      - { id: "#trimm_treatment.input_adapters_files", source: "#qc_treatment.output_custom_adapters" }
      - { id: "#trimm_treatment.nthreads", source: "#nthreads_trimm" }
      - { id: "#trimm_treatment.trimmomatic_jar_path", source: "#trimmomatic_jar_path" }
      - { id: "#trimm_treatment.trimmomatic_java_opts", source: "#trimmomatic_java_opts" }
    outputs:
      - { id: "#trimm_treatment.output_data_fastq_trimmed_files" }
      - { id: "#trimm_treatment.trimmed_fastq_read_count" }
  - id: "#map_treatment"
    run: {$import: "03-map-se.cwl" }
    inputs:
      - { id: "#map_treatment.input_fastq_files", source: "#trimm_treatment.output_data_fastq_trimmed_files" }
      - { id: "#map_treatment.genome_ref_first_index_file", source: "#genome_ref_first_index_file" }
      - { id: "#map_treatment.genome_sizes_file", source: "#genome_sizes_file" }
      - { id: "#map_treatment.ENCODE_blacklist_bedfile", source: "#ENCODE_blacklist_bedfile" }
      - { id: "#map_treatment.nthreads", source: "#nthreads_map" }
      - { id: "#map_treatment.picard_jar_path", source: "#picard_jar_path" }
      - { id: "#map_treatment.picard_java_opts", source: "#picard_java_opts" }
    outputs:
      - { id: "#map_treatment.output_data_sorted_dedup_bam_files" }
      - { id: "#map_treatment.output_index_dedup_bam_files" }
      - { id: "#map_treatment.output_picard_mark_duplicates_files" }
      - { id: "#map_treatment.output_pbc_files" }
      - { id: "#map_treatment.output_bowtie_log" }
      - { id: "#map_treatment.output_preseq_c_curve_files" }
      - { id: "#map_treatment.output_percentage_uniq_reads" }
      - { id: "#map_treatment.output_read_count_mapped" }
  - id: "#qc_control"
    run: {$import: "01-qc-se.cwl" }
    inputs:
      - { id: "#qc_control.input_fastq_files", source: "#input_control_fastq_files" }
      - { id: "#qc_control.default_adapters_file", source: "#default_adapters_file" }
      - { id: "#qc_control.nthreads", source: "#nthreads_qc" }
    outputs:
      - { id: "#qc_control.output_raw_read_counts" }
      - { id: "#qc_control.output_fastqc_read_counts" }
      - { id: "#qc_control.output_fastqc_report_files" }
      - { id: "#qc_control.output_fastqc_data_files" }
      - { id: "#qc_control.output_custom_adapters" }
  - id: "#trimm_control"
    run: {$import: "02-trim-se.cwl" }
    inputs:
      - { id: "#trimm_control.input_read1_fastq_files", source: "#input_control_fastq_files" }
      - { id: "#trimm_control.input_adapters_files", source: "#qc_control.output_custom_adapters" }
      - { id: "#trimm_control.nthreads", source: "#nthreads_trimm" }
      - { id: "#trimm_control.trimmomatic_jar_path", source: "#trimmomatic_jar_path" }
      - { id: "#trimm_control.trimmomatic_java_opts", source: "#trimmomatic_java_opts" }
    outputs:
      - { id: "#trimm_control.output_data_fastq_trimmed_files" }
      - { id: "#trimm_control.trimmed_fastq_read_count" }
  - id: "#map_control"
    run: {$import: "03-map-se.cwl" }
    inputs:
      - { id: "#map_control.input_fastq_files", source: "#trimm_control.output_data_fastq_trimmed_files" }
      - { id: "#map_control.genome_ref_first_index_file", source: "#genome_ref_first_index_file" }
      - { id: "#map_control.genome_sizes_file", source: "#genome_sizes_file" }
      - { id: "#map_control.ENCODE_blacklist_bedfile", source: "#ENCODE_blacklist_bedfile" }
      - { id: "#map_control.nthreads", source: "#nthreads_map" }
      - { id: "#map_control.picard_jar_path", source: "#picard_jar_path" }
      - { id: "#map_control.picard_java_opts", source: "#picard_java_opts" }
    outputs:
      - { id: "#map_control.output_data_sorted_dedup_bam_files" }
      - { id: "#map_control.output_index_dedup_bam_files" }
      - { id: "#map_control.output_picard_mark_duplicates_files" }
      - { id: "#map_control.output_pbc_files" }
      - { id: "#map_control.output_bowtie_log" }
      - { id: "#map_control.output_preseq_c_curve_files" }
      - { id: "#map_control.output_percentage_uniq_reads" }
      - { id: "#map_control.output_read_count_mapped" }
  - id: "#peak_call"
    run: {$import: "04-peakcall-narrow-with-control.cwl" }
    inputs:
      - { id: "#peak_call.input_bam_files", source: "#map_treatment.output_data_sorted_dedup_bam_files" }
      - { id: "#peak_call.input_bam_format", valueFrom: "BAM" }
      - { id: "#peak_call.input_control_bam_files", source: "#map_control.output_data_sorted_dedup_bam_files" }
      - { id: "#peak_call.nthreads", source: "#nthreads_peakcall" }
    outputs:
      - { id: "#peak_call.output_spp_x_cross_corr" }
      - { id: "#peak_call.output_spp_cross_corr_plot" }
      - { id: "#peak_call.output_narrowpeak_file" }
      - { id: "#peak_call.output_extended_narrowpeak_file" }
      - { id: "#peak_call.output_peak_xls_file" }
      - { id: "#peak_call.output_filtered_read_count_file" }
      - { id: "#peak_call.output_peak_count_within_replicate" }
      - { id: "#peak_call.output_read_in_peak_count_within_replicate" }
  - id: "#quant"
    run: {$import: "05-quantification.cwl" }
    inputs:
      - { id: "#quant.input_bam_files", source: "#map_treatment.output_data_sorted_dedup_bam_files" }
      - { id: "#quant.input_pileup_bedgraphs", source: "#peak_call.output_extended_narrowpeak_file" }
      - { id: "#quant.input_peak_xls_files", source: "#peak_call.output_peak_xls_file" }
      - { id: "#quant.input_read_count_dedup_files", source: "#peak_call.output_filtered_read_count_file" }
      - { id: "#quant.input_genome_sizes", source: "#genome_sizes_file" }
      - { id: "#quant.nthreads", source: "#nthreads_quant" }
    outputs:
      - { id: "#quant.bigwig_raw_files" }
      - { id: "#quant.bigwig_norm_files" }
      - { id: "#quant.bigwig_extended_files" }
      - { id: "#quant.bigwig_extended_norm_files" }