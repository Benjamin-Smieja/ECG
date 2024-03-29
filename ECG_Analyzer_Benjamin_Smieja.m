%% This script analyzes the ecg graph from 3 patients identifying potential problems.
% MATLAB final project - Benjamin Smieja
% December 3, 2019

clear; clc; close all;

for patientNum = 1:3
    
    %Loads apporpriate ecg data for patient 1-3
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
    legend("ECG data", 'fontSize', 11);
    title("ECG Signal - Patient: "+num2str(patientNum),'fontSize', 14);
    xlabel("Time (seconds)",'fontSize', 12);
    ylabel('Voltage (millivolts)', 'fontSize', 12);
    ylim([-0.4,1.2]);
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
        plot(time(indexPeak{i}),ecg(indexPeak{i}),markerAtributes(1,i),'MarkerSize', 11 ,'DisplayName', markerAtributes(2,i),'lineWidth', 1.5);
    end
    
    %% P wave Analysis (Heart rate and variation)
    
    %calculates period, and then uses it to find heart rate (frequency)
    period = diff(time(indexPeak{1}));
    avg_HeartRate = 60 / (sum(period) / length(period));
    heartRate = 60./period;
    
    %Compares heart rate to regular interval and creates diagnosis 
    if avg_HeartRate < 60
        Diag_HeartRate="Sinus Bradycardia";
    elseif 60 <= avg_HeartRate && avg_HeartRate <= 100
        Diag_HeartRate = "Normal Rate";
    else
        Diag_HeartRate = "Sinus Tachycardia";
    end
    
    %Finds max variation in heart rate
    MaxVarInHeartRate = 0;
    for i= 2: length(heartRate)
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
    
    %finds each QRS interval and then calculates the average
    QRS_Intervals = findInterval(indexPeak{2}, indexPeak{4}, time);
    avg_QRS_Int = sum(QRS_Intervals)/length(QRS_Intervals);
    
    %Compares QRS duration to normal and creates diagnosis
    Diag_QRS_Int = "Normal QRS duration";
    if avg_QRS_Int > 0.12
        Diag_QRS_Int = "Long, consider right or left bundle branch block, hyperkalaemia";
    end
    
    %% QT Intervals
    % QT interval should be measure from the START of Q wave to END of T wave
    % however for rough calculation the points can be shifted to the the peak
    % of the P wave and peak of T wave.
    QT_Intervals = findInterval(indexPeak{1}, indexPeak{5}, time);
    QT_Intervals_Corrected = QT_Intervals./sqrt(period);
    avg_QTC = sum(QT_Intervals_Corrected) / length(QT_Intervals_Corrected);
    
    %Compares QTC interval to normal and creates diagnosis
    Diag_QTC_Int = "Normal QTC interval";
    if(avg_QTC>0.48)
    Diag_QTC_Int = "High, consider myocardial infraction, subarachnoid haemorrhage";
    end
    
    %% Informs user of possible heart conditions
    disp(" - - - - - - - - - - - - ECG REPORT - - - - - - - - - - - - ")
    disp("Patient: " + patientNum)
    disp("Heart rate: " + round(avg_HeartRate) + "bpm - " + Diag_HeartRate )
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
%checks if the second comes before the first at the start
if first(1)>second(1)
    start = 2;
end

%checks if the first peak appears at the end of the data without the second
%peak after
if first(end)>second(end)
    last = 1;
end
%returns array with interval between each set of peaks.
f = time(second(start:end)) - time(first(1:end-last));
end
