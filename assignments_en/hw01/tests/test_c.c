#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

int32_t add_word(int32_t acc, int32_t value);
int32_t sum_array(const int32_t *values, uint32_t count);

static void expect_u32(const char *name, uint32_t actual, uint32_t expected)
{
    if (actual != expected) {
        fprintf(stderr, "FAIL %s expected=0x%08x actual=0x%08x\n",
                name, expected, actual);
        exit(1);
    }
}

int main(void)
{
    const int32_t sample[] = {5, -2, 9, -7};
    const int32_t negative[] = {-4, -8, 3};

    expect_u32("add basic", (uint32_t)add_word(7, -2), 5u);
    expect_u32("add wrap", (uint32_t)add_word((int32_t)0xffffffffu, 1), 0u);
    expect_u32("sum empty", (uint32_t)sum_array(sample, 0), 0u);
    expect_u32("sum sample", (uint32_t)sum_array(sample, 4), 5u);
    expect_u32("sum negative", (uint32_t)sum_array(negative, 3), 0xfffffff7u);

    puts("PASS C software contract cases=5");
    return 0;
}
