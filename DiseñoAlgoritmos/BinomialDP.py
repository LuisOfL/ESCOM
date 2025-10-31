def binomialDP_optimizado(n, k):
    C = [0] * (k + 1)
    C[0] = 1

    for i in range(1, n + 1):
        for j in range(min(i, k), 0, -1):
            C[j] = C[j] + C[j - 1]

    return C[k]

print(binomialDP_optimizado(5, 2))  
