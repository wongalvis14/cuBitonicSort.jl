# cuBitonicSort.jl
Bitonic sort using CuArrays (Julia CUDA)

Improvement directions:
- eliminate warp divergence due to OOR elements
- warp-level optimizations https://www.epfl.ch/labs/lap/wp-content/uploads/2018/05/YeApr10_HighPerformanceComparisonBasedSortingAlgorithmOnManyCoreGpus_IPDPS10.pdf
