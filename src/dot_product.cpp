#include "integer_driver.hpp"

Sum kernel(const Word* a, const Word* b, std::size_t size) {
    Sum total = 0;
    for (std::size_t i = 0; i < size; ++i)
        total += a[i] * b[i];  // Input bounds keep each product within 32 bits.
    return total;
}

Sum reference(const Word* a, const Word* b, std::size_t size) {
    Sum total = 0;
    while (size--) total += Sum(a[size]) * b[size];
    return total;
}

