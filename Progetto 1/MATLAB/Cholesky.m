function Cholesky()
    directory_path = 'C:/Users/david/Desktop/Matrici';
    
    % Ottieni la lista di tutti i file .mat nella directory
    files = dir(fullfile(directory_path, '*.mat'));

    % Cicla su tutti i file .mat
    for k = 1:length(files)
        file_name = files(k).name;
        file_path = fullfile(directory_path, file_name);

        % Salta i file specifici se necessario
        %if ~strcmp(file_name, 'Flan_1565.mat') && ~strcmp(file_name, 'StocF-1465.mat')
            fprintf('Processando matrice: %s\n', file_path);
            A = load_matrix_from_mat(file_path);
            [t, mem, rel_error] = solve_system(A);
            clear A
            fprintf('Tempo: %.2f ms\n', t * 1000);
            fprintf('Memoria: %.0f KB\n', mem / 1024);
            fprintf('Errore relativo: %.2e\n', rel_error);
            fprintf('##################################\n');
        %end
    end
end

function A = load_matrix_from_mat(path)
    data = load(path);
    fields = fieldnames(data);

    for i = 1:length(fields)
        candidate = data.(fields{i});

        % Se è una struct con campo A (come nei file UF Sparse Matrix Collection)
        if isstruct(candidate) && isfield(candidate, 'A')
            A = candidate.A;
            return;
        end

        % Se è direttamente una matrice numerica
        if isnumeric(candidate) && ismatrix(candidate)
            if issparse(candidate)
                A = candidate;
            else
                A = sparse(double(candidate));
            end
            return;
        end
    end

    error('Nessuna matrice trovata nel file MAT.');
end

function [elapsed_time, mem_used, rel_error] = solve_system(A)
    A = sparse((A + A') / 2);  % Forza simmetria e mantiene sparsa

    n = size(A, 1);
    xe = ones(n, 1);
    b = A * xe;

    vars_before = whos;

    try
     [R, p] = chol(A);  % Salva il risultato della fattorizzazione di Cholesky in R
    if p == 0
        x = R \ (R' \ b);  % Risolve con la fattorizzazione di Cholesky
        elapsed_time = toc;
        vars_after = whos;

        rel_error = norm(x - xe) / norm(xe);
        mem_used = sum([vars_after.bytes]) - sum([vars_before.bytes]);
        clear A
    else
        disp('❌ La matrice non è definita positiva.');
        elapsed_time = 0;
        mem_used = 0;
        rel_error = 0;
        clear A
    end
    catch ME
        fprintf('❌ Errore: %s\n', ME.message);
        elapsed_time = 0;
        mem_used = 0;
        rel_error = 0;
        clear A
    end
end



