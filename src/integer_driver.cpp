#include "integer_driver.hpp"

int main(int argc, char** argv) {
    std::size_t size{}, rounds{};
    if (argc != 3 || !argument(argv[1], 100'000'000, size) ||
        !argument(argv[2], 1'000'000, rounds)) return 2;
    std::vector<Word> a(size + 1), b(size);
    Word state = 12345;
    for (auto& x : a) {
        state = 1664525u * state + 1013904223u;
        x = state >> 16;
    }
    for (std::size_t i = 0; i < size; ++i) b[i] = i % 251;

    std::array<Sum, 2> expected{};
    for (unsigned offset = 0; offset < 2; ++offset) {
        expected[offset] = reference(a.data() + offset, b.data(), size);
        if (kernel(a.data() + offset, b.data(), size) != expected[offset]) return 1;
    }
    Sum checksum = 0;
    auto start = std::chrono::steady_clock::now();
    for (std::size_t r = 0; r < rounds; ++r)
        checksum += kernel(a.data() + (r % 2), b.data(), size);
    auto end = std::chrono::steady_clock::now();
    if (checksum != expected[0] * ((rounds + 1) / 2) + expected[1] * (rounds / 2)) return 1;
    std::cout << std::setprecision(15) << "elapsed_ms="
              << std::chrono::duration<double, std::milli>(end - start).count()
              << "\nchecksum=" << checksum << "\nmax_error=0\n";
}

