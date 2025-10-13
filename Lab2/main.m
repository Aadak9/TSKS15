clear all
close all

Ts = 0.1;
Trange = [ -15:Ts :15];
n = -100:100; 
t = n*Ts;


s1 = exp( -0.1* Trange .^2);
s2 = exp( -0.1* Trange .^2) .*cos(Trange);
sigma_2 = 0.01;
e = sqrt(sigma_2)*randn(size(Trange));
x = s2 + e;


figure;
plot(Trange, s1, 'r', Trange, s2, 'b')
grid on
legend('s1', 's2')
xlabel('t')
ylabel('Amplitude')


%{
figure;
plot(Trange,x)
legend('e with sigma^2=0.01')
xlabel('t')
ylabel('Amplitude')
%}

        
s1_sampled = exp(-0.1 * (t).^2);
s2_sampled = exp(-0.1 * (t).^2) .* cos(t);
E1 = sum(abs(s1_sampled).^2);
E2 = sum(abs(s2_sampled).^2);

alpha1 = 1 / sqrt(E1);
alpha2 = 1 / sqrt(E2);

fprintf('E1 = %.4f, E2 = %.4f\n', E1, E2);
fprintf('alpha1 = %.4f, alpha2 = %.4f\n', alpha1, alpha2);


%ML estimation of T
T_grid = -5:Ts:5;
ML_estimation_vector = zeros(size(T_grid));
for  k = 1:length(T_grid)
    T_candidate = T_grid(k);
    sweep_signal = (exp( -0.1* (Trange-T_candidate) .^2) .*cos(Trange-T_candidate));
    sweep_signal_norm = sweep_signal/norm(sweep_signal);
    ML_estimation_vector(k) = sum(sweep_signal_norm.*x);
end
[~, idx_max] = max(ML_estimation_vector);
T_hat = T_grid(idx_max);



%Q6, CRB and SNR
sigma2_vals = 0.0001:0.001:1;
CRB_s1_values = zeros(size(sigma2_vals));
CRB_s2_values = zeros(size(sigma2_vals));
s1_prime = gradient(s1_sampled, Ts);
s2_prime = gradient(s2_sampled, Ts);
int_s1p2 = sum(s1_prime.^2) * Ts;
int_s2p2 = sum(s2_prime.^2) * Ts;

for i = 1:length(sigma2_vals)
    sigma2 = sigma2_vals(i);
    CRB_s1_values(i) = sigma2/int_s1p2;
    CRB_s2_values(i) = sigma2/int_s2p2;    
end
SNR_linear = 1./sigma2_vals;
SNR_dB = 10*log10(SNR_linear);

figure;
loglog(SNR_linear, sqrt(CRB_s1_values), 'r', 'LineWidth', 1.5); hold on;
loglog(SNR_linear, sqrt(CRB_s2_values), 'b', 'LineWidth', 1.5);
yl = ylim;                  
ylim([yl(1)/2, yl(2)*2]);   
grid on;

legend('√CRB for s₁(t)', '√CRB for s₂(t)', 'Location', 'southwest');
xlabel('SNR (logarithmic scale)');
ylabel('\surdCRB');
title('\surdCRB vs SNR for s₁(t) and s₂(t)');


set(gca, 'XScale', 'log', 'YScale', 'log');


Nmc = 500;
T_range_montecarlo = [-5 5];
grid_factor = 20;
dT = Ts/grid_factor;
T_grid = T_range_montecarlo(1):dT:T_range_montecarlo(2);

SNR_dB = 10:1:30;
SNR_linear = 10.^(SNR_dB/10);

CRB_s1 = zeros(size(SNR_linear));
CRB_s2 = zeros(size(SNR_linear));
RMSE_s1 = zeros(size(SNR_linear));
RMSE_s2 = zeros(size(SNR_linear));

for k = 1:length(SNR_linear)
    sigma2 = 1/SNR_linear(k);
    CRB_s1(k) = sigma2/int_s1p2;
    CRB_s2(k) = sigma2/int_s2p2;
end

for k = 1:length(SNR_linear)
    sigma2 = 1/SNR_linear(k);
    noise_std = sqrt(sigma2);
    
    T0_vector = zeros(1, Nmc);
    T_est_s1 = zeros(1, Nmc);
    T_est_s2 = zeros(1, Nmc);

    for m = 1:Nmc
        % Random true delay
        T0 = T_range_montecarlo(1) + (T_range_montecarlo(2)-T_range_montecarlo(1))*rand;
        T0_vector(m) = T0;

        % Generate delayed signals
        s1_delayed = exp(-0.1*(t - T0).^2);
        s1_delayed = s1_delayed / norm(s1_delayed);
        s2_delayed = exp(-0.1*(t - T0).^2).*cos(t - T0);
        s2_delayed = s2_delayed / norm(s2_delayed);

        % Add Gaussian noise
        x1 = s1_delayed + noise_std*randn(size(t));
        x2 = s2_delayed + noise_std*randn(size(t));

        % ML estimation via grid search
        corr_s1 = zeros(size(T_grid));
        corr_s2 = zeros(size(T_grid));
        for i = 1:length(T_grid)
            Ti = T_grid(i);
            sweep_s1 = exp(-0.1*(t - Ti).^2);
            sweep_s1 = sweep_s1 / norm(sweep_s1);       % normalize
            corr_s1(i) = sum(x1 .* sweep_s1);

            sweep_s2 = exp(-0.1*(t - Ti).^2).*cos(t - Ti);
            sweep_s2 = sweep_s2 / norm(sweep_s2);       % normalize
            corr_s2(i) = sum(x2 .* sweep_s2);
        end

         % ML estimate = argmax correlation
        [~, idx1] = max(corr_s1);
        [~, idx2] = max(corr_s2);
        T_est_s1(m) = T_grid(idx1);
        T_est_s2(m) = T_grid(idx2);
    end

    % Compute RMSE
    RMSE_s1(k) = sqrt(mean((T_est_s1 - T0_vector).^2));
    RMSE_s2(k) = sqrt(mean((T_est_s2 - T0_vector).^2));
end

figure; 
hold on; grid on;

semilogy(SNR_dB, sqrt(CRB_s1), 'r--','LineWidth',1.5);
semilogy(SNR_dB, sqrt(CRB_s2), 'b--','LineWidth',1.5);
semilogy(SNR_dB, RMSE_s1, 'r','LineWidth',1.5);
semilogy(SNR_dB, RMSE_s2, 'b','LineWidth',1.5);

xlabel('SNR [dB]');
ylabel('RMSE / \surdCRB [s]');
legend('s1 √CRB','s2 √CRB','s1 RMSE','s2 RMSE','Location','northeast');
title('Monte-Carlo RMSE vs SNR and √CRB for ML estimation of T');
grid on;

