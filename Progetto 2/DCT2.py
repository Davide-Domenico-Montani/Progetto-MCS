import numpy as np

# Struttura di supporto per la DCT (simile a un oggetto mutabile)
class DCTSupport:
    def __init__(self, N):
        self.sqrt_N = np.sqrt(N)
        self.sqrt_2 = np.sqrt(2)
        self.coeff = np.pi / (2 * N)
        self.result = np.zeros(N)

def dct(v, support=None):
    """
    Esegue la Discrete Cosine Transform (DCT) sul vettore v.
    Se viene passato un oggetto support, vengono riutilizzati i parametri precalcolati e il buffer.
    """
    N = len(v)
    
    if support is None:
        sqrt_N = np.sqrt(N)
        sqrt_2 = np.sqrt(2)
        coeff = np.pi / (2 * N)
        result = np.zeros(N)
    else:
        sqrt_N = support.sqrt_N
        sqrt_2 = support.sqrt_2
        coeff = support.coeff
        result = support.result
        if result is None:
            result = np.zeros(N)

    for k in range(N):
        a_k = 0.0
        coeff_k = coeff * k
        for i in range(N):
            a_k += np.cos(coeff_k * (2 * i + 1)) * v[i]
        result[k] = (a_k / sqrt_N) * sqrt_2
    
    result[0] /= sqrt_2
    return result.copy()  # copia per sicurezza

def dct2(matrix):
    """
    Esegue la Discrete Cosine Transform 2D su una matrice (N x M).
    Applica la DCT sulle righe, poi sulle colonne.
    """
    matrix = np.asarray(matrix, dtype=np.float64)
    N, M = matrix.shape
    result = np.empty_like(matrix)

    # Struttura di supporto per righe
    support = DCTSupport(N)

    # DCT su ogni riga
    for i in range(N):
        result[i, :] = dct(matrix[i, :], support)

    # Riutilizzo della struttura per le colonne
    col_v = np.zeros(N)
    support.result = np.zeros(N)

    # DCT su ogni colonna
    for j in range(M):
        for i in range(N):
            col_v[i] = result[i, j]
        transformed = dct(col_v, support)
        for i in range(N):
            result[i, j] = transformed[i]

    return result
