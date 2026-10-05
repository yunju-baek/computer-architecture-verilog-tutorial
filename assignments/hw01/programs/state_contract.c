#include <stdint.h>

/* Provided behavioral reference. Student implementation belongs in assembly. */
static int32_t signed_word(uint32_t value)
{
    return value <= INT32_MAX ? (int32_t)value : -1 - (int32_t)(UINT32_MAX - value);
}

int32_t add_word(int32_t acc, int32_t value)
{
    return signed_word((uint32_t)acc + (uint32_t)value);
}

int32_t sum_array(const int32_t *values, uint32_t count)
{
    int32_t acc = 0;
    for (uint32_t index = 0; index < count; ++index) {
        acc = add_word(acc, values[index]);
    }
    return acc;
}
