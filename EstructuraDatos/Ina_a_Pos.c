#include<stdio.h>

void In_a_Pos(char *in, char *post){
     int i=0;
     while(in[i]!='\0')
         printf("%c\n",in[i++]);
}
void In_a_Pos2(char *in, char *post){
     int i=0;
     while(*(in+i)!='\0')
         printf("%c\n",*(in+i++));
}
int main(int argc, char *argv[]){
    int i;
    printf("Numero de argumentos: %d.\n",argc);
    for(i=0;i<argc;i++)
        printf("%s\n",argv[i]);

    puts("-------------");
    In_a_Pos(*(argv+1),*(argv+1));

    puts("-------------");
    In_a_Pos2(*(argv+3),*(argv+1));

    return 0;
}
