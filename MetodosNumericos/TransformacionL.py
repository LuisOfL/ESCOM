def transformacion_lineal_simple(matriz, vector):

    if len(matriz[0]) != len(vector):
        raise ValueError("Dimensiones incompatibles")
    
    resultado = []
    for fila in matriz:
        suma = 0
        for i in range(len(vector)):
            suma += fila[i] * vector[i]
        resultado.append(suma)
    
    return resultado

# Ejemplo de uso
matriz_rotacion = [[0, -1], [1, 0]]  # Rotación 90°
vector = [2, 5]
resultado = transformacion_lineal_simple(matriz_rotacion, vector)
print(f"Vector transformado: {resultado}") 
