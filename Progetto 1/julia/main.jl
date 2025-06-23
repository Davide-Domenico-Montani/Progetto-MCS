using BenchmarkTools
using MatrixMarket
using SparseArrays
using LinearAlgebra
using Glob

function load_matrix_from_mtx(path::String)
    A = MatrixMarket.mmread(path)
    return sparse(A)
end

# funzione che verifica che la matrice sia simmetrica e positiva
function cholesky_solve(A::SparseMatrixCSC{Float64, Int})
    
    # Verifica se la matrice è simmetrica
    if A ≈ A' 
            if isposdef(A) # Verifica che la matrice sia positiva
            
                n = size(A, 1)             # Recupera numero di righe (quindi anche colonne) di A
                xe = ones(n)               # Vettore soluzione esatta lungo n tutti 1
                b = A * xe                 # Costruzione del termine noto

                result = @timed begin      # Misurazione tempo
                    F = cholesky(A)
                    x = F \ b              # Soluzione del sistema
                end

                #Calcolo errore relativo
                rel_error = norm(x - xe) / norm(xe)

                return result.time, result.bytes, rel_error
            else
                println("La matrice è simmetrica ma non è definita positiva")
                return 0,0,0
            end
    else
        println("✘ La matrice NON è simmetrica.")
        return 0,0,0
    end
end

#Percorso della cartella delle matrici, inserito negli argomenti, quando si esegue il codice
directory_path = ARGS[1]

# Ottiene la lista di tutti i file .mtx nella directory
matrices_files = glob("*.mtx", directory_path)

# Cicla su ogni file e processa
for file_path in matrices_files
            println("Processando matrice: $file_path")
            # carica la matrice
            A = load_matrix_from_mtx(file_path)
            # richiama la funzione per risolvere la matrice
            t, mem, err = cholesky_solve(A)

            #Stampa risultati
            println("Tempo: $(round(t*1000, digits=2)) ms")
            println("Memoria: $(mem ÷ 1024) KB")
            println("Errore relativo: $err")
            println("##################################")
end
