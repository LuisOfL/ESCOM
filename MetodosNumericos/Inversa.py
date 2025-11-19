n = int(input("Ingresa el tamaño de la matriz (n x n): "))

A = []
for i in range(n):
    fila = []
    for j in range(n):
        valor = float(input(f"Ingresa A[{i+1},{j+1}]: "))
        fila.append(valor)
    A.append(fila)


I = [[1 if i == j else 0 for j in range(n)] for i in range(n)]


for i in range(n):
    factor = A[i][i]
    if factor == 0:
        raise ValueError("No se puede invertir la matriz (pivot 0).")
    for j in range(n):
        A[i][j] /= factor
        I[i][j] /= factor

    for k in range(n):
        if k != i:
            factor = A[k][i]
            for j in range(n):
                A[k][j] -= factor * A[i][j]
                I[k][j] -= factor * I[i][j]

print("\nMatriz Inversa:")
for fila in I:
    print(fila)
