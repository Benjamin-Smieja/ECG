%% This script analyzes the ecg graph from 3 patients identifying potential problems.
% MAT188 MATLAB final project
% December 2019

clear; clc; close all;
for patientNum = 1:3
    
    %Loads apporpriate data set ecg 1-3
    switch patientNum
        case 1
            load ecg1.mat;
        case 2
            load ecg2.mat;
        case 3
            load ecg3.mat;
    end
    
    %Plots patient ECG and adds labels
    figure();
    plot(time, ecg);
    plot_legend = legend("ECG data");
    plot_legend.FontSize = 11;
    title("ECG Signal - Patient: "+num2str(patientNum));
    xlabel("Time (seconds)");
    ylabel('Voltage (milivolts)');
    ylim([-0.3,1.2]);
    xlim([0,5]);
    % Creates a cell array containing 5 arrays with indicies of each peak
    for i = 1:5
        indexPeak(i) = {find(marker==i)};
    end
    
    %Adds the peak markers to the ECG graph
    markerAtributes= ["+", "d", "o", "*", "x";
        "Peak P","Peak Q","Peak R","Peak S","Peak T"];
    hold on;
    for i = 1:5
        plot(time(indexPeak{i}),ecg(indexPeak{i}),markerAtributes(1,i),'MarkerSize', 11 ,'DisplayName', markerAtributes(2,i));
    end
    
    %% Check for missing beats um this is a lil broken, but i planned it out first :)
    % for i = 1:length(indexPeak{1})-1
    %     if indexPeak{1}(i)<indexPeak{2}(i) & indexPeak{2}(i)<indexPeak{3}(i) & indexPeak{3}<indexPeak{4}(i+1) & indexPeak{4}(i+1)<indexPeak{5}(i+1)
    %     else
    %         disp("We're missing one!")
    %     end
    % end
    
    %% P wave Analysis (Heart rate and variation)
    
    
    period = diff(time(indexPeak{1}));
    avg_HeartRate = 60 / (sum(period) / length(period));
    heartRate = 60./period;
    heartRateVar = max(heartRate) / min(heartRate);
    
    %Compares heart rate to regular interval and creates diagnosis 
    if avg_HeartRate < 60
        prob="Sinus Bradycardia";
    elseif 60 <= avg_HeartRate & avg_HeartRate <= 100
        prob = "Normal Rate";
    else
        prob = "Sinus Tachycardia";
    end
    
    %Finds max variation in heart rate
    MaxVarInHeartRate = 0;
    for (i= 2: length(heartRate))
        possibleMax = abs(1 - (heartRate(i)/heartRate(i-1)));
        if possibleMax > MaxVarInHeartRate
            MaxVarInHeartRate = possibleMax;
        end
    end
    
    %Compares heart rate to acceptable range and creates diagnosis
    Diag_Variation = " Less than 10% - Normal";
    if MaxVarInHeartRate > 1.1
        Diag_Variation = "Greater than 10% - Sinus Arrythmia";
    end
    
    %% Finds and analyzes PR interval (0.12 - 0.20 s)
    PR_Intervals = findInterval(indexPeak{1}, indexPeak{3}, time);
    avg_PR_Int = sum(PR_Intervals) / length(PR_Intervals);
    Diag_PR_Int = "PR interval normal";
    
    %Compares PR interval to normal and creates diagnosis
    if avg_PR_Int>0.20
        Diag_PR_Int = "Long, consider first degree heart block and trifascular block ";
    elseif avg_PR_Int<0.12
        Diag_PR_Int = "Short, consider Wolff-Parkinson-White syndrom or Lown-Ganong-Levine syndrome ";
    end
    
    %% Finds and analyzes QRS interval (<0.12s)
    
    QRS_Intervals = findInterval(indexPeak{2}, indexPeak{4}, time);
    avg_QRS_Int = sum(QRS_Intervals)/length(QRS_Intervals);
    Diag_QRS_Int = "Normal QRS duration";
    
    %Compares QRS duration to normal and creates diagnosis
    if avg_QRS_Int > 0.12
        Diag_QRS_Int = "Long, consider right or left bundle branch block, hyperkalaemia";
    end
    
    %% QT Intervals
    % QT interval should be measure from the START of Q wave to END of T wave
    % however for rough calculation the points can be shifted to the the peak
    % of the P wave and peak of T wave.
    QT_Interval = findInterval(indexPeak{1}, indexPeak{5}, time);
    %if QT_Interval()
    QTC = QT_Interval./sqrt(period);
    avg_QTC = sum(QTC) / length(QTC);
    
    %Compares QTC interval to normal and creates diagnosis
    Diag_QTC_Int = "Normal QTC interval";
    if(avg_QTC>0.48)
    Diag_QTC_Int = "High, consider myocardial infraction, subarachnoid haemorrhage";
    end
    
    %% Informs user of possible heart conditions
    disp(" - - - - - - - - - - - - ECG REPORT - - - - - - - - - - - - ")
    disp("Patient: " + patientNum)
    disp("Heart rate: " + round(avg_HeartRate) + "bpm - " + prob )
    disp("Variation in heart rate: "+ Diag_Variation)
    disp("PR Interval: " + round(avg_PR_Int,2) + "s - " + Diag_PR_Int)
    disp("QRS Interval: " + round(avg_QRS_Int,2)+ "s - " + Diag_QRS_Int)
    disp("QT Interval: "+ round(avg_QTC,2) + "s - " + Diag_QTC_Int)
    disp(" - - - - - - - - - - - END OF REPORT  - - - - - - - - - - - ")
    
    %Resets for the next ECG analysis
    hold off;
    if(patientNum<3)
    clear;
    disp(" ")
    end
    
end

%% Funtion returns array with interval between peaks every heart beat
function f = findInterval(first, second, time)
start = 1;
last = 0;
if first(1)>second(1)
    start = 2;
end

if first(end)>second(end)
    last = 1;
end

f = time(second(start:end)) - time(first(1:end-last));
end