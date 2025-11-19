n = 4  

A = [
    [0, 0, 1, 0],
    [1, 0, 0, 1],
    [1, 1, 0, 1],
    [0, 0, 0, 0]
]

d = 0.85  

M = [[0 for _ in range(n)] for _ in range(n)]

for j in range(n):
    col_sum = sum(A[i][j] for i in range(n))
    if col_sum == 0:
        for i in range(n):
            M[i][j] = 1 / n
    else:
        for i in range(n):
            M[i][j] = A[i][j] / col_sum

P = [[d * M[i][j] + (1 - d) / n for j in range(n)] for i in range(n)]

r = [1 / n for _ in range(n)]
tolerancia = 1e-6
max_iter = 100
iteracion = 0


while iteracion < max_iter:
    r_new = [0 for _ in range(n)]
    for i in range(n):
        r_new[i] = sum(P[i][j] * r[j] for j in range(n))

    diff = sum(abs(r_new[i] - r[i]) for i in range(n))
    if diff < tolerancia:
        break

    r = r_new
    iteracion += 1
    
print(f"PageRank final después de {iteracion} iteraciones:")
for i, score in enumerate(r):
    print(f"Página {i+1}: {score:.4f}")
