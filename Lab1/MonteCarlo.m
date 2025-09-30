

SNR_db = -50:2:-10; %%According to lab-pm, steps of two to decrease
%computing time
first_error_probabilities = zeros(size(SNR_db)); %Will contain the error-probability for each SNR
for i = 1:length(SNR_db)
    snr_val = SNR_db(i);
    missclassification_error = 0;
    runs = 0;
    while (missclassification_error < 50) && (runs <500)
        [signal, melody_index, pitch_mismatch] = SignalGenerator(1, snr_val, 1);
        [melody_index_estimation, pitch_mismatch_estimation] = SingleToneClassifier(signal);

        if (melody_index_estimation ~= melody_index) || (pitch_mismatch_estimation ~= pitch_mismatch)
            missclassification_error = missclassification_error + 1;
        end

        runs = runs + 1;
    end
    first_error_probabilities(i) = missclassification_error/runs;
end
%{
size(SNR_db)
size(error_probabilities)
figure;
plot(SNR_db, error_probabilities)
xlabel('SNR [dB]');
ylabel('Probability of error');
title('SingleToneclassifier with 1 tone');
grid on;
%}


SNR_db = -50:2:-10;
second_error_probabilities = zeros(size(SNR_db));
for i = 1:length(SNR_db)
    snr_val = SNR_db(i);
    missclassification_error = 0;
    runs = 0;
    while (missclassification_error < 50) && (runs <500)
        [signal, melody_index, pitch_mismatch] = SignalGenerator(1, snr_val, 3);
        [melody_index_estimation, pitch_mismatch_estimation] = SingleToneClassifier(signal);

        if (melody_index_estimation ~= melody_index) || (pitch_mismatch_estimation ~= pitch_mismatch)
            missclassification_error = missclassification_error + 1;
        end

        runs = runs + 1;
    end
    second_error_probabilities(i) = missclassification_error/runs;
end
%{
size(SNR_db)
size(error_probabilities)
figure;
plot(SNR_db, error_probabilities)
xlabel('SNR [dB]');
ylabel('Probability of error');
title('SingleToneclassifier with 3 tones');
grid on;
%}
        

SNR_db = -50:2:-10;
third_error_probabilities = zeros(size(SNR_db));
for i = 1:length(SNR_db)
    snr_val = SNR_db(i);
    missclassification_error = 0;
    runs = 0;
    while (missclassification_error < 50) && (runs <500)
        [signal, melody_index, pitch_mismatch] = SignalGenerator(1, snr_val, 1);
        [melody_index_estimation, pitch_mismatch_estimation] = ThreeToneClassifier(signal);

        if (melody_index_estimation ~= melody_index) || (pitch_mismatch_estimation ~= pitch_mismatch)
            missclassification_error = missclassification_error + 1;
        end

        runs = runs + 1;
    end
    third_error_probabilities(i) = missclassification_error/runs;
end
%{
size(error_probabilities)
size(SNR_db)
figure;
plot(SNR_db, error_probabilities)
xlabel('SNR [dB]');
ylabel('Probability of error');
title('ThreeToneclassifier with 1 tone');
grid on;
%}


SNR_db = -50:2:-10;
fourth_error_probabilities = zeros(size(SNR_db));
for i = 1:length(SNR_db)
    snr_val = SNR_db(i);
    missclassification_error = 0;
    runs = 0;
    while (missclassification_error < 50) && (runs <500)
        [signal, melody_index, pitch_mismatch] = SignalGenerator(1, snr_val, 3);
        [melody_index_estimation, pitch_mismatch_estimation] = ThreeToneClassifier(signal);

        if (melody_index_estimation ~= melody_index) || (pitch_mismatch_estimation ~= pitch_mismatch)
            missclassification_error = missclassification_error + 1;
        end

        runs = runs + 1;
    end
    fourth_error_probabilities(i) = missclassification_error/runs;
end
figure;
hold on;
plot(SNR_db, first_error_probabilities, '-o', 'DisplayName', 'SingleToneClassifier, 1 tone'); 
plot(SNR_db, second_error_probabilities, '-s', 'DisplayName', 'SingleToneClassifier, 3 tones');
plot(SNR_db, third_error_probabilities, '-d', 'DisplayName', 'ThreeToneClassifier, 1 tone');
plot(SNR_db, fourth_error_probabilities, '-^', 'DisplayName', 'ThreeToneClassifier, 3 tones');

xlabel('SNR [dB]');
ylabel('Probability of error');
title('Comparison of Classifiers and Number of Tones');
legend('show');  
grid on;

