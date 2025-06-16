import numpy as np
import matplotlib.pyplot as plt
from scipy.fftpack import dct, idct
from PIL import Image
import tkinter as tk
from tkinter import filedialog, messagebox

# DCT2 e IDCT2
def dct2(block):
    return dct(dct(block.T, norm='ortho').T, norm='ortho')

def idct2(block):
    return idct(idct(block.T, norm='ortho').T, norm='ortho')

# Compressione immagine
def process_image(img_array, F, d_threshold):
    H, W = img_array.shape
    H = (H // F) * F
    W = (W // F) * F
    img_array = img_array[:H, :W]
    result = np.zeros_like(img_array)

    for i in range(0, H, F):
        for j in range(0, W, F):
            block = img_array[i:i+F, j:j+F]
            c = dct2(block)
            for k in range(F):
                for l in range(F):
                    if k + l >= d_threshold:
                        c[k, l] = 0
            ff = idct2(c)
            ff = np.round(ff)
            ff = np.clip(ff, 0, 255)
            result[i:i+F, j:j+F] = ff

    return img_array, result

# Interfaccia grafica
class DCTApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Compressione DCT2 Immagini")
        self.file_path = None
        self.img_array = None

        # Selezione file
        self.btn_file = tk.Button(root, text="Seleziona file immagine", command=self.select_file)
        self.btn_file.pack(pady=10)

        # Input F
        self.label_f = tk.Label(root, text="Inserisci F (dimensione blocchi):")
        self.label_f.pack()
        self.entry_f = tk.Entry(root)
        self.entry_f.pack()

        # Input d
        self.label_d = tk.Label(root, text="Inserisci d (soglia frequenze):")
        self.label_d.pack()
        self.entry_d = tk.Entry(root)
        self.entry_d.pack()

        # Bottone esegui
        self.btn_run = tk.Button(root, text="Esegui compressione", command=self.run_compression)
        self.btn_run.pack(pady=10)

    def select_file(self):
        path = filedialog.askopenfilename(filetypes=[("Immagini BMP", "*.bmp")])
        if path:
            try:
                img = Image.open(path).convert('L')
                self.img_array = np.array(img)
                self.file_path = path
                messagebox.showinfo("File caricato", "Immagine caricata con successo!")
            except Exception as e:
                messagebox.showerror("Errore", f"Errore nel caricamento dell'immagine: {e}")

    def run_compression(self):
        if self.img_array is None:
            messagebox.showwarning("Attenzione", "Seleziona prima un'immagine.")
            return

        try:
            F = int(self.entry_f.get())
            d = int(self.entry_d.get())
            if not (0 <= d <= 2*F - 2):
                raise ValueError(f"d deve essere tra 0 e {2*F - 2}")
        except Exception as e:
            messagebox.showerror("Errore", f"Valori non validi: {e}")
            return

        original, processed = process_image(self.img_array, F, d)

        # Visualizza immagini
        plt.figure(figsize=(12, 6))
        plt.subplot(1, 2, 1)
        plt.title("Originale")
        plt.imshow(original, cmap='gray')
        plt.axis('off')

        plt.subplot(1, 2, 2)
        plt.title(f"Compressione DCT2 (F={F}, d={d})")
        plt.imshow(processed, cmap='gray')
        plt.axis('off')

        plt.tight_layout()
        plt.show()

# Avvia applicazione
if __name__ == "__main__":
    root = tk.Tk()
    app = DCTApp(root)
    root.mainloop()
