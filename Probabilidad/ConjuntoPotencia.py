def ConjPow(set):
    n = 2**len(set)
    l = []
    for x in range(n):
        temp = []
        for y in range(len(set)):
            if (x>>y) & 1:
                temp.append(set[y])
        l.append(temp)
    return l
        
