#!/usr/bin/env bash
# Everything between "the clips exist" and "the trainer can start":
# trim and filter the clips, set a holdout aside, then build the feature sets.
set -eu
WW=$(cd "$(dirname "$0")/.." && pwd)
PY=${MIMI_WW_PY:-$HOME/mimi_ww/.venv/bin/python}
export TF_CPP_MIN_LOG_LEVEL=2
# See the note in train.sh: the editable install's recorded path is stale.
export PYTHONPATH=${PYTHONPATH:+$PYTHONPATH:}$WW/work/mww
cd "$WW"

echo "=== trim and filter ==="
$PY scripts/qc_clips.py --dirs \
  data/fish/mimi data/fish/hey_mimi data/fish/confusable \
  data/piper/mimi data/piper/hey_mimi data/piper/negative

echo "=== holdout, one clip in twenty ==="
for pair in "data/fish/mimi:data/holdout/mimi" \
            "data/piper/mimi:data/holdout/mimi" \
            "data/fish/hey_mimi:data/holdout/hey_mimi" \
            "data/piper/hey_mimi:data/holdout/hey_mimi" \
            "data/fish/confusable:data/holdout/negative" \
            "data/piper/negative:data/holdout/negative"; do
  $PY scripts/make_holdout.py --source "${pair%%:*}" --out "${pair##*:}" --every 20
done

echo "=== features ==="
$PY scripts/make_features.py --name mimi_positive --truth \
  --dirs data/fish/mimi data/piper/mimi
$PY scripts/make_features.py --name adversarial --slide 5 \
  --dirs data/fish/confusable data/piper/negative
$PY scripts/make_features.py --name music --split-seconds 10 \
  --dirs "$HOME/mimi_ww/fma_16k"

echo "=== sizes ==="
du -sh "$HOME"/mimi_ww/features/*
df -h /mnt/c | tail -1
