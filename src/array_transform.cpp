#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstddef>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <vector>

// Keep the operation in a separate function so we can inspect it in assembly.
#if defined(__clang__) || defined(__GNUC__)
__attribute__((noinline))
#endif
void transform(const float* a, const float* b, float* out, std::size_t size) {
    for (std::size_t i = 0; i < size; ++i) {
        out[i] = a[i] * 1.25f + b[i];
    }
}

int main(int argc, char** argv) {
    try {
        if (argc != 3) {
            std::cerr << "Usage: benchmark <array-size> <rounds>\n";
            return 2;
        }
        const auto size = std::stoull(argv[1]);
        const auto rounds = std::stoull(argv[2]);
        if (size == 0 || size > 100'000'000 || rounds == 0 || rounds > 1'000'000) {
            std::cerr << "Invalid size or rounds\n";
            return 2;
        }
        std::vector<float> a(size), b(size), output(size);
        for (std::size_t i = 0; i < size; ++i) {
            a[i] = static_cast<float>(i % 1024) * 0.001f;
            b[i] = static_cast<float>(i % 251) * 0.002f;
        }

        transform(a.data(), b.data(), output.data(), size);  // Warm up.
        const auto start = std::chrono::steady_clock::now();
        for (std::size_t round = 0; round < rounds; ++round) {
            // Changing one input each round prevents treating repeated passes as identical.
            a[(round * 97) % size] += 0.0001f;
            transform(a.data(), b.data(), output.data(), size);
        }
        const auto end = std::chrono::steady_clock::now();

        // Independently validate the final output using double-precision math.
        double checksum = 0.0;
        double max_error = 0.0;
        for (std::size_t i = 0; i < size; ++i) {
            const double expected = static_cast<double>(a[i]) * 1.25 + static_cast<double>(b[i]);
            const double error = std::abs(static_cast<double>(output[i]) - expected);
            max_error = std::max(max_error, error);
            if (error > 1e-5 * (1.0 + std::abs(expected))) {
                std::cerr << "Correctness failure at index " << i << "\n";
                return 1;
            }
            checksum += output[i];
        }
        const double elapsed_ms = std::chrono::duration<double, std::milli>(end - start).count();
        std::cout << std::setprecision(15)
                  << "elapsed_ms=" << elapsed_ms << "\n"
                  << "checksum=" << checksum << "\n"
                  << "max_error=" << max_error << "\n";
    } catch (const std::exception& error) {
        std::cerr << "Error: " << error.what() << "\n";
        return 2;
    }
}
