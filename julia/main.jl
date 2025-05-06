using BenchmarkTools
using MatrixMarket
using SparseArrays
using LinearAlgebra
using Glob  # Per elencare i file con estensione .mtx

function load_matrix_from_mtx(path::String)
    A = MatrixMarket.mmread(path)
    return sparse(A)
end

function is_symmetric_and_positive_definite(A::SparseMatrixCSC{Float64, Int})
    # Verifica se la matrice è simmetrica
    if A ≈ A' #check simmetrica
            if isposdef(A)
            
                n = size(A, 1)             # Recupera numero di righe (quindi anche colonne) di A
                xe = ones(n)               # Vettore soluzione esatta lungo n tutti 1
                b = A * xe                 # Costruzione del termine noto

                result = @timed begin      # Misurazione tempo
                    F = cholesky(A)
                    x = F \ b              # Soluzione del sistema
                end


                rel_error = norm(x - xe) / norm(xe)

                return result.time, result.bytes, rel_error
            else
                println("La matrice è simmetrica ma non è definita positiva")
                return null
            end
        
        
    else
        println("✘ La matrice NON è simmetrica.")
        return null
    end
end



# 👉 Inserisci qui il percorso alla matrice .mtx
file_path = "C:/Users/david/Desktop/Matrici/cfd2.mtx"

A = load_matrix_from_mtx(file_path)
t, mem, err = is_symmetric_and_positive_definite(A)

println("Tempo: $(round(t*1000, digits=2)) ms")
println("Memoria: $(mem ÷ 1024) KB")
println("Errore relativo: $err")
println("##################################")

# Ottieni la lista di tutti i file .mtx nella directory
#matrices_files = glob("*.mtx", directory_path)

# Cicla su ogni file e processa
#for file_path in matrices_files
 #   println("Processando matrice: $file_path")
  #  A = load_matrix_from_mtx(file_path)
   # is_symmetric_and_positive_definite(A)
#end

###############################################################################
#=
function chol(A)
    n = size(A)[1] # note I didn't check it is square here
    lower = zeros(n,n)

    for i in 1:n
        for j in 1:i
            sum1 = 0;
            # summation for diagonals
            if (j == i)
                for k in 1:j
                    sum1 += (lower[j,k])^2
                end#for
                lower[j,j] = sqrt(matrix[j,j] - sum1)
            else 
                # Evaluating L(i, j)
                # using L(j, j)
                for k in 1:j
                    sum1 += (lower[i,k] * lower[j,k]);
                end#for
                if(lower[j,j] > 0)
                    lower[i,j] = (matrix[i,j] - sum1) /lower[j,j]
                end#if
            end#if else
        end#for
    end#for
    lower
end
=#