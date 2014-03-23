#include <cstdio>
#include <stdint.h>
using namespace std;

int main() {
    uint64_t derp;
    scanf("%lld", &derp);
    int num_bits = __builtin_popcountll(derp);
    printf("%d\n", num_bits);
    return 0;
}
