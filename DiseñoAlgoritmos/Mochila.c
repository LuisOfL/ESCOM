#include <stdio.h>

#define MAX(a,b) ((a) > (b) ? (a) : (b))

int knapsack(int W, int val[], int wt[], int n) {
    int dp[n+1][W+1];
    
    for(int i = 0; i <= n; i++) {
        for(int w = 0; w <= W; w++) {
            if(i == 0 || w == 0)
                dp[i][w] = 0;
            else if(wt[i-1] <= w)
                dp[i][w] = MAX(val[i-1] + dp[i-1][w-wt[i-1]], dp[i-1][w]);
            else
                dp[i][w] = dp[i-1][w];
        }
    }
    return dp[n][W];
}

int main() {
    // Primera configuración: 5 objetos
    int val1[] = {60, 60, 20, 30, 40};
    int wt1[] = {10, 10, 100, 120, 200};
    int n1 = 5;
    
    // Segunda configuración: 3 objetos  
    int val2[] = {20, 30, 40};
    int wt2[] = {100, 120, 200};
    int n2 = 3;
    
    int capacidades[] = {50, 100, 125, 220, 300};
    int num_cap = 5;
    
    // Imprimir encabezados de la tabla
    printf("bj\\wW    ");
    for(int i = 0; i < n1; i++) 
        printf("%d      ", val1[i]);
    for(int i = 0; i < n2; i++) 
        printf("%d      ", val2[i]);
    printf("\n");
    
    printf("   \\W    ");
    for(int i = 0; i < n1; i++) 
        printf("%d      ", wt1[i]);
    for(int i = 0; i < n2; i++) 
        printf("%d      ", wt2[i]);
    printf("\n");
    
    printf("----------------------------------------------------------------------\n");
    
    // Calcular y mostrar resultados para cada capacidad
    for(int c = 0; c < num_cap; c++) {
        int W = capacidades[c];
        printf("%d      ", W);
        
        // Primera configuración (5 objetos) - mostrar todos los resultados individuales
        for(int i = 0; i < n1; i++) {
            int single_val[] = {val1[i]};
            int single_wt[] = {wt1[i]};
            int result = knapsack(W, single_val, single_wt, 1);
            printf("%d      ", result);
        }
        
        // Segunda configuración (3 objetos) - mostrar todos los resultados individuales
        for(int i = 0; i < n2; i++) {
            int single_val[] = {val2[i]};
            int single_wt[] = {wt2[i]};
            int result = knapsack(W, single_val, single_wt, 1);
            printf("%d      ", result);
        }
        
        printf("\n");
    }
    
    return 0;
}
