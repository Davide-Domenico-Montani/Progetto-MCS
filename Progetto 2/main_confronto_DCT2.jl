using FFTW
using Printf
include("DCT2.jl")

using Random, LinearAlgebra, PyPlot

function compare_dct2_performance()
    N_values = [32, 64, 128, 256, 512, 1024]  # Array di dimensioni crescenti
    times_custom = Float64[]
    times_fftw = Float64[]

    for N in N_values
        println(N)
        f_mat = rand(N, N)  # Genera una matrice N × N con valori casuali

        # Misura il tempo per la tua implementazione
        t_custom = @elapsed dct2(f_mat)
        push!(times_custom, t_custom)

        # Misura il tempo per la DCT2 della libreria FFTW
        t_fftw = @elapsed fftw_dct2 = FFTW.dct(f_mat)  # Usando FFTW
        push!(times_fftw, t_fftw)
    end

    # Plotta il confronto in scala semilogaritmica
    figure()
    semilogy(N_values, times_custom, "-o", label="DCT2 Custom (N³)")
    semilogy(N_values, times_fftw, "-s", label="DCT2 FFTW (N² log N)")
    xlabel("Dimensione N")
    ylabel("Tempo (s)")
    title("Confronto tra DCT2 personalizzata e FFTW")
    legend()
    grid(true)
    show()
end

compare_dct2_performance()


