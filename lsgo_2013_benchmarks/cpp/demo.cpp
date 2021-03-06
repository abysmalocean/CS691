#include "Header.h"
#include <sys/time.h>
#include <cstdio>
#include <unistd.h>


int main(int argc, char* argv[]){
  /*  Test the basic benchmark function */
  double* X;
  Benchmarks* fp=NULL;
  unsigned dim = 1000000;
  //unsigned funToRun[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};

   unsigned funToRun[] = {3};
  // unsigned funToRun[] = {15};
  unsigned funNum = 1;
  unsigned run = 1;
  char *p;
  if (argc == 2)
  {
    run = (unsigned)strtol(argv[1], &p, 10);
  }

  vector<double> runTimeVec;
  struct timeval start, end;
  long seconds, useconds;
  double mtime;
  double resultTest;

  X = new double[dim];
  for (unsigned i=0; i<dim; i++){
    X[i]=0;
  }


  for (unsigned i=0; i<funNum; i++){
    fp = generateFuncObj(funToRun[i]);
    printf("F %d value = %1.20E\n", fp->getID(), resultTest = fp->compute(X));
    gettimeofday(&start, NULL);
    for (unsigned j=0; j < run; j++){
      if (fp->compute(X) - resultTest > 0.1)
      {
        printf("result not equal to the previous result\n" );
      }
    }
    gettimeofday(&end, NULL);

    seconds  = end.tv_sec  - start.tv_sec;
    useconds = end.tv_usec - start.tv_usec;

    mtime = (((seconds) * 1000 + useconds/1000.0) + 0.5)/1000;

    runTimeVec.push_back(mtime);
    //printf ( "F %d, Running Time = %f s\n\n", fp->getID(), mtime);

    //TODO GPU Computing
    printf("\n*****************GPU Computing Result***************************\n\n");
  for (unsigned j=0; j < run; j++){
    printf("[%d] Times Run\n",j );
    fp->GPUcomputefunction(X,resultTest,run);
  }
    delete fp;
  }

  delete []X;

  // for (unsigned i=0; i<runTimeVec.size(); i++){
  // 	printf ( "%f\n", runTimeVec[i] );
  // }

  return 0;
}

// create new object of class with default setting
Benchmarks* generateFuncObj(int funcID){
  Benchmarks *fp;
  // run each of specified function in "configure.ini"
  if (funcID==1){
    fp = new F1();
  }else if (funcID==2){
    fp = new F2();
  }else if (funcID==3){
    fp = new F3();
  }else if (funcID==4){
    fp = new F4();
  }else if (funcID==5){
    fp = new F5();
  }else if (funcID==6){
    fp = new F6();
  }else if (funcID==7){
    fp = new F7();
  }else if (funcID==8){
    fp = new F8();
  }else if (funcID==9){
    fp = new F9();
  }else if (funcID==10){
    fp = new F10();
  }else if (funcID==11){
    fp = new F11();
  }else if (funcID==12){
    fp = new F12();
  }else if (funcID==13){
    fp = new F13();
  }else if (funcID==14){
    fp = new F14();
  }else if (funcID==15){
    fp = new F15();
  }else{
    cerr<<"Fail to locate Specified Function Index"<<endl;
    exit(-1);
  }
  return fp;
}
