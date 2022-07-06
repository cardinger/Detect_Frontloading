%Analyze_Frontloading.m

%This script analyzes alcohol drinking patterns to assess if
%alcohol front-loading is present using the following
%criteria:
%1*. Of three detected change points, the change point with the best fit
%is the earliest and/or is within the first half of the session. This
%becomes the reference change point for criteria 2 & 3 -
%2. The pre-change point slope exceeds the rate of alcohol metabolism, providing
%evidence of intoxication
%3. The pre-change point slope is signficantly different than the
%post-change point slope
%The code will save a 'Subject_Number_Summary.mat' file and
%graphs which classify subjects as front-loaders, non-frontloaders, or
%inconclusive

%*Note: if criteria 1 is not met, subjects are classified as "inconclusive
%results." In many cases, these subjects have a lot of consumption at the
%end of the session, where the rate of this 'backloading' is greater than
%the rate of any frontloading. However, this does not necessarily mean that
%there was no substantial intake at the beginning of the session. Users of
%this code should consider the most clinically and experimentally relevant
%definition of front-loading when determining whether front-loading
%occurred. The categorizations determined by this code are only meant to
%serve as suggestions, not hard and fast rules.

%Data input should be volume consumed over time (i.e. g/kg/min or g/kg/sec). See example
%datasets. HAP2 and cHAP/HDID examples are in g/kg/min. Wistar rat example
%data are in g/kg/sec.

%% analyze change points
clear all
close all

%%

%Thanks for using our code. Please load your data, specify timescale &
%metabolic rate below: 

dname = pwd; 
cd ([dname]); %go to the folder where Detect_Frontloading.m is saved
Dataset = %call your data matrix here. Individual subjects on columns, data (not cumulative) over time on rows
Dir = ([dname '/Folder_Where_Your_Data_Live_Here/']); %enter the name of the folder where you want your results to be saved
Time_Variable = 'Minute'; %Change the timescale to match your data; 'Minute' or 'Second'
Metabolic_Rate = %enter the metabolic rate in g/kg/your timescale (min or sec). 
%See ChooseExample function for some commonly used metabolic rates. 

number_of_subjects = 1:size(Dataset,2);

M=3; k = 2; B = 100; alpha = 0.05; %inputs for PARCs function;
%see parcs.m for description of parameters. 

%Get appropriate axis label based on which example was chosen:
if Time_Variable == 'Second'
    Lgd = 'Metabolic Rate (g/kg/sec)';
else
    Lgd = 'Metabolic Rate (g/kg/min)';
end

%Make all graphs on same YAxis: 
MaxYAxis = max(max(cumsum(Dataset))); 

for XX = 1:length(number_of_subjects);
    data = Dataset(:,XX);
    
    if data(1) ~= 0;
        data = [0; data]; %if there is not a leading zero, add one. B/c the cumulative
        %sum data works against frontloaders if they drank during the
        %first timepoint (this is a problem esp. w/ DID data)
    end
    
    %Run the PARCS function to detect change points
    %Then, run a basic regression to get stats on pre versus post strongest
    %change point 
    
    model = parcs(data,M);
    chPt = model.ch;
    model1 = bpb4parcs(model,k,B,alpha);
    
    time_axis = 1:length(data);
    y_pre = cumsum(data(1:chPt(1,1)));
    time_pre = time_axis(1:chPt(1,1))';
    stats_pre = regstats(y_pre, time_pre);
    
    y_post = cumsum(data(chPt(1,1):end));
    time_post = time_axis(chPt(1,1):end);
    stats_post = regstats(y_post, time_post);
    
    %CRITERIA 1
    %1.1: is the earliest change point the most significant?
    %1.2: is this change point within the first half of the session?
    %if neither of these are met; the results are classified as
    %inconclusive:
    
       half_session = length(data)/2;
    
    if chPt(1) > chPt(2) && chPt(1) > chPt(3) && chPt(1) > half_session
        Inconclusive_Result_Data{XX} = data;
        Inconclusive_Result_Subject_Numbers{XX} = XX;
        Criteria1 = 0;
        
        %if criteria 1 is not met, classify subject as inconclusive: 
        
        h = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'visible','off')
        hx = xline(chPt(1,1),'-',{'Change','Point'}, 'HandleVisibility','off', 'LineWidth', 3);
        hx.FontSize = 20;
        time_axis2 = (time_axis)'; %flip to fit curve
        cumulative_data = cumsum(data);
        [curve, goodness, output] = fit(time_axis2, cumulative_data, 'smoothingspline');
        hold on
        h1 = plot(curve, time_axis2, cumulative_data);
        Metabolic_rate_plot = Metabolic_Rate * time_axis;
        hold on; plot(time_axis, Metabolic_rate_plot, 'LineWidth', 5);
        title(['Subject Number ' num2str(XX)]);
        legend({"Cumulative" + newline + "Intake (g/kg)", 'Fit Data', sprintf(Lgd)}, 'location', 'northoutside');
        set(gca,'FontSize',20); xlabel(sprintf(Time_Variable));  ylabel({['Cumulative EtOH' newline 'Intake (g/kg)']});
        xlim([0 length(data)]); ylim([0 MaxYAxis]);
        set(h1,'LineWidth',5); set(h1, 'MarkerSize', 20);
        mkdir Inconclusive_Results
        fig_name = strcat('Fig_Animal_',num2str(XX));
        figuresdir = ([Dir '/Inconclusive_Results']);
        newname = fullfile(figuresdir, [fig_name '.png']);
        saveas(h, newname, 'png');
        close all
    else
        Criteria1 = chPt(1) < half_session;
        
        %CRITERIA 2
        %Determine if the slope prior to the change point is greater than the
        %metabolic rate is determined when you select the example at the
        %beginning
        
        Criteria2 = stats_pre.beta(2) > Metabolic_Rate;
        
        %CRITERIA 3
        %Is the pre-change point slope significantly higher than
        %the post change-point slope?
        
        t_stat_num = stats_pre.beta(2) - stats_post.beta(2);
        t_stat_den = sqrt((stats_pre.tstat.se(2)^2) + (stats_post.tstat.se(2)^2));
        t_stat = t_stat_num / t_stat_den;
        t_stat_df = stats_pre.tstat.dfe + stats_post.tstat.dfe;
        p = (1-tcdf(abs(t_stat), t_stat_df));
        Criteria3 = p < alpha && stats_pre.beta(2) > stats_post.beta(2);
        
        %group animals by front-loaders or non-front-loaders:
        if (Criteria1 == 1) && (Criteria2 == 1) && (Criteria3 == 1)
            Frontloader_Data{XX} = data;
            Frontloader_Subject_Numbers{XX} = XX;
            
            h = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'visible','off')
            hx = xline(chPt(1,1),'-',{'Change','Point'}, 'HandleVisibility','off', 'LineWidth', 3);
            hx.FontSize = 20;
            time_axis2 = (time_axis)'; %flip to fit curve
            cumulative_data = cumsum(data);
            [curve, goodness, output] = fit(time_axis2, cumulative_data, 'smoothingspline');
            hold on
            h1 = plot(curve, time_axis2, cumulative_data);
            Metabolic_rate_plot = Metabolic_Rate * time_axis;
            hold on; plot(time_axis, Metabolic_rate_plot, 'LineWidth', 5);
            title(['Subject Number ' num2str(XX)]);
            legend({"Cumulative" + newline + "Intake (g/kg)", 'Fit Data', sprintf(Lgd)}, 'location', 'northoutside');
            set(gca,'FontSize',20); xlabel(sprintf(Time_Variable));  ylabel({['Cumulative EtOH' newline 'Intake (g/kg)']});
            xlim([0 length(data)]); ylim([0 MaxYAxis]);
            set(h1,'LineWidth',5); set(h1, 'MarkerSize', 20);
            mkdir Identified_Frontloaders
            fig_name = strcat('Fig_Animal_',num2str(XX));
            figuresdir = ([Dir '/Identified_Frontloaders']);
            newname = fullfile(figuresdir, [fig_name '.png']);
            saveas(h, newname, 'png');
            close all
        else
            Non_Frontloader_Data{XX} = data;
            Non_Frontloader_Subject_Numbers{XX} = XX;
            
            h = figure('units', 'normalized', 'outerposition', [0 0 1 1], 'visible','off')
            hx = xline(chPt(1,1),'-',{'Change','Point'}, 'HandleVisibility','off', 'LineWidth', 3);
            hx.FontSize = 20;
            time_axis2 = (time_axis)'; %flip to fit curve
            cumulative_data = cumsum(data);
            [curve, goodness, output] = fit(time_axis2, cumulative_data, 'smoothingspline');
            hold on
            h1 = plot(curve, time_axis2, cumulative_data);
            Metabolic_rate_plot = Metabolic_Rate * time_axis;
            hold on; plot(time_axis, Metabolic_rate_plot, 'LineWidth', 5);
            title(['Subject Number ' num2str(XX)]);
            legend({"Cumulative" + newline + "Intake (g/kg)", 'Fit Data', sprintf(Lgd)}, 'location', 'northoutside');
            set(gca,'FontSize',20); xlabel(sprintf(Time_Variable));  ylabel({['Cumulative EtOH' newline 'Intake (g/kg)']});
            xlim([0 length(data)]); ylim([0 MaxYAxis]);
            set(h1,'LineWidth',5); set(h1, 'MarkerSize', 20);
            mkdir Identified_Non_Frontloaders
            fig_name = strcat('Fig_Animal_',num2str(XX));
            figuresdir = ([Dir '/Identified_Non_Frontloaders']);
            newname = fullfile(figuresdir, [fig_name '.png']);
            saveas(h, newname, 'png');
            close all
        end
        clear h hx fig_name figuresdir newname raw data stats_pre stats_post t_stat t_stat_den t_stat_df t_stat_num Criteria1 Criteria2 Criteria3 model model1 time_axis time_axis2 Metabolic_rate_plot time_post time_pre y_post y_pre
    end
end
%save subject numbers into categories:
clearvars -except Frontloader_Subject_Numbers Inconclusive_Result_Subject_Numbers Non_Frontloader_Subject_Numbers
if exist('Frontloader_Subject_Numbers')
    Frontloader_Subject_Numbers = cell2mat(Frontloader_Subject_Numbers);
end
if exist('Inconclusive_Result_Subject_Numbers')
    Inconclusive_Result_Subject_Numbers = cell2mat(Inconclusive_Result_Subject_Numbers);
end
if exist('Non_Frontloader_Subject_Numbers')
    Non_Frontloader_Subject_Numbers = cell2mat(Non_Frontloader_Subject_Numbers);
end
save Subject_Number_Summary.mat
f = msgbox({"Code is finished. Thanks!"});