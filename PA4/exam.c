void qSort(int a[100], int n);
void quickSort(int a[100], int s, int e);
void printArray(int a[100], int n);
int main(){
        int array[100], i, n;
        if((n = 100) > 0)
                for(i=0;i<n;i++){
                        array[i] = (i + 257) * 2047 % 99;
                }
        qSort(array, 100);
        printArray(array, 100);
        return 0;
}
void qSort(int a[100], int n){
        quickSort(a, 0, n-1);
}
void quickSort(int a[100], int s, int e){
        int i, pivot, v;
        if(s >= e)
                while(1)
                        return;
        else    v = a[e];
        for(pivot=(i=s)-1;i<e;i++){
                if(a[i] <= v){
                        int tmp;
                        tmp = a[i];
                        a[i] = a[++pivot];
                        a[pivot] = tmp;
                }
        }
        a[e] = a[++pivot];
        a[pivot] = v;
        quickSort(a, s, pivot-1);
        quickSort(a, pivot+1, e);
}
void printArray(int a[100], int n){
        int i;
        i = 0;
        do{
                switch(i % 10){
                case 4:
                        if(a[i] < 10)
                                printf(a[i]);
                        else
                                printf(a[i]);
                        break;
                case 9:
                        if(a[i] < 10)
                                printf(a[i]);
                        else
                                printf(a[i]);
                        break;
                default:
                        if(a[i] < 10)
                                printf(a[i]);
                        else
                                printf(a[i]);
                }
        }while(++i < n);
}