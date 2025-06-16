import numpy as np
import matplotlib.pyplot as plt
from scipy.fftpack import dct
import time
from DCT2 import dct2  # Importa la tua DCT2 fatta in casa

# Implementazione DCT2 veloce usando SciPy (DCT tipo II)
def dct2_fast(x):
    return dct(dct(x.T, norm='ortho').T, norm='ortho')

# Dimensioni da testare
N_values = [128, 256, 512]
time_naive = []
time_fast = []

# Misurazione tempi
for N in N_values:
    x = np.random.rand(N, N)

    # Tempo per DCT2 fatta in casa
    start = time.time()
    dct_naive_result = dct2(x)
    end = time.time()
    time_naive.append(end - start)

    # Tempo per DCT2 veloce
    start = time.time()
    dct_fast_result = dct2_fast(x)
    end = time.time()
    time_fast.append(end - start)

    print(f"Done for N = {N}")
    
print("Valori N:", N_values)
print("Tempi naive:", time_naive)
print("Tempi fast: ", time_fast)
# Plot dei tempi in scala semilogaritmica (y)
plt.figure(figsize=(10, 6))
plt.semilogy(N_values, time_naive, 'o-', label='DCT2 fatta in casa (N³)')
plt.semilogy(N_values, time_fast, 's-', label='DCT2 veloce (FFT)')

plt.xlabel('Dimensione N')
plt.ylabel('Tempo di esecuzione (s) [Scala log]')
plt.title('Confronto tra DCT2 fatta in casa e DCT2 veloce (FFT)')
plt.legend()
plt.grid(True, which="both", ls="--")
plt.tight_layout()
plt.show()
