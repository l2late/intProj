%% LQR = Create figure

if ~exist('h1','var')
    h1 = figure('Position', [100 670 670 238]);
    title('Response to Initial Condiiton', 'FontSize', 14);
%     h1.Toolbar = 'none';
end
if ~exist('h2','var')
    h2 = figure('Position', [100 390 670 234]);
    title('Actuator Effor', 'FontSize', 14);
%     h2.Toolbar = 'none';
end
if ~exist('h3','var')
    h3 = figure('Position', [100 80 670 236]);
    title('Pole / Zero Map', 'FontSize', 14);
%     h3.Toolbar = 'none';
end

% Plot response
set(0, 'currentfigure', h1);
hold all
p1 = plot( T, Y(:,1), 'LineWidth', 4);


set(0, 'currentfigure', h2);
hold all
p2= plot( T, -K*X', 'LineWidth', 4);

set(0, 'currentfigure', h3);
hold all
pzmap(sys);
