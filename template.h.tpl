#ifndef __UNIJIS_UTF_CVT__
#define __UNIJIS_UTF_CVT__
#include <string>

/*%SHIFT_JIS_UTF8_GROUPS%*/

char16_t* shiftJisUtf16Map[16] =
{
/*%SHIFT_JIS_UTF8_GROUP_MAP%*/
};

int ShiftJisToUtf16(const char* input, int inputLength, char16_t* output, int maxOutputLength)
{
    int len = 0;
    int i;

    for(len = 0, i = 0; len < maxOutputLength && i < inputLength; i++)
    {
        char value = input[i];
        int group = 0;
        if(value >= 0x80)
        {
            output[len] = shiftJisUtf16Map[value | 0xF0][(value << 8) | input[i + 1]];
            i++;
        }
        else
        {
            output[len] = shiftJisUtf16Map[0][value];
        }

        len++;
    }

    return len;
}
#endif