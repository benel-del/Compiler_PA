int isPrime(int p);
int main(void){
        int a[10], i;
        a[0] = 2;
        for(i=1;i<10;i++){
                for(a[i] = a[i-1]+1;isPrime(a[i]) == 0;a[i]++);
        }
        return 0;
}
int isPrime(int p){
        int i, r;
        i = 2;
        do{
                r = p % i++;
        }while(i<p && r > 0);
        if(i == p)      return 1;
        else    return 0;
}