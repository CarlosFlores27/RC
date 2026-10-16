function [muestras, t_corr] = extraerMuestrasRC(data, tfin, paso)

    if ischar(data) || isstring(data)
        data = load(data).out;
    end

    num_puntos = round(tfin / paso); 
    muestras = [];
    N = length(data.tout);
    
    i = 1;
    while i < N
        if data.simout(i) == 0 && data.simout(i+1) > 0
            if i + num_puntos - 1 <= N
                nueva_muestra = data.simout(i : i + num_puntos - 1)';
                muestras = [muestras; nueva_muestra];
                i = i + num_puntos; 
                continue;
            end
        end
        
        i = i + 1;
    end
    t_corr = linspace(0, tfin, num_puntos);
end




ruta = "C:\Users\Resen\Documents\MATLAB\RC\RC_10.mat";

[muestras_5s, t_corr] = extraerMuestrasRC(ruta, 10 * 10, 0.1);

t_texto = compose("%.3f", t_corr' ./ 10);

num_muestras = size(muestras_5s, 1);
nombres_M = arrayfun(@(k) sprintf('M%d', k), 1:num_muestras, 'UniformOutput', false);

tabla_csv = array2table(muestras_5s', 'VariableNames', nombres_M);

tabla_csv = addvars(tabla_csv, t_texto, 'Before', 1, 'NewVariableNames', "t");

writetable(tabla_csv, 'muestras_RC_10.csv');

fprintf('Archivo guardado correctamente con precisión de decimales en t.\n');



% Graficar todas las muestras obtenidas
plot(t_corr ./ 10, muestras_5s');
grid on;
xlabel('Tiempo (s)');
ylabel('Voltaje / Carga');
title(['Se extrajeron ', num2str(size(muestras_5s, 1)), ' muestras correctamente']);