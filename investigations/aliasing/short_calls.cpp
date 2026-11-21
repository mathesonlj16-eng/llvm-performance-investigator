#include <algorithm>
#include <array>
#include <chrono>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

using Word = std::uint32_t;
using Kernel = void (*)(Word*, const Word*, std::size_t);
extern "C" void ordinary(Word*, const Word*, std::size_t);
extern "C" void restricted(Word*, const Word*, std::size_t);

constexpr int calls = 500000;
alignas(64) static std::array<Word, 256> data;

[[gnu::noinline]] static long long batch(Kernel kernel, std::size_t n) {
    auto start = std::chrono::steady_clock::now();
    for (int i = 0; i < calls; ++i)
        kernel(data.data() + 128, data.data(), n);
    return std::chrono::duration_cast<std::chrono::nanoseconds>(
        std::chrono::steady_clock::now() - start).count();
}

int main() {
    for (Word i = 0; i < 128; ++i) data[i] = i % 7 ? i * i : UINT32_MAX;
    constexpr std::array<int, 8> sizes{0, 1, 4, 16, 31, 32, 33, 64};
    std::puts("pair,position,n,kernel,calls,elapsed_ns");
    for (int pair = -2; pair < 12; ++pair) {
        for (int j = 0; j < 8; ++j) {
            int n = sizes[(j + pair + 2) % sizes.size()];
            for (int pos = 0; pos < 2; ++pos) {
                bool use_restricted = (pair + 2 + pos) % 2;
                constexpr Word sentinel = 0xdeadbeef;
                std::fill(data.begin() + 128, data.end(), sentinel);
                long long elapsed = batch(use_restricted ? restricted : ordinary, n);
                for (int i = 0; i < 128; ++i) {
                    Word expected = i < n ? data[i] + 1u : sentinel;
                    if (data[128 + i] != expected) std::abort();
                }
                if (pair >= 0)
                    std::printf("%d,%d,%d,%s,%d,%lld\n", pair, pos, n,
                                use_restricted ? "restricted" : "ordinary", calls, elapsed);
            }
        }
    }
}
