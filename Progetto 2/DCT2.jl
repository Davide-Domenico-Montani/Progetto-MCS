# Definizione della struttura di supporto per la DCT
mutable struct DCTSupport
    sqrt_N::Float64
    sqrt_2::Float64
    coeff::Float64
    result::Union{Vector{Float64}, Nothing}  # Vettore ausiliario, può essere nothing
end

"""
    dct(v::AbstractVector{Float64}, support::Union{DCTSupport, Nothing}=nothing) -> Vector{Float64}

Esegue la Discrete Cosine Transform (DCT) sul vettore `v`.

Se viene passato un oggetto `support`, vengono riutilizzati i parametri precalcolati e il buffer.
"""
function dct(v::AbstractVector{Float64}, support::Union{DCTSupport, Nothing}=nothing)
    N = length(v)
    

    if support === nothing
        sqrt_N = sqrt(N)
        sqrt_2 = sqrt(2)
        coeff = pi / (2 * N)
        result = zeros(Float64, N)
    else
        sqrt_N = support.sqrt_N
        sqrt_2 = support.sqrt_2
        coeff = support.coeff
        result = support.result
        if result === nothing
            result = zeros(Float64, N)
        end
    end
    
    for k in 0:(N-1)
        a_k = 0.0
        coeff_k = coeff * k
        for i in 0:(N-1)
            # Ricorda: in Julia gli indici partono da 1
            a_k += cos(coeff_k * (2 * i + 1)) * v[i+1]
        end
        
        result[k+1] = (a_k / sqrt_N) * sqrt_2
    end

    result[1] /= sqrt_2
    return result
end

"""
    dct2(matrix::Array{Float64,2}) -> Array{Float64,2}

Esegue la Discrete Cosine Transform (DCT2) su una matrice `matrix` di dimensione N x M.
Il procedimento prevede l'applicazione della DCT sulle righe e successivamente sulle colonne.
"""
function dct2(matrix::Array{Float64,2})
    N, M = size(matrix)
    result = similar(matrix)
    
    # Creiamo la struttura di supporto in base a N
    support = DCTSupport(sqrt(N), sqrt(2), pi/(2*N), zeros(N))
    
    # Passaggio 1: trasforma ogni riga della matrice
    for i in 1:N
        # Utilizziamo una view per la riga i-esima
        result[i, :] = dct(view(matrix, i, :), support)
    end

    # Vettore temporaneo per la trasformazione colonnare
    col_v = zeros(Float64, N)
    support.result = zeros(N)  # Riutilizza o reinizializza il buffer
    
    # Passaggio 2: trasforma ogni colonna usando il risultato parziale
    for j in 1:M
        for i in 1:N
            col_v[i] = result[i, j]
        end
        
        transformed = dct(col_v, support)
        
        for i in 1:N
            result[i, j] = transformed[i]
        end
    end
    
    return result
end
