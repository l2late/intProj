for who = {'halithan'}%'luca',
    % iterate over both optimization focus options
    for focus = {'prediction'}%'simulation',
        tablePath = ['../id_results/',who{1},'/',...
            num2str(focus{1}),'/tables.mat'];
        load(tablePath);
        
        for ii = 1:3
           latexTablePath = [who{1},'_',num2str(focus{1}),'_model_',...
               num2str(ii),'.tex'];
           table2latex(tab{ii},latexTablePath);            
        end
    end
end