def combinatoria_recursiva(n, k):
    # Casos base
    if k == 0 or k == n:
        return 1
    # Recursión: elegir o no el elemento n
    return combinatoria_recursiva(n-1, k-1) + combinatoria_recursiva(n-1, k)

print(combinatoria_recursiva(5, 2))
