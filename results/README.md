# Evaluation Results

These files are generated from real local experiments against the current Docker/Compose-backed crawler implementation. Do not copy old CSVs into this directory: the report intentionally reads these generated files so it cannot display stale numbers from the previous architecture.

## Data files

- `results/raw/evaluation_results.json`: combined raw JSON output from the experiment run.
- `results/processed/crawl_scaling.csv`: worker-count scaling measurements from independent worker subprocesses.
- `results/processed/worker_contribution.csv`: per-worker page counts from scaling runs.
- `results/processed/indexing_scaling.csv`: streaming-indexer drain time and index-size measurements.
- `results/processed/streaming_indexer_lag.csv`: index_outbox lag while the real streaming indexer drains events.
- `results/processed/pagerank_convergence.csv`: L1 delta per PageRank power-iteration pass.
- `results/processed/query_latency.csv`: FastAPI search latency over repeated HTTP requests.
- `results/processed/search_correctness.json`: deterministic streaming index/search correctness validation.
- `results/processed/fault_tolerance.csv`: one-worker-terminated experiment result.
- `results/processed/bloom_memory_calculation.csv`: Bloom filter formula output and exact-set memory baseline.
- `results/processed/memory_efficiency.csv`: Bloom versus exact-set memory comparison for graphing.
- `results/processed/redis_latency.csv`: Redis frontier, Bloom, lock, and robots-cache operation latency.
- `results/processed/redis_memory_usage.csv`: Redis benchmark memory usage for temporary keys.
- `results/processed/mongodb_latency.csv`: MongoDB transaction, outbox claim, posting upsert, and search aggregation latency.
- `results/processed/sustained_throughput_windows.csv`: throughput-window summaries derived from measured scaling runs.
- `results/processed/resource_scaling_1_20.csv`: CPU, memory, Redis memory, and throughput data from 1-to-20 worker resource runs.

## Figures

Figures in `results/figures/` and `report/figures/` are generated only from the processed data above.

## Reproduction

Start Redis and MongoDB first:

```powershell
docker compose up -d
```

Run experiments:

```powershell
python scripts/run_evaluation_experiments.py
python scripts/run_resource_scaling_1_20.py
python scripts/run_report_supplement_metrics.py
```

Generate figures:

```powershell
python scripts/generate_evaluation_graphs.py
```

Compile the report:

```powershell
pdflatex -interaction=nonstopmode -output-directory report report/main.tex
pdflatex -interaction=nonstopmode -output-directory report report/main.tex
```

## Limitations

The crawl experiments use a deterministic local website spread across multiple ports to simulate multiple domains. Workers still use the real Redis frontier, processing ledger, MongoDB transactions, MinIO blob store, streaming indexer, PageRank worker, and search aggregation path. The local fixture makes the results reproducible, but it does not capture real-world DNS variance, ISP/CDN latency, or anti-bot defences.
