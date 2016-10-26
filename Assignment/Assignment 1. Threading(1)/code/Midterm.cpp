#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <float.h>
#include <math.h>
#include <iostream>

#include <pthread.h>
#include <semaphore.h>
#include <time.h>


using namespace std;
int counter = 0;
pthread_mutex_t mu;

void *run(void* input ) {
  int * result = (int *)malloc(sizeof(int));
  *result = ((int *)input)[0] + 1;
  pthread_mutex_lock(&mu);
  counter++;
  pthread_mutex_unlock(&mu);
  printf("Thread [%d] result is [%d]\n",((int *)input)[0],result);
  pthread_exit((void *)result);
}

int main() {
  /* code */
  int var;
  var = 1;
  pthread_t thread1, thread2;
  pthread_create(&thread1,NULL,&run,&var);
  int var2 = 3;
  pthread_create(&thread2,NULL,&run,&var2);

  int res[2];
  int * res_pointer[2];
  void * temp;

  pthread_join(thread1,&temp);
  res[0] = (*(int*)temp);
  res_pointer[0] = (int*)temp;
  pthread_join(thread2,&temp);
  pthread_exit(NULL);
  res[1] = (*(int*)temp);
  res_pointer[1] = (int*)temp;
  printf("%d, %d, %d\n",res[0],res[1],counter);
  printf("result address is[%d][%d]\n",res_pointer[0],res_pointer[1]);
  free(res_pointer[0]);
  free(res_pointer[1]);

  return 0;
}
