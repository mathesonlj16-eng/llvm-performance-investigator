#include <stdint.h>
#include <stdio.h>

extern uint32_t scale32(uint32_t);
extern uint64_t scale64(uint64_t);
extern uint64_t identity(uint64_t);

int main(void) {
  const uint64_t values[] = {
      0, 1, 3, 17, 0x123456789abcdef0ULL,
      INT32_MAX, (uint64_t)INT32_MAX + 1, UINT32_MAX,
      INT64_MAX, (uint64_t)INT64_MAX + 1, UINT64_MAX
  };
  for (unsigned i = 0; i < sizeof(values) / sizeof(values[0]); ++i) {
    uint64_t x = values[i];
    if (scale32((uint32_t)x) != (uint32_t)x * UINT32_C(8) ||
        scale64(x) != x * (UINT64_C(1) << 62) || identity(x) != x) {
      fprintf(stderr, "unexpected value for case %u\n", i);
      return 1;
    }
  }
  return 0;
}
