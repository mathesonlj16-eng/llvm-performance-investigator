#include <cstddef>
#include <cstdint>

extern "C" void ordinary(std::uint32_t* dst, const std::uint32_t* src, std::size_t n) {
    for (std::size_t i = 0; i < n; ++i)
        dst[i] = src[i] + 1u;
}

extern "C" void restricted(std::uint32_t* __restrict dst,
                           const std::uint32_t* __restrict src, std::size_t n) {
    for (std::size_t i = 0; i < n; ++i)
        dst[i] = src[i] + 1u;
}
