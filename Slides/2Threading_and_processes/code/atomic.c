#include <stdio.h>
#include <stdatomic.h>
#include "c11threads.h"

atomic_int atomic_counter[200];
//= (atomic_int*)malloc(20 * sizeof(atomic_int));
//atomic_counter = (int*)malloc(20 * sizeof(atomic_int));

int regular_counter = 0;

int thread(void* param)
{
    for(int i = 0; i < 200; i++) {
        atomic_counter[i] = atomic_counter[i] + i;
        regular_counter++;
    }
}

int main(void)
{
    thrd_t thr[10];

    for(int i = 0; i < 10; i++)
        thrd_create(&thr[i], thread, NULL);

    for(int i = 0; i < 10; i++)
        thrd_join(thr[i], NULL);

    printf("The regular_counter counter is %u\n", regular_counter);
    printf("Size of the atomic counter is %d",sizeof(atomic_counter[0]));
    for(int i = 0; i < 200; i ++)
    {
    printf("The atomic counter[%d] is %u\n",i ,atomic_counter[i]);
    }
}
