n = int(input("Ingresa el tamaño de la matriz (n x n): "))

mat_A = []
mat_B = []


for i in range(n):
    fila = []
    for j in range(n):
        valor = float(input(f"Ingresa A[{i+1},{j+1}]: "))
        fila.append(valor)
    mat_A.append(fila)


for i in range(n):
    valor = float(input(f"Ingresa B[{i+1}]: "))
    mat_B.append(valor)



x_old = [0.0 for _ in range(n)]  
x_new = x_old.copy()
tolerancia = 0.0001
max_iter = 100
iteracion = 0


while True:
    for i in range(n):
        suma = 0
        for j in range(n):
            if j != i:
                suma += mat_A[i][j] * x_old[j]
        x_new[i] = (mat_B[i] - suma) / mat_A[i][i]

    diff = [abs(x_new[i] - x_old[i]) for i in range(n)]
    if max(diff) < tolerancia or iteracion >= max_iter:
        break

    x_old = x_new.copy()
    iteracion += 1

print("\n------------MATRIZ A-------------")
for fila in mat_A:
    print(fila)

print("\n------------MATRIZ B-------------")
print(mat_B)

print("\n------------RESULTADOS-------------")
print(x_new)
