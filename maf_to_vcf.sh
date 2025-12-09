#!/bin/bash
# Usage: ./maf_to_vcf.sh input_maf.txt output.vcf

# Check arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <input_maf> <output_vcf>"
    exit 1
fi

INPUT_MAF=$1
OUTPUT_VCF=$2

python3 - <<END
import pandas as pd

maf_file = "$INPUT_MAF"
vcf_file = "$OUTPUT_VCF"

# Read MAF
maf = pd.read_csv(maf_file, sep="\t", comment="#", low_memory=False)

# Map your actual column names to expected names
col_map = {
    "Chromosome": "CHROMOSOME",
    "Start_Position": "START_POSITION",
    "Reference_Allele": "REFERENCE_ALLELE",
    "Tumor_Seq_Allele2": "TUMOR_SEQ_ALLELE2",
    "Tumor_Sample_Barcode": "TUMOR_SAMPLE_BARCODE"
}

# Rename
maf.rename(columns=col_map, inplace=True)

# Normalize column names to uppercase
maf.columns = maf.columns.str.upper()

# Required columns
required_cols = ["CHROMOSOME", "START_POSITION", "REFERENCE_ALLELE",
                 "TUMOR_SEQ_ALLELE2", "TUMOR_SAMPLE_BARCODE"]

for col in required_cols:
    if col not in maf.columns:
        raise ValueError(f"Missing required column: {col}")

print("✅ All required columns found:", required_cols)

# Collect tumor samples
all_samples = maf["TUMOR_SAMPLE_BARCODE"].dropna().astype(str).unique().tolist()

# Replace blank or nan-like with defaults
clean_samples = []
for i, s in enumerate(all_samples, start=1):
    s = s.strip()
    if s == "" or s.lower() in ["nan", "na", "."]:
        s = f"Sample{i}"
    clean_samples.append(s)

# Ensure at least one sample
if not clean_samples:
    clean_samples = ["Sample1"]

print("Samples in VCF:", clean_samples)

# Open VCF
with open(vcf_file, "w") as vcf:
    # VCF Header
    vcf.write("##fileformat=VCFv4.2\n")
    vcf.write("##source=MAF_to_VCF_converter\n")
    vcf.write("##INFO=<ID=TYPE,Number=1,Type=String,Description=\"Variant classification from MAF\">\n")
    vcf.write("##FORMAT=<ID=GT,Number=1,Type=String,Description=\"Genotype\">\n")
    vcf.write("##FORMAT=<ID=AD,Number=R,Type=Integer,Description=\"Allelic depths: ref,alt\">\n")
    vcf.write("#CHROM\tPOS\tID\tREF\tALT\tQUAL\tFILTER\tINFO\tFORMAT\t" + "\t".join(clean_samples) + "\n")

    # Loop through variants
    for _, row in maf.iterrows():
        try:
            chrom = str(row["CHROMOSOME"])
            pos = int(row["START_POSITION"])
            ref = str(row["REFERENCE_ALLELE"])
            alt = str(row["TUMOR_SEQ_ALLELE2"])
            sample = str(row["TUMOR_SAMPLE_BARCODE"]).strip()
        except Exception:
            continue  # skip bad rows

        if pd.isna(alt) or alt == ref or alt in ["", "NA", "nan", "."]:
            continue

        # Variant type info
        info = f"TYPE={row.get('VARIANT_CLASSIFICATION', 'NA')}"

        # FORMAT
        fmt = "GT:AD"

        # Fill sample genotypes
        sample_gt = []
        for s in clean_samples:
            if s == sample:
                try:
                    ref_count = int(row.get("T_REF_COUNT", 5))
                    alt_count = int(row.get("T_ALT_COUNT", 5))
                except Exception:
                    ref_count, alt_count = 5, 5
                gt = "0/1"
                ad = f"{ref_count},{alt_count}"
                sample_gt.append(f"{gt}:{ad}")
            else:
                sample_gt.append("./.:0,0")

        # Write line
        vcf.write(f"{chrom}\t{pos}\t.\t{ref}\t{alt}\t.\tPASS\t{info}\t{fmt}\t" + "\t".join(sample_gt) + "\n")

print(f"✅ VCF written to {vcf_file}")
END
