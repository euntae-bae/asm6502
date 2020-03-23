#include <stdio.h>

void bubbleSort(int *arr, int len)
{
    int i, j;
    int temp;
    for (i = len - 1; i > 0; i--) {
        for (j = 0; j < i; j++) {
            if (arr[j] > arr[j + 1]) {
                temp = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = temp;
            }
        }
    }
}

void printArr(const int *arr, int len)
{
    int i;
    for (i = 0; i < len; i++)
        printf("%d ", arr[i]);
    printf("\n");
}

int main(void)
{
    int arr[10] = { 5, 39, 11, 57, 4, 26, 92, 67, 0, 10 };
    bubbleSort(arr, 10);
    printArr(arr, 10);
    return 0;
}