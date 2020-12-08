function [h,t1,t2] = fig_breakXAxis(hAxes, start, stop, epsilon, addTicks)
%FIG_BREAKXAXIS Inserts a notch into the x axis.
%
%   Useful for if there is a large unused area of the plot
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	hAxes       Numeric         Handle to axes
%                                   @default: gca
%
%    	start       Numeric         Last XAxis value before break
%                                   @required
%
%    	stop        Numeric         First XAxis value after break
%                                   @required
%
%    	epsilon     Numeric         Proportion of the axis to take up with
%                                   the 'broken' area
%                                   @default: 0.2
%
%    	addTicks    Logical         Whether to bound the break area with
%                                   tick marks
%                                   @default: true
%
% @Returns:  
%
%       h           Numeric         New data handles
%
%       t1          Numeric         Handle to breakmark on bottom XAxis
%
%       t2          Numeric         Handle to breakmark on top XAxis
%
%
% @Syntax:
%
%       [h,t1,t2] = fig_breakXAxis([hAxes], start, stop, [epsilon], [addTicks])
%
% @Example:    
%
%       figure();
%       plot(linspace(1,40,20),rand(20),'o');
%       %
%       hAxes = gca;
%       start=10;
%       stop=20;
%       fig_breakXAxis(hAxes, start, stop);
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	26/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            <none>

if nargin < 4 || isempty(epsilon)
    epsilon = .2;
end
width = diff(xlim()) * epsilon;

if nargin < 5 || isempty(addTicks)
    addTicks = true;
end


if isempty(hAxes)
    hAxes = gca();
end

data_handles = findobj(hAxes,'type','line');
for i=1:length(data_handles)

    % get values
    h = get(data_handles(i));
    x = h.XData; y = h.YData;

    % erase unused data
    idx = x>start & x<stop;
    x(idx)=[];
    y(idx)=[];

    % map to new xaxis, leaving a space 'width' wide
  	x2=x;
    x2(x2>=stop)=x2(x2>=stop)-(stop-start)+width;
    
%     % set values
%     set(data_handles(i),'XData',x2);
%     set(data_handles(i),'YData',y);
    

   
   	% set values, introducing a discontinuity
    set(data_handles(i),'XData',x2(x<=start));
    set(data_handles(i),'YData',y(x<=start));
    
    z = copyobj(data_handles(i), hAxes); % get(data_handles(i),'parent')
    set(z,'XData',x2(x>=stop));
    set(z,'YData',y(x>=stop)); 
    
%     tag = sprintf('%s£formatLink=%1.16f$',get(z,'Tag'),data_handles(i));
%     set(z,'Tag',tag); % used by format_axes 
    % actually better to do it backwards, since the newer items will be on
    % the top of the stack, so will get formatted first(??)
    tag = sprintf('%s£formatLink=%1.16f$',get(data_handles(i),'Tag'),z);
    set(data_handles(i),'Tag',tag); % used by format_axes 
end

xpos = start + width / 2;
%
ytick=get(hAxes,'YTick');
t1=text(xpos,ytick(1),'//','fontsize',15,'HorizontalAlignment','center');
t2=text(xpos,ytick(max(length(ytick))),'//','fontsize',15,'HorizontalAlignment','center');
set([t1 t2],'BackgroundColor',[1 1 1]); % add white background

% For y-axis breaks, use set(t1,'rotation',270);

% remap tick marks, and 'erase' them in the gap
xtick=get(hAxes,'XTick');
xticklbl=get(hAxes,'XTickLabel');

x = []; xlbl = [];
if addTicks
    x = [start; stop-(stop-start)+width];
    xlbl = num2str([start; stop]); % sprintf('%1.2f\n',x));
end

idx_l = xtick<start;
idx_u = xtick>stop;
xtick = [xtick(idx_l) x' xtick(idx_u)-(stop-start)+width]; % remove any ticks falling in the gap, and add edge ticks if so specified
if ~isempty(xlbl)
    xticklbl = char(xticklbl(idx_l,:), xlbl, xticklbl(idx_u,:)); % vertical char concatenation
else
    xticklbl = char(xticklbl(idx_l,:), xticklbl(idx_u,:)); % to avoid blank line
end

set(hAxes,'XTick',xtick,'XTickLabel',xticklbl);