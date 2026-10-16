clc
clear
close all 

muestras_RC_5 = importfile_RC_5("C:\Users\Resen\Documents\MATLAB\RC\muestras_RC_5.csv", [2, Inf]);

Vin = 5.08;

R_ideal = 10e3; 
C_ideal = 100e-6;
V_ideal = 5; 

R_real = 10.09e3; 
C_real = 102.2e-6;
V_real = 5.08; 

t = muestras_RC_5.t;
Vp = muestras_RC_5.MP;

muestras = table2array(muestras_RC_5);

muestras = (muestras * Vin) ./ 1023; 
Vp = (Vp * Vin) ./ 1023;

window_size = 3;
b = (1/ window_size) * ones(1, window_size);
filtrado = filter(b, 1, Vp);

Vc_ideal = @(t, R_ideal, C_ideal, V_ideal) V_ideal * (1 - exp( -t / (R_ideal * C_ideal) ) );
Vc_real = @(t, R_real, C_real, V_real) V_real * (1 - exp( -t / (R_real * C_real) ) );


% FIGURA 1: 15 MUESTRAS Y PROMEDIO EXPERIMENTAL

figure
hold on
h_muestras = plot(t, muestras(:, 2:16), 'Color', [0.75 0.78 0.81], 'LineWidth', 0.8);
h_prom = plot(t, Vp, 'k-', 'LineWidth', 2);
grid on
box on
xlabel('Tiempo (s)')
ylabel('Voltaje del capacitor, V_C (V)')
%title('Respuesta experimental del circuito RC (\tau = 1 s)')
legend([h_muestras(1), h_prom], ...
    {'Mediciones experimentales (n = 15)', ...
     'Promedio experimental'}, ...
    'Location', 'southeast')
set(gca, 'FontSize', 30, 'LineWidth', 1)

% FIGURA 2: PROMEDIO EXPERIMENTAL Y MODELOS ANALITICOS

figure
hold on
plot(t, Vp, 'k', 'LineWidth', 1.8)
plot(t, Vc_ideal(t, R_ideal, C_ideal, V_ideal), '--', 'LineWidth', 1.8)
plot(t, Vc_real(t, R_real, C_real, V_real), '-', 'LineWidth', 1.8)
grid on
box on
xlabel('Tiempo (s)')
ylabel('Voltaje del capacitor, V_C (V)')
%title('Comparacion experimental y modelos analiticos (\tau = 1 s)')
legend('Promedio experimental', ...
    'Modelo con parametros nominales', ...
    'Modelo con parametros medidos', ...
    'Location', 'southeast')
set(gca, 'FontSize', 30, 'LineWidth', 1)

% FIGURA 3: RESIDUOS DE LOS MODELOS ANALITICOS

% Residuo = promedio experimental - modelo
res_ideal = Vp - Vc_ideal(t, R_ideal, C_ideal, V_ideal);
res_real  = Vp - Vc_real(t, R_real, C_real, V_real);

figure
subplot(1,2,1)
plot(t, res_ideal, 'o-', 'MarkerSize', 3, 'LineWidth', 1)
hold on
yline(0, 'k--', 'LineWidth', 1.2)
grid on
box on
xlabel('Tiempo (s)')
ylabel('Residuo (V)')
title('(a)')

subplot(1,2,2)
plot(t, res_real, 'o-', 'MarkerSize', 3, 'LineWidth', 1)
hold on
yline(0, 'k--', 'LineWidth', 1.2)
grid on
box on
xlabel('Tiempo (s)')
ylabel('Residuo (V)')
title('(b)')
set(findall(gcf, 'Type', 'axes'), ...
    'FontSize', 30, ...
    'LineWidth', 1, ...
    'XLim', [0 5])

% FIGURA 4: EFECTO DEL FILTRADO DIGITAL

efecto_filtrado = Vp - filtrado(:);

figure

subplot(1,2,1)
plot(t, Vp, 'k-', 'LineWidth', 1.5)
hold on
plot(t, filtrado, 'r--', 'LineWidth', 1.5)
grid on
box on
xlabel('Tiempo (s)')
ylabel('Voltaje (V)')
title('(a)')
legend('Promedio sin filtrar', ...
    'Promedio filtrado', ...
    'Location', 'southeast')

subplot(1,2,2)
plot(t, efecto_filtrado, 'LineWidth', 1.2)
hold on
yline(0, 'k--', 'LineWidth', 1.2)
grid on
box on
xlabel('Tiempo (s)')
ylabel('\Delta V_C (V)')
title('(b)')
set(findall(gcf, 'Type', 'axes'), ...
    'FontSize', 30, ...
    'LineWidth', 1, ...
    'XLim', [0 5])

% BENCHMARK: MODELO NOMINAL Y MODELO CON PARAMETROS MEDIDOS CONTRA PROMEDIO Y FILTRADO

B_ideal = benchmark(Vp, Vc_ideal(t, R_ideal, C_ideal, V_ideal), t);
B_real  = benchmark(Vp, Vc_real(t, R_real, C_real, V_real), t);

B_ideal_fil = benchmark(filtrado, Vc_ideal(t, R_ideal, C_ideal, V_ideal), t);
B_real_fil  = benchmark(filtrado, Vc_real(t, R_real, C_real, V_real), t);


% Metricas tomadas
metricas = {'RMSE'; 'MAE'; 'R2'; 'FIT'; 'IAE'};

valores_ideal = [B_ideal.RMSE; ...
                 B_ideal.MAE; ...
                 B_ideal.R2; ...
                 B_ideal.FIT; ...
                 B_ideal.IAE];

valores_real = [B_real.RMSE; ...
                B_real.MAE; ...
                B_real.R2; ...
                B_real.FIT; ...
                B_real.IAE];

valores_ideal_fil = [B_ideal_fil.RMSE; ...
                     B_ideal_fil.MAE; ...
                     B_ideal_fil.R2; ...
                     B_ideal_fil.FIT; ...
                     B_ideal_fil.IAE];

valores_real_fil = [B_real_fil.RMSE; ...
                    B_real_fil.MAE; ...
                    B_real_fil.R2; ...
                    B_real_fil.FIT; ...
                    B_real_fil.IAE];

Resultados = table(metricas, valores_ideal, valores_real, ...
    'VariableNames', ...
    {'Metrica', 'Modelo_nominal', 'Modelo_parametros_medidos'});

disp(' ')
disp('COMPARACION DE MODELOS RC')
disp(Resultados)

Resultados_fil = table(metricas, valores_ideal_fil, valores_real_fil, ...
    'VariableNames', ...
    {'Metrica', 'Modelo_nominal', 'Modelo_parametros_medidos'});

disp(' ')
disp('COMPARACION DE MODELOS RC CON FILTRO')
disp(Resultados_fil)


% Constantes de tiempo
tau_ideal = R_ideal * C_ideal;
tau_real = R_real*C_real;

fprintf('\nConstante de tiempo nominal: %.6f s\n', tau_ideal);
fprintf('Constante de tiempo medida:  %.6f s\n', tau_real);

% Diferencia relativa entre constantes de tiempo
fprintf('Diferencia relativa de tau: %.2f %%\n', ...
    100*abs(tau_real-tau_ideal)/tau_ideal);