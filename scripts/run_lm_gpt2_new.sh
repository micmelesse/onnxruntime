#!/bin/bash
set -e

# checkout tip of transformers master
git reset --hard
git checkout master
git pull

# download dependencies
pip3 install -e .
pip3 install datasets
# pip3 install tokenizers -U

num_gpus=8
use_ort=false

#export TRAIN_FILE=/data/wiki.train.tokens
#export TEST_FILE=/data/wiki.test.tokens

RUN_FILE=/workspace/GPT2/transformers/examples/language-modeling/run_clm.py
RESULT_DIR=/workspace/results

if [ "$use_ort" = true ]; then
    echo "Launching ORT run:"
    RUN_CMD="mpirun -n ${num_gpus} --allow-run-as-root python $RUN_FILE --ort_trainer --output_dir=$RESULT_DIR/output-ort"
else
    echo "Launching PyTorch run:"
    RUN_CMD="python -m torch.distributed.launch --nproc_per_node $num_gpus $RUN_FILE --output_dir=$RESULT_DIR/output-pytorch"
fi

BATCH_SIZE=3
$RUN_CMD \
    --model_name_or_path gpt2-medium \
    --dataset_name wikitext \
    --dataset_config_name wikitext-2-raw-v1 \
    --do_train \
    --do_eval \
    --per_device_train_batch_size=$BATCH_SIZE \
    --per_device_eval_batch_size=$BATCH_SIZE \
    --gradient_accumulation_steps=8 \
    --block_size=1024  \
    --weight_decay=0.01 \
    --overwrite_output_dir \
    --logging_steps=10 \
    --num_train_epochs=5 \
    --fp16 \
    --fp16_opt_level=O2
