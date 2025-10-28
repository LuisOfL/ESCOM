#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <limits.h>
#include <math.h> 


int kadane_iterativo(int A[], int n, int *inicio, int *fin) {
    if (n == 0) {
        *inicio = *fin = -1;
        return 0;
    }
    
    int max_sum = A[0];
    int current_sum = A[0];
    int temp_inicio = 0;
    *inicio = *fin = 0;
    
    for (int i = 1; i < n; i++) {
        if (current_sum + A[i] > A[i]) {
            current_sum += A[i];
        } else {
            current_sum = A[i];
            temp_inicio = i;
        }
        
        if (current_sum > max_sum) {
            max_sum = current_sum;
            *inicio = temp_inicio;
            *fin = i;
        }
    }
    
    return max_sum;
}


int max_suma_cruzando_medio(int A[], int izquierda, int medio, int derecha, 
                           int *cruz_inicio, int *cruz_fin) {
    int suma_izq = INT_MIN;
    int suma_temp = 0;
    *cruz_inicio = medio;
    
    for (int i = medio; i >= izquierda; i--) {
        suma_temp += A[i];
        if (suma_temp > suma_izq) {
            suma_izq = suma_temp;
            *cruz_inicio = i;
        }
    }
    int suma_der = INT_MIN;
    suma_temp = 0;
    *cruz_fin = medio + 1;
    
    for (int i = medio + 1; i <= derecha; i++) {
        suma_temp += A[i];
        if (suma_temp > suma_der) {
            suma_der = suma_temp;
            *cruz_fin = i;
        }
    }
    
    return suma_izq + suma_der;
}

int max_suma_subarreglo_recursivo(int A[], int izquierda, int derecha, 
                                 int *inicio, int *fin) {
    if (izquierda == derecha) {
        *inicio = *fin = izquierda;
        return A[izquierda];
    }
    
    int medio = (izquierda + derecha) / 2;
    
    int izq_inicio, izq_fin, der_inicio, der_fin, cruz_inicio, cruz_fin;
    
    int suma_izq = max_suma_subarreglo_recursivo(A, izquierda, medio, &izq_inicio, &izq_fin);
    int suma_der = max_suma_subarreglo_recursivo(A, medio + 1, derecha, &der_inicio, &der_fin);
    int suma_cruz = max_suma_cruzando_medio(A, izquierda, medio, derecha, &cruz_inicio, &cruz_fin);
    
    if (suma_izq >= suma_der && suma_izq >= suma_cruz) {
        *inicio = izq_inicio;
        *fin = izq_fin;
        return suma_izq;
    } else if (suma_der >= suma_izq && suma_der >= suma_cruz) {
        *inicio = der_inicio;
        *fin = der_fin;
        return suma_der;
    } else {
        *inicio = cruz_inicio;
        *fin = cruz_fin;
        return suma_cruz;
    }
}

int divide_y_venceras(int A[], int n, int *inicio, int *fin) {
    if (n == 0) {
        *inicio = *fin = -1;
        return 0;
    }
    return max_suma_subarreglo_recursivo(A, 0, n - 1, inicio, fin);
}


void generar_arreglo(int A[], int n) {
    for (int i = 0; i < n; i++) {
        A[i] = rand() % 2001 - 1000; 
    }
}

void comparar_tiempos(int tamano_arreglo) {
    int *A = (int*)malloc(tamano_arreglo * sizeof(int));
    generar_arreglo(A, tamano_arreglo);
    
    printf("\n============================================================\n");
    printf("PRUEBA CON ARREGLO DE TAMAÑO: %d\n", tamano_arreglo);
    printf("============================================================\n");
    
    int inicio_kadane, fin_kadane, inicio_div, fin_div;
    int suma_kadane, suma_div;
    clock_t inicio, fin;
    double tiempo_kadane, tiempo_divide;

    inicio = clock();
    suma_kadane = kadane_iterativo(A, tamano_arreglo, &inicio_kadane, &fin_kadane);
    fin = clock();
    tiempo_kadane = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
    
    inicio = clock();
    suma_div = divide_y_venceras(A, tamano_arreglo, &inicio_div, &fin_div);
    fin = clock();
    tiempo_divide = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
    
    assert(suma_kadane == suma_div);
    
    printf("KADANE (Iterativo O(n)):\n");
    printf("  Tiempo: %.6f segundos\n", tiempo_kadane);
    printf("  Suma máxima: %d\n", suma_kadane);
    printf("  Subarreglo: [%d, %d]\n", inicio_kadane, fin_kadane);
    
    printf("\nDIVIDE Y VENCERÁS (Recursivo O(n log n)):\n");
    printf("  Tiempo: %.6f segundos\n", tiempo_divide);
    printf("  Suma máxima: %d\n", suma_div);
    printf("  Subarreglo: [%d, %d]\n", inicio_div, fin_div);
    
    printf("\nCOMPARACION:\n");
    printf("  Diferencia de tiempo: %.6f segundos\n", 
           tiempo_divide - tiempo_kadane);
    
    if (tiempo_kadane < tiempo_divide) {
        printf("  Kadane es %.2f veces más rápido\n", 
               tiempo_divide / tiempo_kadane);
    } else {
        printf("  Divide y Vencerás es %.2f veces más rápido\n", 
               tiempo_kadane / tiempo_divide);
    }
    
    printf("  Ventaja de Kadane: %.2fx\n", tiempo_divide / tiempo_kadane);
    
    free(A);
}

void realizar_pruebas_completas() {
    int tamanos[] = {10, 100, 500, 1000, 5000, 10000, 50000, 100000};
    int num_tamanos = sizeof(tamanos) / sizeof(tamanos[0]);
    
    printf("\n================================================================================\n");
    printf("COMPARACIÓN COMPLETA: KADANE vs DIVIDE Y VENCERÁS\n");
    printf("================================================================================\n");
    printf("%-10s %-15s %-15s %-15s %-10s %-10s\n", 
           "Tamaño", "Kadane O(n)", "Divide O(n log n)", "Diferencia", "Razón", "Ventaja");
    printf("--------------------------------------------------------------------------------\n");
    
    for (int i = 0; i < num_tamanos; i++) {
        int tamano = tamanos[i];
        int *A = (int*)malloc(tamano * sizeof(int));
        generar_arreglo(A, tamano);
        
        int inicio1, fin1, inicio2, fin2;
        clock_t inicio, fin;
        double tiempo_kadane, tiempo_divide;

        inicio = clock();
        kadane_iterativo(A, tamano, &inicio1, &fin1);
        fin = clock();
        tiempo_kadane = ((double)(fin - inicio)) / CLOCKS_PER_SEC;

        inicio = clock();
        divide_y_venceras(A, tamano, &inicio2, &fin2);
        fin = clock();
        tiempo_divide = ((double)(fin - inicio)) / CLOCKS_PER_SEC;
        
        double diferencia = tiempo_divide - tiempo_kadane;
        double razon = (tiempo_kadane > 0) ? tiempo_divide / tiempo_kadane : 0;
        double ventaja = (tiempo_kadane > 0) ? tiempo_divide / tiempo_kadane : 0;
        
        printf("%-10d %-15.6f %-15.6f %-15.6f %-10.2f %-10.2fx\n", 
               tamano, tiempo_kadane, tiempo_divide, diferencia, razon, ventaja);
        
        free(A);
    }
    
    printf("\nANÁLISIS DE RESULTADOS:\n");
    printf("- Kadane (O(n)) es más eficiente para todos los tamaños\n");
    printf("- La ventaja de Kadane aumenta con el tamaño del arreglo\n");
    printf("- Divide y Vencerás (O(n log n)) tiene mayor overhead por recursión\n");
}

void prueba_rapida() {
    printf("PRUEBA RÁPIDA - Tamaño 1000\n");
    comparar_tiempos(1000);
}

void demostrar_complejidad() {
    printf("\n============================================================\n");
    printf("ANÁLISIS DE COMPLEJIDAD TEÓRICA\n");
    printf("============================================================\n");
    
    printf("KADANE (Iterativo):\n");
    printf("- Complejidad: O(n)\n");
    printf("- Una sola pasada por el arreglo\n");
    printf("- Uso de memoria: O(1)\n");
    printf("- Óptimo para este problema\n\n");
    
    printf("DIVIDE Y VENCERÁS (Recursivo):\n");
    printf("- Complejidad: O(n log n)\n");
    printf("- Ecuación: T(n) = 2T(n/2) + O(n)\n");
    printf("- Uso de memoria: O(log n) por pila de recursión\n");
    printf("- Más intuitivo pero no óptimo\n\n");
    
    printf("COMPARACIÓN TEÓRICA:\n");
    printf("n\tO(n)\tO(n log n)\tRazón\n");
    printf("----------------------------------------\n");
    
    int tamanos[] = {10, 100, 1000, 10000, 100000};
    for (int i = 0; i < 5; i++) {
        int n = tamanos[i];
        double n_val = n;
        double nlogn = n * log2(n);
        double razon = nlogn / n_val;
        printf("%d\t%.0f\t%.0f\t\t%.2fx\n", n, n_val, nlogn, razon);
    }
}

int main() {
    srand(time(NULL));
    
    printf("COMPARADOR: KADANE vs DIVIDE Y VENCERÁS\n");
    printf("========================================\n");
    printf("Selecciona una opcion:\n");
    printf("1. Prueba rápida (tamaño 1000)\n");
    printf("2. Prueba completa (múltiples tamaños)\n");
    printf("3. Análisis de complejidad teórica\n");
    
    int opcion;
    printf("Ingresa tu opcion (1-3): ");
    scanf("%d", &opcion);
    
    switch(opcion) {
        case 1:
            prueba_rapida();
            break;
        case 2:
            realizar_pruebas_completas();
            break;
        case 3:
            demostrar_complejidad();
            break;
        default:
            printf("Opción inválida. Ejecutando prueba completa.\n");
            realizar_pruebas_completas();
    }
    
    return 0;
}
