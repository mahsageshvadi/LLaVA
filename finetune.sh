#!/bin/bash

DEEPSPEED_SCRIPT="deepspeed llava/train/train_mem.py"
DEEPSPEED_JSON="./scripts/zero3.json"
MODEL_NAME="liuhaotian/llava-v1.5-7b"
DATA_PATH="lengthDataset/train/dataset.json"
IMAGE_FOLDER="lengthDataset/images"
VISION_TOWER="openai/clip-vit-large-patch14-336"
OUTPUT_DIR="lengthDataset"

finetune_script="
${DEEPSPEED_SCRIPT} \\
    --lora_enable True --lora_r 128 --lora_alpha 256 --mm_projector_lr 2e-5 \\
    --deepspeed ${DEEPSPEED_JSON} \\
    --model_name_or_path ${MODEL_NAME} \\
    --version v1 \\
    --data_path ${DATA_PATH} \\
    --image_folder ${IMAGE_FOLDER} \\
    --vision_tower ${VISION_TOWER} \\
    --mm_projector_type mlp2x_gelu \\
    --mm_vision_select_layer -2 \\
    --mm_use_im_start_end False \\
    --mm_use_im_patch_token False \\
    --image_aspect_ratio pad \\
    --group_by_modality_length True \\
    --bf16 True \\
    --output_dir ${OUTPUT_DIR} \\
    --num_train_epochs 5 \\
    --per_device_train_batch_size 16 \\
    --per_device_eval_batch_size 4 \\
    --gradient_accumulation_steps 1 \\
    --evaluation_strategy \"no\" \\
    --save_strategy \"steps\" \\
    --save_steps 50000 \\
    --save_total_limit 1 \\
    --learning_rate 2e-4 \\
    --weight_decay 0. \\
    --warmup_ratio 0.03 \\
    --lr_scheduler_type \"cosine\" \\
    --logging_steps 1 \\
    --tf32 True \\
    --model_max_length 2048 \\
    --gradient_checkpointing True \\
    --dataloader_num_workers 4 \\
    --lazy_preprocess True \\
    --report_to wandb
"

eval $finetune_script
