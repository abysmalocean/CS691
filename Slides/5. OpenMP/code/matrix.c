#include <stdio.h>
#include <omp.h>

#define SIZE 5000
int a[SIZE][SIZE];
int b[SIZE][SIZE];
int c[SIZE][SIZE];


void main()
{
	#pragma omp parallel for shared(a,b,c) schedule(static,500)
			for (int m = 0; m < SIZE; m++)
			{
				for (int n = 0; n < SIZE; n++)
				{
					a[m][n] = m;
					c[m][n] = 0;
					b[m][n] = n;

				}
			}
			
	# pragma omp parallel for shared(a,b,c) schedule(static,500)
			for (int i = 1; i <= (SIZE - 2); i++)
			{
				for (int j = 1; j <= (SIZE - 2); j++)
				{
					c[i][j] = a[j][i] * b[i][j];
					printf("C[%d][%d]=%d\n",i,j,c[i][j]);
				}
			}
}
