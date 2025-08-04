#!/bin/bash

##test

if [[ $# -lt 3 ]]; then
    echo "Usage: ./petra2density.sh [-p] subject_id T1_file PETRA_file" >&2
    echo "Please provide the subject_id, T1_file, and PETRA_file" >&2
    echo "use -p to register to the petra. default is to register to the t1" >&2
    exit 2
fi

PETRA2DENSITY_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "PETRA2DENSITY_DIR: $PETRA2DENSITY_DIR"
REGISTER_TO_PETRA=0

while getopts "h:p" opt; do
  case ${opt} in
    h) echo "./petra2density.sh [-p] subject_id T1_file PETRA_file"; exit 1;;
    p) echo "Registering to petra image"
       REGISTER_TO_PETRA=1
       ;;
    ?) echo "Invalid option: -${OPTARG}."; exit 1 ;;
  esac
done

shift $((OPTIND - 1))

SUBJECT_ID="tim"
DATA_DIR="/Users/timdenboer1/local_drive_data/AmygTUS_Plasticity-Techdev/F3T_2024_023_050"
PETRA_FILE="${DATA_DIR}/images_031_noT1_petra_tra_FA_1_deg.nii"

T1_IMAGES=(
  "images_04_t1_mprage_sag_p2_iso.nii"
 #"images_026_t1_mprage_sag_p2_iso_FSWEn.nii"
  #"images_028_t1_mprage_sag_p2_isoFSWEf.nii"
)

for T1_IMAGE in "${T1_IMAGES[@]}"; do
  # Extract the string at the end of the T1 image filename before .nii (e.g., FSWEn, FSWEf, classic)
  T1_ABBR=$(echo "$T1_IMAGE" | sed -E 's/.*_([A-Za-z0-9]+)\.nii/\1/')
  if [ "$T1_ABBR" = "iso" ]; then
    T1_ABBR="classic"
  fi
  SUBJECT_ID="tim_${T1_ABBR}"
  T1_PATH="${DATA_DIR}/${T1_IMAGE}"

  # Set output directory based on T1_ABBR
  case "$T1_ABBR" in
    FSWEn)
      OUT_DIR="${DATA_DIR}/T1/T1_fatSupr_normal"
      ;;
    isoFSWEf)
      OUT_DIR="${DATA_DIR}/T1/T1_fatSupr_fast"
      ;;
    classic)
      OUT_DIR="${DATA_DIR}/T1/T1_classic"
      ;;
    *)
      OUT_DIR="${DATA_DIR}"
      ;;
  esac

  if [ "$REGISTER_TO_PETRA" -eq 1 ]; then
      cd "$OUT_DIR"
      echo "$OUT_DIR"
      charm "$SUBJECT_ID" "$PETRA_FILE" "$T1_PATH" --usesettings $PETRA2DENSITY_DIR/charm.ini --forceqform
      python3 $PETRA2DENSITY_DIR/petra2density.py "$OUT_DIR/m2m_${SUBJECT_ID}" --register_to_petra
      cd "$PETRA2DENSITY_DIR"
  else
      cd "$OUT_DIR"
      charm "$SUBJECT_ID" "$T1_PATH" "$PETRA_FILE" --usesettings $PETRA2DENSITY_DIR/charm.ini --forceqform
      python3 $PETRA2DENSITY_DIR/petra2density.py "$OUT_DIR/m2m_${SUBJECT_ID}"
      cd "$PETRA2DENSITY_DIR"
  fi
done
