#include <array>
#include <cstddef>
#include <cstdint>
#include <cstdio>

using Word = std::uint32_t;
extern "C" void ordinary(Word*, const Word*, std::size_t);
extern "C" void restricted(Word*, const Word*, std::size_t);

int main() {
    // Compare the entire allocation to catch out-of-range writes in its margins.
    for (int n : {0, 1, 3, 4, 7, 8, 31, 32, 33, 65, 129}) {
        for (int delta : {-160, -32, -1, 0, 1, 31, 32, 33, 160}) {
            constexpr int src = 170;
            const int dst = src + delta;
            std::array<Word, 480> initial{};
            for (unsigned i = 0; i < initial.size(); ++i)
                initial[i] = (i % 7 == 0) ? UINT32_MAX : i * i + 19;
            auto expected = initial;
            for (int i = 0; i < n; ++i)
                expected[dst + i] = expected[src + i] + 1u;

            for (auto kernel : {ordinary, restricted}) {
                if (kernel == restricted && n > 0 && delta < n && delta > -n)
                    continue;
                auto actual = initial;
                kernel(actual.data() + dst, actual.data() + src, n);
                if (actual != expected) {
                    std::fprintf(stderr, "%s failed: n=%d, dst-src=%d elements\n",
                                 kernel == ordinary ? "ordinary" : "restricted", n, delta);
                    return 1;
                }
            }
        }
    }
}
