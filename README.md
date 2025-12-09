# toolscript
This is my collection of script to make my multiomics work easy.

## MAF to VCF Converter

Converts MAF (Mutation Annotation Format) files to VCF (Variant Call Format) files. Preserves variant information per sample and generates a minimal VCF compatible with downstream tools including ANNOVAR and VCF validators.

### Dependencies

- **Python 3** (tested on ≥3.8)
- **pandas** library for Python

Install pandas if not already installed:

```bash
pip install pandas
```

### Usage

```bash
./maf_to_vcf.sh <input_maf_file> <output_vcf_file>
```

### Parameters

**<input_maf_file>** — Path to the input MAF file (tab-delimited)
**<output_vcf_file>** — Desired path for the output VCF file

### Example

```bash
./maf_to_vcf.sh mutation.txt output.vcf
./maf_to_vcf.sh mutation.maf output.vcf
```

### Notes
* The script automatically detects and normalizes column names, but your MAF file must contain at least the following columns (case-insensitive):
- Chromosome
- Start_Position
- Reference_Allele
- Tumor_Seq_Allele2
- Tumor_Sample_Barcode
* Missing sample names will be automatically assigned as Sample1, Sample2, etc.
* Default allele depths (T_REF_COUNT and T_ALT_COUNT) are set to 5 if not provided.
* Output VCF will include all tumor samples in the order detected in the MAF.
