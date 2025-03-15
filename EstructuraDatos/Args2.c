#include<stdio.h>

int main(int argc, char *argv[]){
    FILE *in=fopen(*++argv,"r");
    char c;

    while((c=fgetc(in))!=EOF)
        putchar(c);

    return 0;
}
