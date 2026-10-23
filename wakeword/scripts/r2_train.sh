#!/usr/bin/env bash
# Features for the new sets, then the fine-tune from mimi_full2 step 9000,
# with the scout, the ambient/noise evaluator and the round two evaluator.
set -u
NAME=${1:-mimi_r2a}
cd ~/mimi_ww/r2
sed -i 's/\r$//' scripts/*.py scripts/*.sh
PY=~/mimi_ww/.venv/bin/python
export PYTHONPATH=~/mimi_ww/r2/work/mww CUDA_VISIBLE_DEVICES=-1 TF_CPP_MIN_LOG_LEVEL=2
until grep -q DATA_DONE ~/mimi_ww/r2_data.log; do sleep 10; done
if [ ! -d ~/mimi_ww/features/mimi_r2_pos/testing ] || [ ! -d ~/mimi_ww/features/quiet_neg/testing ]; then
  $PY scripts/make_features.py --name mimi_r2_pos --dirs data/fish/mimi_r2 data/quiet/pos --repeat 2 > ~/mimi_ww/feat_pos.log 2>&1 &
  $PY scripts/make_features.py --name quiet_neg --dirs data/quiet/neg_speech data/quiet/neg_sounds > ~/mimi_ww/feat_neg.log 2>&1 &
  wait
fi
tail -3 ~/mimi_ww/feat_pos.log ~/mimi_ww/feat_neg.log
$PY scripts/r2_config.py --name $NAME --steps ${STEPS:-3000} --rate ${RATE:-0.0001} --eval ${EVAL:-750}
W=~/mimi_ww/trained_models/mimi_full2/train/0_weights_9000.weights.h5
# the fine-tune starter regenerates the config through make_config; bypass it
LOG=~/mimi_ww/train_$NAME.log
rm -rf ~/mimi_ww/trained_models/$NAME work/scout_$NAME; rm -f $LOG
grep -q "batch_size=256," work/mww/microwakeword/train.py || echo "WARN train.py validation batch is not 256"
tmux new-session -d -s train_$NAME "export PYTHONPATH=$PYTHONPATH CUDA_VISIBLE_DEVICES=0 TF_FORCE_GPU_ALLOW_GROWTH=true TF_GPU_ALLOCATOR=cuda_malloc_async TF_CPP_MIN_LOG_LEVEL=1; cd ~/mimi_ww; $PY ~/mimi_ww/r2/scripts/fine_tune.py --config ~/mimi_ww/training_parameters_$NAME.yaml --weights $W > $LOG 2>&1; echo TRAIN_EXIT=\$? >> $LOG"
tmux new-session -d -s scout_$NAME "bash scripts/scout.sh $NAME mimi data/holdout/mimi $LOG > ~/mimi_ww/scout_$NAME.log 2>&1"
tmux new-session -d -s full_$NAME "bash scripts/auto_eval.sh $NAME mimi $LOG > ~/mimi_ww/full_$NAME.log 2>&1"
tmux new-session -d -s r2e_$NAME "bash scripts/r2_eval_loop.sh $NAME > ~/mimi_ww/r2e_$NAME.log 2>&1"
echo TRAIN_STARTED
