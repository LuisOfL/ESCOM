#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>

void max_min_iterativo(int A[], int n, int *max, int *min) {
    if (n == 0) {
        *max = *min = 0;
        return;
    }
    
    *max = A[0];
    *min = A[0];
    
    for (int i = 1; i < n; i++) {
        if (A[i] > *max) {
            *max = A[i];
        } else if (A[i] < *min) {
            *min = A[i];
        }
    }
}

void max_min_recursivo(int A[], int i, int j, int *max, int *min) {
    if (i == j) {
        *max = A[i];
        *min = A[i];
    } else if (i == j - 1) {
        if (A[i] > A[j]) {
            *max = A[i];
            *min = A[j];
        } else {
            *max = A[j];
            *min = A[i];
        }
    } else {
        int mitad = (i + j) / 2;
        int max1, min1, max2, min2;
        

        max_min_recursivo(A, i, mitad, &max1, &min1);
        max_min_recursivo(A, mitad + 1, j, &max2, &min2);
        
      
        *max = (max1 > max2) ? max1 : max2;
        *min = (min1 < min2) ? min1 : min2;
    }
}

void wrapper_max_min_recursivo(int A[], int n, int *max, int *min) {
    if (n == 0) {
        *max = *min = 0;
        return;
    }
    max_min_recursivo(A, 0, n - 1, max, min);
}


void generar_arreglo(int A[], int n) {
    for (int i = 0; i < n; i++) {
        A[i] = rand() % 200001 - 100000; 
    }
}


void comparar_tiempos(int tamano_arreglo) {
    int *A = (int*)malloc(tamano_arreglo * sizeof(int));
    

    generar_arreglo(A, tamano_arreglo);
    
    printf("\n============================================================\n");
    printf("PRUEBA CON ARREGLO DE TAMAÑO: %d\n", tamano_arreglo);
    printf("============================================================\n");
    
    int max_iter, min_iter, max_rec, min_rec;
    clock_t inicio, fin;
    double tiempo_iterativo, tiempo_recursivo;
    

    inicio = clock();
    max_min_iterativo(A, tamano_arreglo, &max_iter, &min_iter);
    fin = clock();
    tiempo_iterativo = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
    

    inicio = clock();
    wrapper_max_min_recursivo(A, tamano_arreglo, &max_rec, &min_rec);
    fin = clock();
    tiempo_recursivo = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
  
    assert(max_iter == max_rec && min_iter == min_rec);
    

    printf("METODO ITERATIVO:\n");
    printf("  Tiempo: %.6f segundos\n", tiempo_iterativo);
    printf("  Maximo: %d, Minimo: %d\n", max_iter, min_iter);
    
    printf("\nMETODO RECURSIVO:\n");
    printf("  Tiempo: %.6f segundos\n", tiempo_recursivo);
    printf("  Maximo: %d, Minimo: %d\n", max_rec, min_rec);
    
    printf("\nCOMPARACION:\n");
    printf("  Diferencia de tiempo: %.6f segundos\n", 
           (tiempo_iterativo > tiempo_recursivo) ? 
           tiempo_iterativo - tiempo_recursivo : tiempo_recursivo - tiempo_iterativo);
    
    if (tiempo_iterativo < tiempo_recursivo) {
        printf("  El metodo ITERATIVO es %.2f veces mas rapido\n", 
               tiempo_recursivo / tiempo_iterativo);
    } else {
        printf("  El metodo RECURSIVO es %.2f veces mas rapido\n", 
               tiempo_iterativo / tiempo_recursivo);
    }
    
    free(A);
}


void realizar_pruebas() {
    
    int tamanos[] = {10, 100, 1000, 10000, 50000, 100000};
    int num_tamanos = sizeof(tamanos) / sizeof(tamanos[0]);
    
    printf("\n================================================================================\n");
    printf("RESUMEN DE RESULTADOS\n");
    printf("================================================================================\n");
    printf("%-10s %-15s %-15s %-15s %-10s\n", 
           "Tamaño", "Iterativo (s)", "Recursivo (s)", "Diferencia (s)", "Razón");
    printf("--------------------------------------------------------------------------------\n");
    
    for (int i = 0; i < num_tamanos; i++) {
        int tamano = tamanos[i];
        int *A = (int*)malloc(tamano * sizeof(int));
        generar_arreglo(A, tamano);
        
        int max_iter, min_iter, max_rec, min_rec;
        clock_t inicio, fin;
        double tiempo_iterativo, tiempo_recursivo;
  
        inicio = clock();
        max_min_iterativo(A, tamano, &max_iter, &min_iter);
        fin = clock();
        tiempo_iterativo = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
        
        inicio = clock();
        wrapper_max_min_recursivo(A, tamano, &max_rec, &min_rec);
        fin = clock();
        tiempo_recursivo = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
        
        double diferencia = (tiempo_iterativo > tiempo_recursivo) ? 
                           tiempo_iterativo - tiempo_recursivo : tiempo_recursivo - tiempo_iterativo;
        double razon = (tiempo_iterativo > 0) ? tiempo_recursivo / tiempo_iterativo : 0;
        
        printf("%-10d %-15.6f %-15.6f %-15.6f %-10.2f\n", 
               tamano, tiempo_iterativo, tiempo_recursivo, diferencia, razon);
        
        free(A);
    }
}


void prueba_rapida() {
   
    int tamano = 1000;  
    
    comparar_tiempos(tamano);
}

int main() {

    srand(time(NULL));
    
    printf("COMPARADOR DE ALGORITMOS MAXIMO Y MINIMO\n");
    printf("Selecciona una opcion:\n");
    printf("1. Prueba rapida (un solo tamaño)\n");
    printf("2. Prueba completa (multiples tamaños)\n");
    
    int opcion;
    printf("Ingresa tu opcion (1 o 2): ");
    scanf("%d", &opcion);
    
    if (opcion == 1) {
        prueba_rapida();
    } else if (opcion == 2) {
        realizar_pruebas();
    } else {
        printf("Opcion invalida. Ejecutando prueba rapida por defecto.\n");
        prueba_rapida();
    }
    
    return 0;
}
