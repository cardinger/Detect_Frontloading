This package is distributed under the terms of the GNU GPLv3 & Creative Commons Attribution License. Please credit the source and cite the reference below when using the code in any from of publication.

This repository contains MATLAB code for detecting frontloading, together with demos, as described in:

C. Ardinger, C. C. Lapish, C. L. Czachowski, N. J. Grahame (2022). Front-loading: A drinking pattern which manifests in response to the rewarding effects of alcohol. Alcoholism: Clinical and Experimental Research. DOI: xxxx.


├─ Code                     		% A folder containing functions that Detect_Frontloading_Demo.m
					      % and Detect_Frontloading.m uses
│  ├─ parcs.m                		% PARCS model estimation. This function is reported in Toutounji H 
						% and Durstewitz D (2018) Detecting Multiple Change Points Using 
						% Adaptive Regression Splines With Application to Neural Recordings. Front. 
						% Neuroinform. 12:67. doi: 10.3389/fninf.2018.00067
│  ├─ bpb4parcs.m 			% Block-permutation bootstrap for PARCS. This function is reported 
						% in Toutounji H and Durstewitz D (2018) Detecting Multiple Change Points Using 
						% Adaptive Regression Splines With Application to Neural Recordings. 
						% Front. Neuroinform. 12:67. doi: 10.3389/fninf.2018.00067
│  ├─ ChooseExample.m 			% A function which prompts the user to select an example when running 
						% Detect_Frontloading_Demo.m
├─ Data                     		% A folder containing example datasets
│  ├─ cHAP_HDID				% Example data from a 2-hour drinking-in-the-dark (DID) session using 
						% adult cHAPxHDID mice 
│  ├─ HAP2					% Example data from a 2-hour DID session using adult HAP2 mice 
│  ├─ Wistars				% Example data from a 20-minute free access operant session
						% using adult Wistar rats
Detect_Frontloading_Demo.m		% This script will prompt the user to choose one of the above-mentioned 
						% example datasets to detect frontloading.
						% Then, data from subjects in the chosen example are categorized as frontloaders, 
						% non-frontloaders, or inconclusive results.
						% Results are saved within the folder of the chosen example as both graphs and a 
						% Subject_Number_Summary.mat file. 
Detect Frontloading.m       		% Code to detect frontloading. Use this with your own data.

