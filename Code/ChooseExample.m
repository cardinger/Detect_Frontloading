function [Metabolic_Rate, Dir, Dataset, Time_Variable] = ChooseExample

dname = pwd;
cd ([dname]); %go to main folder

opts.Interpreter = 'tex'; opts.Default = 'HAP2 Mice (2-Hr DID)';
button = questdlg('\fontsize{16} Which example would you like to run?', 'Choose Example', 'HAP2 Mice (2-Hr DID)', 'cHAP/HDID Mice (2-Hr DID)', 'Wistar Rats (20-Min Operant Free Access)', opts);
drawnow;  % Refresh screen to get rid of dialog box remnants.
if strcmpi(button, 'HAP2 Mice (2-Hr DID)')
    Metabolic_Rate = .017; % .017 g/kg/min = HAP 1 g/kg/hr / 60 min; calculated from
    %Matson et al. 2013; PMID: 2275796
    Dir = ([dname '/Data/HAP2/']);
    cd ([Dir]); %navigate to the selected folder
    [num, txt, raw] = xlsread('HAP2_DAY14.xlsx');
    Dataset = num; 
    Time_Variable = 'Minute'; 
end
if strcmpi(button, 'cHAP/HDID Mice (2-Hr DID)')
    Metabolic_Rate = .017; % .017 g/kg/min = HAP 1 g/kg/hr / 60 min; calculated from
    %Matson et al. 2013; PMID: 2275796
    Dir = ([dname '/Data/cHAP_HDID/']);
    cd ([Dir]); %navigate to the selected folder
    [num, txt, raw] = xlsread('cHAP_HDID_EW_DAY14.xlsx');
    Dataset = num; 
    Time_Variable = 'Minute'; 
end
if strcmpi(button, 'Wistar Rats (20-Min Operant Free Access)')
    Metabolic_Rate = .0001; % .0001 g/kg/sec = .006 g/kg/min / 60 Wistar Rat;
    %calculated from Morningstar et al. 2020; PMID: 32966634
    Dir = ([dname '/Data/Wistars']);
    cd ([Dir]); %navigate to the selected folder
    load('frontload_rat_data.mat', 'mxH');
    mxH = diff(mxH); %These data are already cumulative (Mice data are not); 
    %Undo the cumulative calculation as the code will analyze the data
    %cumulatively
    Dataset = mxH; 
    Time_Variable = 'Second'; 
end
end