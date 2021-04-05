int d;
int gcd(int a, int b);
int main(){
        printf("gcd = %d\n", gcd('\n', 12));
        return 0;
}
int gcd(int a, int b){
        do{
                d = a % b;
                a = b;
        }while((b = d) != 0);
        return a;
}