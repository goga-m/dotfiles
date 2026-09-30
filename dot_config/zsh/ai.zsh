# ============================================================================
# TheRock ROCm (default ROCm for Strix Halo / gfx1151)
# pacman ROCm 7.2.3 was removed; therock is the sole ROCm stack.
# CIRU's Qwen3.8-Flash-CIRU-STRIX-IU4 runtime links libamdhip64.so.7 (HIP 7.x),
# so keep therock on the 7.x line (do NOT jump to ROCm 10.x without rebuilding).
# Override THEROCK_ROOT to point at a different therock install.
# ============================================================================

: "${THEROCK_ROOT:=/home/pico/therock/7.15.0a20260718}"
export ROCM_PATH="${THEROCK_ROOT}"
export HIP_PATH="${THEROCK_ROOT}"
export LD_LIBRARY_PATH="${THEROCK_ROOT}/lib:${LD_LIBRARY_PATH}"
export PATH="${THEROCK_ROOT}/bin:${PATH}"

# Print the active ROCm stack (for verifying therock is default):
#   ai-rocm-env
alias "ai-rocm-env"='echo "THEROCK_ROOT=$THEROCK_ROOT"; which rocminfo hipcc hipconfig; rocminfo 2>/dev/null | grep -m1 gfx1151; hipconfig --full 2>/dev/null | head -3'

# Aliases - AI/LLM
# ============================================================================

alias "aif"="aichat -r %functions%"
alias "aic"="aichat -c"
alias "x"="aichat -e"
alias ","="aichat"
alias fabric="fabric-ai --disable-responses-api --stream"

# ============================================================================
# Aliases - AI Models
# ============================================================================

# Qwen3.8-Flash-CIRU-STRIX-IU4 — required CIRU llama.cpp runtime (v1.1, gfx1151).
# IU4 WMMA execution + FP8 PLE sidecar pager + Q8_0 MTP depth-3 speculative decode.
# run-server.sh sources profiles/strix-halo-production.env (GGML_CUDA_Q41_MOE_FORCE_J=32,
# GGML_QWEN4EXP_PLE_WORKERS=16, ROCBLAS_USE_HIPBLASLT=1) and applies the audited production flags.
# model/ symlinks to the HF cache; MODEL_DIR is resolved from repo_root so cwd does not matter.
alias "ai-qwen3.8-flash"='~/ai/Qwen3.8-Flash-CIRU-STRIX-IU4/scripts/ciru/run-server.sh'

alias h='toolbox run -c hermes-box -- hermes'

export OPENCODE_ENABLE_EXA=1 

alias "ai-qwen3.5-local-llama"='~/temp/strix-halo-llamacpp/vulkan/llama-server \
  --port 18080 \
  -m ~/.cache/llama.cpp/fast_unsloth_Qwen3.5-35B-A3B-GGUF_Qwen3.5-35B-A3B-UD-Q4_K_XL.gguf \
  --alias LOCAL \
  -ngl 999 \
  --load-mode mmap \
  --ctx-size 202752 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --flash-attn on --fit on \
  --kv-unified \
  --keep -1 \
  -np 1 \
  --jinja \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0.05 \
  --repeat-penalty 1.0 \
  --presence-penalty 1.4 \
  --chat-template-kwargs "{\"enable_thinking\": true}"'

alias "ai-Qwen3.6-35B-A3B"='~/temp/llama.cpp/build/bin/llama-server \
  --port 8080 \
  -m ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-GGUF/snapshots/9280dd353ab587157920d5bd391ada414d84e552/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf \
  --mmproj ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-GGUF/snapshots/9280dd353ab587157920d5bd391ada414d84e552/mmproj-BF16.gguf \
  --alias QWEN_SMALL \
  -ngl 999 \
  --no-mmap \
  --flash-attn on --fit on \
  --ctx-size 202752 \
  --ctx-checkpoints 8192 \
  --cache-type-k f16 --cache-type-v f16 \
  --flash-attn on --fit on \
  --keep -1 \
  -np 1 \
  --jinja \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0 \
  --repeat-penalty 1.0 \
  --presence-penalty 0 \
  --checkpoint-every-n-tokens 2048 \
  --chat-template-kwargs "{\"preserve_thinking\": true}"'


 # ### Why these params
 #
 # ┌─────────────────────────┬───────────┬─────────────────────────────────────────────────────────────────────┐
 # │ Flag                    │ Value     │ Reason                                                              │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ -hf                     │ UD-Q4_K_S │ Speed-first UD quant, ~19 GB (vs 22 GB for XL)                      │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --port                  │ 8081      │ Separate from your other servers on 8080                            │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ -ngl 999                │ 999       │ Full GPU offload                                                    │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --no-mmap               │ (on)      │ Prefetch weights into RAM, no errors on large models                │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --flash-attn on         │ (on)      │ rocWMMA flash attention — mandatory for Strix speed                 │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --fit on                │ (on)      │ Auto-fits layers to GPU memory                                      │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ -ub 1024                │ 1024      │ Optimal ubatch for RADV on Strix Halo                               │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --ctx-size 131072       │ 131K      │ Half of native 262K — best speed/quality balance with q8_0 KV cache │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --cache-type-k/v        │ q8_0      │ Quantized KV cache keeps memory manageable at large context         │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --spec-draft-n-max 3    │ 3         │ MTP draft 3 tokens — sweet spot for Qwen3.6 MoE (Caleb's benchmark) │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --temp 0.6              │ 0.6       │ Optimal for coding per Qwen team                                    │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ --presence-penalty 0.0  │ 0.0       │ Coding tasks don't need presence penalty (Qwen team recommendation) │
 # ├─────────────────────────┼───────────┼─────────────────────────────────────────────────────────────────────┤
 # │ preserve_thinking: true │ (on)      │ Keeps reasoning traces across turns for agentic sessions            │
 # └─────────────────────────┴───────────┴─────────────────────────────────────────────────────────────────────┘
  alias "ai-Qwen3.6-35B-A3B-UDQ4S"='~/temp/llama.cpp/build/bin/llama-server \
    --port 8080 \
    -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_S \
    -ngl 999 \
    --no-mmap \
    --flash-attn on --fit on \
    --ctx-size 131072 \
    --ctx-checkpoints 8192 \
    --cache-type-k q8_0 --cache-type-v q8_0 \
    --kv-unified \
    --keep -1 \
    -np 1 \
    --jinja \
    --temp 0.6 \
    --top-p 0.95 \
    --top-k 20 \
    --min-p 0.05 \
    --repeat-penalty 1.0 \
    --presence-penalty 0.0 \
    --checkpoint-every-n-tokens 2048 \
    --chat-template-kwargs "{\"preserve_thinking\": true}" \
    --spec-type draft-mtp --spec-draft-n-max 3'


alias "ai-Qwen3.6-35B-A3B-0xSero"='~/temp/llama.cpp/build/bin/llama-server \
  --port 8080 \
  --mmproj ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-GGUF/snapshots/9280dd353ab587157920d5bd391ada414d84e552/mmproj-BF16.gguf \
  -m ~/.cache/huggingface/hub/models--0xSero--Qwen3.6-35B-A3B-GGUF-Strix/snapshots/96c5227ecdaf21c91b6a1bb1e43f176a119dbd7a/Qwen3.6-35B-A3B-Q4_K_M.gguf \
  --alias QWEN_A3B \
  -ngl 999 \
  --load-mode none \
  --parallel 1 \
  --ctx-checkpoints 8192 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --ctx-size 262144 \
  --batch-size 2048 \
  --ubatch-size 1024 \
  --image-min-tokens 1024 \
  --flash-attn on \
  --fit on \
  --keep -1 \
  -np 1 \
  --jinja \
  --reasoning-preserve \
  --chat-template-file ~/.cache/huggingface/hub/models--0xSero--Qwen3.6-35B-A3B-GGUF-Strix/snapshots/96c5227ecdaf21c91b6a1bb1e43f176a119dbd7a/chat_template.jinja \
  --temp 0.7 \
  --top-p 0.95 \
  --min-p 0.05 \
  --repeat-penalty 1.05'

  alias "ai-Qwen3.6-27B-MTP"='~/temp/rocmfp4-llama/build-strix-rocmfp4/bin/llama-server \
    -m ~/.cache/llama.cpp/local-models/ROCmFP4-STRIX_LEAN.gguf \
    --port 8080 \
    -ngl 999 \
    -c 262144 \
    -b 512 \
    -ub 512 \
    -fa on \
    -ctk q8_0 \
    -ctv q8_0 \
    --checkpoint-every-n-tokens 2048 \
    --ctx-checkpoints 8192 \
    --spec-type draft-mtp \
    --spec-draft-n-max 4 \
    --spec-draft-n-min 0 \
    --spec-draft-p-min 0.0 \
    --spec-draft-p-split 0.10 \
    --spec-draft-type-k q4_0 \
    --spec-draft-type-v q4_0 \
    --jinja
    --temp 0.6 \
    --top-p 0.95 \
    --top-k 20 \
    --min-p 0.05 \
    --repeat-penalty 1.0 \
    --alias LOCAL \
    --chat-template-kwargs "{\"preserve_thinking\": true}"'


  alias "ai-DENSEMTP"='~/temp/rocmfp4-llama/build-strix-rocmfp4/bin/llama-server \
    --port 8080 \
    -m ~/temp/rocmfp4-llama/model-ROCmFP4-STRIX_LEAN.gguf \
    --mmproj ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-27B-MTP-GGUF/snapshots/5cb35eb3dcbf52dbce5f87dbc64df6aaffadcace/mmproj-BF16.gguf \
    -ngl 999 \
    --no-mmap \
    --no-warmup \
    --flash-attn on \
    --ctx-size 131072 \
    --ctx-checkpoints 256 \
    --cache-type-k q4_0 \
    --cache-type-v q4_0 \
    --kv-unified \
    -np 1 \
    --jinja \
    --temp 0.6 \
    --top-p 0.95 \
    --top-k 20 \
    --min-p 0.00 \
    --repeat-penalty 1.0 \
    --presence-penalty 0.6 \
    --chat-template-kwargs "{\"preserve_thinking\": true}" \
    --spec-type ngram-mod,draft-mtp,ngram-map-k4v \
    --spec-draft-n-max 2 \
    --spec-ngram-mod-n-match 16 \
    --spec-ngram-mod-n-min 16 \
    --spec-ngram-mod-n-max 64 \
    --spec-ngram-map-k4v-size-n 16 \
    --spec-ngram-map-k4v-size-m 96 \
    --spec-ngram-map-k4v-min-hits 1 \
    --alias LOCAL'

alias "ai-qwen2.5-coder-3b"='~/temp/llama.cpp/build/bin/llama-server \
  --port 18080 \
  -m ~/.cache/huggingface/hub/models--bartowski--Qwen2.5-Coder-3B-Instruct-GGUF/snapshots/7c137640ef0332dfedb229f2504c58d83ed4307a/Qwen2.5-Coder-3B-Instruct-Q6_K_L.gguf \

  --alias QWEN_CODER_3B \
  -ngl 999 \
  --no-mmap \
  --flash-attn on --fit on \
  --ctx-size 4096 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --keep -1 \
  -np 1 \
  --jinja \
  --temp 0.4 \
  --top-p 0.95 \
  --top-k 40 \
  --min-p 0.05 \
  --repeat-penalty 1.1 \
  --chat-template-kwargs "{}"'

alias "ai-qwen2.5-coder-7b"='~/temp/llama.cpp/build/bin/llama-server \
  --port 18080 \
  -hf bartowski/Qwen2.5-Coder-7B-Instruct-GGUF \
  --alias QWEN_CODER_7B \
  -ngl 999 \
  --no-mmap \
  --flash-attn on --fit on \
  --ctx-size 4096 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --keep -1 \
  -np 1 \
  --jinja \
  --temp 0.4 \
  --top-p 0.95 \
  --top-k 40 \
  --min-p 0.05 \
  --repeat-penalty 1.1 \
  --chat-template-kwargs "{}"'

alias "ai-Qwen3.6-27B-CHADROCK"='~/temp/llama.cpp/build/bin/llama-server \
  --port 8080 \
  -hf unsloth/Qwen3.6-27B-MTP-GGUF:UD-Q4_K_XL \
  -ngl 999 \
  --no-mmap \
  -fa on \
  -ub 1024 \
  -c 131072 \
  -ctk q8_0 -ctv q8_0 \
  --spec-type draft-mtp --spec-draft-n-max 3 \
  -np 1 \
  --jinja \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0.05 \
  --repeat-penalty 1.0 \
  --chat-template-kwargs "{\"preserve_thinking\": true}"'

# alias "ai-Qwen3.6-35B-A3B-MTP"='~/temp/llama.cpp/build/bin/llama-server \
#   --port 8080 \
#   --mmproj ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-MTP-GGUF/snapshots/e28512781649329c5b37cbf55029355a48d158d4/mmproj-BF16.gguf \
#   -m ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-MTP-GGUF/snapshots/e28512781649329c5b37cbf55029355a48d158d4/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf \
#   --alias QWEN_A3B \
#   -ngl 999 \
#   --parallel 1 \
#   --checkpoint-every-n-tokens 2048 \
#   --ctx-checkpoints 8192 \
#   --cache-type-k q8_0 \
#   --cache-type-v q8_0 \
#   --ctx-size 202752 \
#   --batch-size 2048 \
#   --ubatch-size 1024 \
#   --flash-attn on \
#   --fit on \
#   --keep -1 \
#   -np 1 \
#   --jinja \
#   --temp 0.7 \
#   --top-p 0.95 \
#   --min-p 0.05 \
#   --repeat-penalty 1.0 \
#   --presence-penalty 1.5 \
#
#   --spec-type draft-mtp,ngram-mod \
#   --spec-draft-n-max 3 \
#   --spec-ngram-mod-n-match 16 \
#   --spec-ngram-mod-n-min 16 \
#   --spec-ngram-mod-n-max 64 \
#
#   --chat-template-kwargs "{\"preserve_thinking\": true}"'
  alias "ai-Qwen3.6-35B-A3B-MTP"='~/temp/llama.cpp/build/bin/llama-server \
    --port 8080 \
    -hf unsloth/Qwen3.6-35B-A3B-MTP-GGUF:UD-Q4_K_XL \
    --mmproj ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-MTP-GGUF/snapshots/e28512781649329c5b37cbf55029355a48d158d4/mmproj-BF16.gguf \
    -ngl 999 \
    --no-mmap \
    --flash-attn on \
    -ub 512 \
    -b 2048 \
    -c 131072 \
    -ctk q8_0 -ctv q8_0 \
    --spec-type draft-mtp --spec-draft-n-max 3 \
    -np 1 \
    --jinja \
    --temp 0.6 \
    --top-p 0.95 \
    --top-k 20 \
    --min-p 0.05 \
    --repeat-penalty 1.0 \
    --chat-template-kwargs "{\"preserve_thinking\": true}"'

alias "ai-qwen3.5-byteshape"='~/temp/llama.cpp/build/bin/llama-server \
  --port 8080 \
  -m ~/.cache/llama.cpp/Qwen3.5-35B-A3B-Q4_K_S-3.51bpw.gguf \
  --mmproj ~/.cache/llama.cpp/mmproj-bf16.gguf \
  --alias QWEN_SMALL \
  -ngl 999 \
  --no-mmap \
  --flash-attn on 
  --fit on \
  --ctx-size 202752 \
  --ctx-checkpoints 8192 \
  --cache-type-k q8_0 --cache-type-v q8_0 \
  --flash-attn on --fit on \
  --keep -1 \
  -np 1 \
  --jinja \
  --temp 0.6 \
  --top-p 0.95 \
  --top-k 20 \
  --min-p 0 \
  --presence-penalty 0 --repeat-penalty 1 \
  --checkpoint-every-n-tokens 2048 \
  --chat-template-kwargs "{\"enable_thinking\": true}"'

  alias "ai-Qwen3.6-35B-A3B-chadrock"='~/ai/ROCmFPX/build-strix-rocmfp4/bin/llama-server \
    -m ~/.cache/huggingface/hub/models--jcbtc--chadrock-35b-ace-saber-rocmfp4-mtp/snapshots/0fca0a9b66249e771d19ca2944daf5c744d6960c/Qwen3.6-35B-A3B-NSC-ACE-SABER-MTP-F16-to-ROCmFP4-STRIX_LEAN.gguf \
    --mmproj ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-MTP-GGUF/snapshots/e28512781649329c5b37cbf55029355a48d158d4/mmproj-BF16.gguf \
    --alias chadrock-35b-ace-saber-rocmfp4-cap4 \
    --host 127.0.0.1 \
    --port 8080 \
    --jinja \
    -c 262144 \
    --no-context-shift \
    --ctx-checkpoints 8192 \
    --checkpoint-every-n-tokens 2048 \
    -dev Vulkan0 \
    -ngl 999 \
    -fa on \
    -b 2048 \
    -ub 512 \
    -t 16 \
    -tb 32 \
    -ctk f16 \
    -ctv f16 \
    --temp 0 \
    --top-p 0.95 \
    --top-k 20 \
    --seed 123 \
    --parallel 1 \
    --no-mmproj \
    --metrics \
    --slot-prompt-similarity 0.0 \
    --spec-type draft-mtp \
    --spec-draft-device Vulkan0 \
    --spec-draft-ngl all \
    --spec-draft-threads 16 \
    --spec-draft-threads-batch 32 \
    --spec-draft-type-k f16 \
    --spec-draft-type-v f16 \
    --spec-draft-n-max 4 \
    --spec-draft-n-min 0 \
    --spec-draft-p-min 0.25 \
    --spec-draft-p-split 0.10 \
    --spec-draft-poll 1 \
    --spec-draft-poll-batch 1 \
    --presence-penalty 0 --repeat-penalty 1 \
    --chat-template-kwargs "{\"preserve_thinking\": true}"'

  alias "ai-Qwen3.6-Qwable-5-27B-chadrock"='~/ai/ROCmFPX/build-strix-rocmfp4/bin/llama-server \
    -m ~/.cache/huggingface/hub/models--jcbtc--Qwable-5-27B-Chadrock-v2-ROCmFP6-QUALITY/snapshots/9c10f8e0f05deebf81e862a72b37dd6fffa3c283/Qwable-5-27B-Chadrock-v2-ROCmFP6-QUALITY.gguf \
    --alias qwable-5-27b-chadrock-v2-rocmfp4 \
    --host 127.0.0.1 \
    --port 8080 \
    --jinja \
    -c 262144 \
    --no-context-shift \
    -dev Vulkan0 \
    -ngl 999 \
    -fa on \
    -b 2048 \
    -ub 512 \
    -t 16 \
    -tb 32 \
    -ctk q8_0 \
    -ctv q8_0 \
    --temp 0 \
    --top-p 0.95 \
    --top-k 20 \
    --seed 123 \
    --parallel 1 \
    --no-mmproj \
    --metrics \
    --no-webui \
    --slot-prompt-similarity 0.0 \
    --spec-type draft-mtp \
    --spec-draft-device Vulkan0 \
    --spec-draft-ngl all \
    --spec-draft-threads 16 \
    --spec-draft-threads-batch 32 \
    --spec-draft-type-k f16 \
    --spec-draft-type-v f16 \
    --spec-draft-n-max 6 \
    --spec-draft-n-min 0 \
    --spec-draft-p-min 0.0 \
    --spec-draft-p-split 0.20 \
    --no-spec-draft-backend-sampling \
    --spec-draft-poll 1 \
    --spec-draft-poll-batch 1 \
    --chat-template-kwargs "{\"preserve_thinking\": true}"'

# ============================================================================
# Aliases - Strix Halo llama.cpp (Vulkan, RADV fixes)
# ============================================================================

# Portable Vulkan build: https://github.com/Nathanw1014/strix-halo-llamacpp
# Bundles Mesa 26.3 RADV + libdrm — no host Mesa needed. Optimized for Strix Halo (gfx1151).
# Key wins: FA dequant-once, f16 KV contiguize, mmid row-list prepass → 2–3x prefill at depth.

alias "ai-strix"='~/temp/strix-halo-llamacpp/vulkan/llama-server \
  --port 18080 \
  --mmproj ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-GGUF/snapshots/9280dd353ab587157920d5bd391ada414d84e552/mmproj-BF16.gguf \
  -m ~/.cache/huggingface/hub/models--0xSero--Qwen3.6-35B-A3B-GGUF-Strix/snapshots/96c5227ecdaf21c91b6a1bb1e43f176a119dbd7a/Qwen3.6-35B-A3B-Q4_K_M.gguf \
  --alias QWEN_A3B \
  -ngl 999 \
  --load-mode none \
  --parallel 1 \
  --ctx-checkpoints 8192 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --ctx-size 262144 \
  --batch-size 2048 \
  --ubatch-size 1024 \
  --image-min-tokens 1024 \
  --flash-attn on \
  --fit on \
  --keep -1 \
  -np 1 \
  --jinja \
  --reasoning-preserve \
  --chat-template-file ~/.cache/huggingface/hub/models--0xSero--Qwen3.6-35B-A3B-GGUF-Strix/snapshots/96c5227ecdaf21c91b6a1bb1e43f176a119dbd7a/chat_template.jinja \
  --temp 0.7 \
  --top-p 0.95 \
  --min-p 0.05 \
  --repeat-penalty 1.05'


# Ornith-1.5 35B-A3B — recommended: temp=0.6, top_p=0.95
alias "ai-ornith-1.5"='~/temp/strix-halo-llamacpp/vulkan/llama-server \
  --port 8080 \
  --mmproj ~/.cache/huggingface/hub/models--ornith-ai--Ornith-1.5-35B-A3B-GGUF/snapshots/5ae357e3eaf951ae221e8d784c71a8a3cdb6aa5f/mmproj-Ornith-1.5-35B-BF16.gguf \
  -m ~/.cache/huggingface/hub/models--ornith-ai--Ornith-1.5-35B-A3B-GGUF/snapshots/5ae357e3eaf951ae221e8d784c71a8a3cdb6aa5f/Ornith-1.5-35B-Q4_K_M.gguf \
  --alias ORNITH_A3B \
  -ngl 999 \
  --load-mode none \
  --parallel 1 \
  --ctx-checkpoints 8192 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --ctx-size 262144 \
  --batch-size 2048 \
  --ubatch-size 1024 \
  --image-min-tokens 1024 \
  --flash-attn on \
  --fit on \
  --keep -1 \
  -np 1 \
  --jinja \
  --reasoning on \
  --reasoning-budget 700 \
  --reasoning-budget-message "\nThinking time expired. If a solid answer was found, deliver it now. If split between valid candidates, state them briefly and ask the user." \
  --reasoning-preserve \
  --chat-template-file ~/.cache/huggingface/hub/models--ornith-ai--Ornith-1.5-35B-A3B-GGUF/snapshots/5ae357e3eaf951ae221e8d784c71a8a3cdb6aa5f/chat_template.jinja \
  --temp 0.6 \
  --top-p 0.95 \
  --min-p 0.05 \
  --repeat-penalty 1.05'

alias "ai-qwen36-mtp"='~/temp/strix-halo-llamacpp/vulkan/llama-server \
     --port 18080 \
     -m ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-MTP-GGUF/snapshots/e28512781649329c5b37cbf55029355a48d158d4/Qwen3.6-35B-A3B-UD-Q4_K_XL.gguf \
     --mmproj ~/.cache/huggingface/hub/models--unsloth--Qwen3.6-35B-A3B-MTP-GGUF/snapshots/e28512781649329c5b37cbf55029355a48d158d4/mmproj-BF16.gguf \
     --alias QWEN36_A3B_MTP \
     -ngl 999 \
    --load-mode none \
    --parallel 1 \
    --ctx-checkpoints 8192 \
    --cache-type-k q8_0 \
    --cache-type-v q8_0 \
    --ctx-size 262144 \
    --batch-size 2048 \
    --ubatch-size 1024 \
    --image-min-tokens 1024 \
    --flash-attn on \
    --fit on \
    --keep -1 \
    -np 1 \
    --jinja \
    --reasoning on \
    --reasoning-budget 700 \
    --reasoning-budget-message "Thinking time expired. If a solid answer was found, deliver it now. If split between valid candidates, state them briefly and ask the user." \
    --reasoning-preserve \
    --chat-template-file ~/.cache/huggingface/hub/models--ornith-ai--Ornith-1.5-35B-A3B-GGUF/snapshots/5ae357e3eaf951ae221e8d784c71a8a3cdb6aa5f/chat_template.jinja \
    --temp 0.6 \
    --top-p 0.95 \
    --min-p 0.05 \
    --repeat-penalty 1.05'


# Sharp chat template (peculiar-ragdoll/Qwen-Sharp-Chat-Templates, v22.1.1).
# Drop-in fix for Qwen3.5/3.6/3.8 — cuts filler, leads with the answer, steers
# reasoning effort via chat_template_kwargs (none/minimal/low/medium/high/xhigh).
# Template co-located with the Ornith model blob so llama.cpp auto-detects it.
#
alias "ai-ornith"=' GGML_VK_MMID_ROWLISTS=1 GGML_VK_MMID_SMALLN=1 GGML_VK_MMID_BM64=1 \
   GGML_VK_MMID_WAVE32=1 GGML_VK_MMID_F16B=1 GGML_VK_MMID_M128=1 \
   GGML_VK_FA_KV_CONTIG=1 \
  ~/temp/strix-halo-llamacpp/vulkan/llama-server \
  --port 8080 \
  --mmproj ~/.cache/huggingface/hub/models--ornith-ai--Ornith-1.5-35B-A3B-GGUF/snapshots/5ae357e3eaf951ae221e8d784c71a8a3cdb6aa5f/mmproj-Ornith-1.5-35B-BF16.gguf \
  -m ~/.cache/huggingface/hub/models--ornith-ai--Ornith-1.5-35B-A3B-GGUF/snapshots/5ae357e3eaf951ae221e8d784c71a8a3cdb6aa5f/Ornith-1.5-35B-Q4_K_M.gguf \
  --alias ORNITH_A3B \
  -ngl 999 \
  --load-mode none \
  --parallel 1 \
  --ctx-checkpoints 8192 \
  --cache-type-k q8_0 \
  --cache-type-v q8_0 \
  --ctx-size 163840 \
  --batch-size 2048 \
  --ubatch-size 1024 \
  --image-min-tokens 1024 \
  --flash-attn on \
  --fit on \
  --keep -1 \
  -np 1 \
  --jinja \
  --reasoning on \
  --reasoning-budget 700 \
  --reasoning-budget-message "Thinking time expired. If a solid answer was found, deliver it now. If split between valid candidates, state them briefly and ask the user." \
  --reasoning-preserve \
  --chat-template-file ~/.cache/huggingface/hub/models--ornith-ai--Ornith-1.5-35B-A3B-GGUF/snapshots/5ae357e3eaf951ae221e8d784c71a8a3cdb6aa5f/chat_template.jinja \
  --temp 0.6 \
  --top-p 0.95 \
  --min-p 0.05 \
  --repeat-penalty 1.05'

alias 'ai-q38rocm'='~/temp/strix-halo-llamacpp/vulkan/llama-server \
    -m ~/q38rocm/Qwen3.8-27B-ROCmFP4-FAST.gguf \
    -dev Vulkan0 \
    -ngl 99 \
    -fa on \
    -np 1 \
    -ctxcp 0 \
    -cram 16384 \
    -c 32768 \
    -b 2048 \
    -ub 1024 \
    -t 16 \
    --poll 100 \
    -ctk q8_0 \
    --port 8080 \
    --host 0.0.0.0 \
    --spec-type draft-mtp \
    --spec-draft-n-max 6 \
    --spec-draft-p-min 0.60 \
    --log-disable'

# Qwen3.8-27B-ROCmFP4-FAST on the ROCm (HIP) build — single-user interactive burst.
# Params per julianmb/q38rocm benchmarks: Asymmetric TurboQuant KV (K=q8_0, V=turbo4),
# MTP depth K=4 optimal for a single stream (interactive burst n5/p0.50); n6 is bus-saturating.
alias 'ai-q38rocm-rocm'='~/temp/ROCmFPX/build-strix-rocmfp4/bin/llama-server \
    -m ~/q38rocm/Qwen3.8-27B-ROCmFP4-FAST.gguf \
    -dev ROCm0 \
    -ngl 99 \
    -fa on \
    -np 1 \
    -ctxcp 0 \
    -cram 16384 \
    -c 32768 \
    -b 2048 \
    -ub 1024 \
    -t 16 \
    --poll 100 \
    -ctk q8_0 \
    -ctv turbo4 \
    --port 18080 \
    --host 127.0.0.1 \
    --spec-type draft-mtp \
    --spec-draft-n-max 5 \
    --spec-draft-p-min 0.50'

_aichat_zsh() {
    if [[ -n "$BUFFER" ]]; then
        local _old=$BUFFER
        BUFFER+="⌛"
        zle -I && zle redisplay
        BUFFER=$(aichat -e "$_old")
        zle end-of-line
    fi
}
zle -N _aichat_zsh
bindkey '\ee' _aichat_zsh
