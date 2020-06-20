clear all; clc;

rs_list = [1,5];%,10,15,20,25,30,35,40];
modelNames = {'greybox 1','greybox 2','blackbox'};
LW = 1; %line width for bw plots

% iterate for both casas: luca and halithan
for who = {'luca','halithan'}
    % iterate over both optimization focus options
    for focus = {'simulation','prediction'}
        jj = 1;
        % Iterate over varying respamling ratios
        for resampleFactor = rs_list

        % close all plots
        close all;

        % Get identification data
        [~, datap_id, datai_id, Tnom, T0, outputOffset] = ....
            get_data(who{1},resampleFactor,'id');

        % Get optimized parameters as initial guesses
        loadName = ['../model_parameters/model_parameters_',who{1}];
        load(loadName);

        %% Greybox model identification 1 tau

        % Initialize greybox model with 1 tau
        odefun = 'linearTclabModel';
        fcn_type =  'c';
        parameters = {'heatCoef1',U;'heatCoef2',Us;'alpha1',alpha1;....
            'alpha2',alpha2;'timeConstant',tau;};
        init_sys = idgrey(odefun,parameters,fcn_type,...
            'Name',modelNames{1},...
            'InputName',{'Heater 1','Heater 2'},...
            'OutputName',{'Temp 1','Temp 2'});

        % Define parameter bounds for greybox model
        % U
        init_sys.Structure.Parameters(1).Minimum = 1;
        init_sys.Structure.Parameters(1).Maximum = 20;
        % Us
        init_sys.Structure.Parameters(2).Minimum = 5;
        init_sys.Structure.Parameters(2).Maximum = 40;
        % alpha1
        init_sys.Structure.Parameters(3).Minimum = 0.001;
        init_sys.Structure.Parameters(3).Maximum = 0.03;
        % alpha2
        init_sys.Structure.Parameters(4).Minimum = 0.001;
        init_sys.Structure.Parameters(4).Maximum = 0.03;
        % tau
        init_sys.Structure.Parameters(5).Minimum = 3;
        init_sys.Structure.Parameters(5).Maximum = 60;

        % Estimate Greybox model with 1 tau
        opt = greyestOptions('SearchMethod','fmincon',...
            'InitialState','zero','Focus',focus{1});
        models{1} = greyest(datap_id,init_sys,opt);


        %% Greybox model identification 2 tau

        % clear old variables
        clear U Us tau alpha1 alpha2

        % get optimized parameters from file
        loadName = ['../model_parameters/model_parameters_',who{1},'_2tau'];
        load(loadName)

        % Initialize greybox model with 2 tau

        odefun = 'linearTclabModel_2tau';
        fcn_type =  'c';
        parameters = {'heatCoef1',U;'heatCoef2',Us;'alpha1',alpha1;....
            'alpha2',alpha2;'timeConstant1',tau1;'timeConstant2',tau2};
        init_sys = idgrey(odefun,parameters,fcn_type,...
            'Name',modelNames{1},...
            'InputName',{'Heater 1','Heater 2'},...
            'OutputName',{'Temp 1','Temp 2'});

        % Define parameter bounds for greybox model
        % U
        init_sys.Structure.Parameters(1).Minimum = 1;
        init_sys.Structure.Parameters(1).Maximum = 20;
        % Us
        init_sys.Structure.Parameters(2).Minimum = 5;
        init_sys.Structure.Parameters(2).Maximum = 40;
        % alpha1
        init_sys.Structure.Parameters(3).Minimum = 0.001;
        init_sys.Structure.Parameters(3).Maximum = 0.03;
        % alpha2
        init_sys.Structure.Parameters(4).Minimum = 0.001;
        init_sys.Structure.Parameters(4).Maximum = 0.03;
        % tau1
        init_sys.Structure.Parameters(5).Minimum = 3;
        init_sys.Structure.Parameters(5).Maximum = 60;
        % tau2
        init_sys.Structure.Parameters(6).Minimum = 3;
        init_sys.Structure.Parameters(6).Maximum = 60;

        % Estimate Greybox model with 2 tau
        opt = greyestOptions('SearchMethod','fmincon',...
            'InitialState','zero','Focus',focus{1});
        models{2} = greyest(datap_id,init_sys,opt);

        %% Blackbox model identification

        bl_sys_order = 4;
        % Identify system and print report
        opt = ssestOptions('InitializeMethod','n4sid',...
            'InitialState','zero','EnforceStability',true,'Focus',focus{1});
        models{3} = ssest(datap_id,bl_sys_order,opt);
        models{3}.Name = modelNames{3};
        
        %% Plot validation results and save images

        % Get validation data
        [~, datap_val, datai_val, Tnom, T0, outputOffset] = ...
            get_data(who{1},1,'val');

        plotPath = ['../id_results/',who{1},'/',...
            num2str(focus{1}),'/',num2str(resampleFactor),'/'];
        
        if ~exist(plotPath, 'dir')
            mkdir(plotPath)
        end

        % save plots for all models        
        for ll = 1:3
            
            opt = compareOptions('InitialCondition','z',...
                'OutputOffset',outputOffset');
            
            % Time domain comparison
            figure('visible','off');
            compare(datai_val,models{ll},'k--',opt);
            legend('Location','SE')
            set(gca,'DefaultLineLineWidth',1)
            saveas(gca,[plotPath, 'comparison_',modelNames{ll},'.png'])
            
            [y_val{ll},model_fit(jj,:,ll)] = compare(datai_val,models{ll},opt);
            
            % Pole-Zero map
            figure('visible','off');
            iopzmap(models{ll})
            saveas(gca,[plotPath, 'polezero_',modelNames{ll},'.png'])

            %  Plot residuals
            opt=residOptions('InitialCondition','z',...
                'OutputOffset',outputOffset');
            figure('visible','off');
            resid(datai_val,models{ll},opt)
            saveas(gca,[plotPath, 'residuals_',modelNames{ll},'.png'])
            
            % Variance accounted for
            vaf(ll,jj) = compute_vaf(datai_val.OutputData,y_val{ll}.OutputData);
            
            %% Save all models

%             % Set path for models
%               modelPath =  ['../id_results/',who{1},'/',...
%                   num2str(focus{1}),'/',num2str(resampleFactor),'/'];       
%             if ~exist(modelPath, 'dir')
%                 mkdir(modelPath)
%             end
%             save([modelPath,'models'],'models');
            
        end
        
        % Bode mag plot
        figure('visible','off');
        bodemag(models{1},...
            models{2},'k--',...
            models{3},'k:')
        legend(modelNames{1},modelNames{2},modelNames{3},...
            'Location','SE')
        saveas(gca,[plotPath, 'bodemag_comparison.png'])
        
        % Time domain comparison plots
        t = datai_val.SamplingInstants;

        figure('visible','off');
        plot(t,datai_val.y(:,1)); hold on;
        for ll = 1:3
            plot(t,y_val{ll}.y(:,1)+outputOffset(1)); hold on;
        end
        hold off
        ylabel('Temperature (deg C)')
        legend('measured',modelNames{1},modelNames{2},modelNames{3}...
            ,'Location','SE')
        title('Time Domain Reponses Temperature sensor 1')
        saveas(gca,[plotPath,'timedomain_comparison_all_T1.png']);


        figure('visible','off');
        plot(t,datai_val.y(:,2)); hold on;
        for ll = 1:3
            plot(t,y_val{ll}.y(:,2)+outputOffset(2)); hold on;
        end
        hold off
        ylabel('Temperature (deg C)')
        legend('measured',modelNames{1},modelNames{2},modelNames{3}...
            ,'Location','SE')
        title('Time Domain Reponses Temperature sensor 2')
        saveas(gca,[plotPath,'timedomain_comparison_all_T2.png']);

        jj = jj + 1; 
        
        end
        
        % constructs table with fit and vaf results
        varNames = {'Fit T1 & T2 (%)'; 'VAF'};
        description = ['Validation performance comparison with ',...
            focus{1},'optimisation focus for varying resampling factors'];
        
        for kk = 1:3
            n_decimal = 1; % for rounding
            tab{kk} = table(round(model_fit(:,:,kk), n_decimal),... 
                round(vaf(kk,:), n_decimal)',...
                 'VariableNames',varNames,...
                 'RowNames',string(rs_list)');
            tab{kk}.Properties.Description = description;
            % set desired precision in terms of the number of decimal places
%             tab{kk} = varfun(@(x) num2str(x, ...
%                 ['%' sprintf('.%df', n_decimal)]), round(tab{kk}));
        end
        
        % save table with fit and vaf results
        tabPath =  ['../id_results/',who{1},'/',num2str(focus{1}),'/'];
        if ~exist(tabPath, 'dir')
            mkdir(tabPath);
        end
        save([tabPath,'tables'],'tab');
        
    end
end