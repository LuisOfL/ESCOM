#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>

int coef_bino_bottom_up(int n, int k) {
    if (k < 0 || k > n) return 0;
    if (k == 0 || k == n) return 1;
    

    int **tabla = (int **)malloc((n+1) * sizeof(int *));
    for (int i = 0; i <= n; i++) {
        tabla[i] = (int *)malloc((k+1) * sizeof(int));
    }
    
  
    for (int i = 0; i <= n; i++) {
        tabla[i][0] = 1;
    }
    
    for (int i = 1; i <= n; i++) {
        for (int j = 1; j <= (i < k ? i : k); j++) {
            if (j == i) {
                tabla[i][j] = 1;
            } else {
                tabla[i][j] = tabla[i-1][j-1] + tabla[i-1][j];
            }
        }
    }
    
    int resultado = tabla[n][k];
    
    for (int i = 0; i <= n; i++) {
        free(tabla[i]);
    }
    free(tabla);
    
    return resultado;
}


double measure_execution_time(int n, int k) {
    clock_t start, end;
    

    int repetitions = 1000;
    int result;
    
    start = clock();
    for (int i = 0; i < repetitions; i++) {
        result = coef_bino_bottom_up(n, k);
    }
    end = clock();
    
    double total_time = ((double)(end - start)) / CLOCKS_PER_SEC * 1000.0;
    return total_time / repetitions;
}


void format_number_with_commas(int num, char *buffer) {
    if (num < 1000) {
        sprintf(buffer, "%d", num);
        return;
    }
    
    char temp[20];
    sprintf(temp, "%d", num);
    
    int len = strlen(temp);
    int comma_pos = len % 3;
    if (comma_pos == 0) comma_pos = 3;
    
    int j = 0;
    for (int i = 0; i < len; i++) {
        buffer[j++] = temp[i];
        if (i == comma_pos - 1 && i < len - 1) {
            buffer[j++] = ',';
            comma_pos += 3;
        }
    }
    buffer[j] = '\0';
}

void print_separator() {
    printf("+------+------+---------------------+-------------------+\n");
}

void print_results_table() {
    int pruebas[][2] = {{4,2}, {5,3}, {7,4}, {9,5}, {35,6}};
    int num_pruebas = sizeof(pruebas) / sizeof(pruebas[0]);
    

    printf("\n");
    print_separator();
    printf("|  n   |  k   | Resultado Bottom-up | Tiempo ejecución  |\n");
    print_separator();
    
    for (int i = 0; i < num_pruebas; i++) {
        int n = pruebas[i][0];
        int k = pruebas[i][1];
        
        int resultado = coef_bino_bottom_up(n, k);
        double tiempo = measure_execution_time(n, k);
        

        char resultado_str[20];
        if (resultado > 1000) {
            format_number_with_commas(resultado, resultado_str);
        } else {
            sprintf(resultado_str, "%d", resultado);
        }
        
        printf("|  %2d  |  %2d  | %19s | %11.3f ms    |\n", 
               n, k, resultado_str, tiempo);
    }
    
    print_separator();
}


void show_detailed_calculations() {
    printf("\n=== CÁLCULOS DETALLADOS ===\n");
    
    int pruebas[][2] = {{4,2}, {5,3}, {7,4}, {9,5}, {35,6}};
    int num_pruebas = sizeof(pruebas) / sizeof(pruebas[0]);
    
    for (int i = 0; i < num_pruebas; i++) {
        int n = pruebas[i][0];
        int k = pruebas[i][1];
        int resultado = coef_bino_bottom_up(n, k);
        
        printf("\nC(%d, %d) = ", n, k);
        
        if (n <= 10) {
            printf("%d! / (%d! × %d!) = ", n, k, n-k);
            
            long long fact_n = 1, fact_k = 1, fact_nk = 1;
            for (int j = 1; j <= n; j++) fact_n *= j;
            for (int j = 1; j <= k; j++) fact_k *= j;
            for (int j = 1; j <= (n-k); j++) fact_nk *= j;
            
            printf("%lld / (%lld × %lld) = %lld / %lld = %d", 
                   fact_n, fact_k, fact_nk, fact_n, fact_k * fact_nk, resultado);
        } else {

            printf("%d × %d × ... / (%d × %d × ...) = ", n, n-1, k, k-1);
            
            char resultado_str[20];
            format_number_with_commas(resultado, resultado_str);
            printf("%s", resultado_str);
        }
    }
    printf("\n");
}

int main() {
    printf("=================================================\n");
    printf("      TABLA DE COEFICIENTES BINOMIALES\n");
    printf("         (Algoritmo Bottom-Up DP)\n");
    printf("=================================================\n");
    

    print_results_table();
    

    show_detailed_calculations();
    

    printf("\n=== INFORMACIÓN ADICIONAL ===\n");
    printf("Método utilizado: Programación Dinámica (Bottom-Up)\n");
    printf("Complejidad: O(n × k)\n");
    printf("Complejidad espacial: O(n × k)\n");
    printf("Tiempos medidos en milisegundos (promedio de 1000 ejecuciones)\n");
    
    return 0;
}
