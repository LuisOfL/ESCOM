#include<stdio.h>

int main(int argc, char *argv[]){
    FILE *in=fopen(*++argv,"r");
    FILE *out=fopen(*++argv,"w");

    char c;

    while((c=fgetc(in))!=EOF)
        fputc(c,out);
    fclose(in);
    fclose(out);

    return 0;
}
