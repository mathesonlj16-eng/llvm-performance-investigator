#include "integer_driver.hpp"

// Order-sensitive recurrence over selected elements, with defined unsigned wraparound.
Sum kernel(const Word* a, const Word* b, std::size_t size) {
    Sum hash = 0;
    for (std::size_t i = 0; i < size; ++i)
        if (a[i] >= 32768) hash = hash * 33 + b[i];
    return hash;
}

Sum reference(const Word* a, const Word* b, std::size_t size) {
    Sum hash = 0, weight = 1;
    while (size--) {
        if (a[size] < 32768) continue;
        hash += weight * b[size];
        weight *= 33;
    }
    return hash;
}

