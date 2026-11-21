#pragma once
#include <array>
#include <charconv>
#include <chrono>
#include <cstdint>
#include <iomanip>
#include <iostream>
#include <string_view>
#include <vector>

using Word = std::uint32_t;
using Sum = std::uint64_t;

// Defined in a separate translation unit. No LTO: the caller must issue every call.
Sum kernel(const Word*, const Word*, std::size_t);
Sum reference(const Word*, const Word*, std::size_t);

inline bool argument(std::string_view text, std::size_t limit, std::size_t& value) {
    auto [end, error] = std::from_chars(text.data(), text.data() + text.size(), value);
    return error == std::errc{} && end == text.data() + text.size() && value && value <= limit;
}

