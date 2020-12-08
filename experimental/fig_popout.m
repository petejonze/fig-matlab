function [ax1 ax2] = fig_popout(h, xmin, xmax, extraprops, drawLines)
%FIG_POPOUT creates a popout plot.
%
% 	creates a popout plot (e.g. outset plot) from axis contained in the
% 	figure specfied by handle h, from limits specified by xmin and xmax
% 	with axes properties specified by the structure props (see example
% 	below).
% 
% 	popout plot inherits all graphics properties of the axis in figure h
% 	(e.g. linewidth, labels).
% 
%  	However, extra axes properties (for each axis) may be specfied to
%  	override inherited properties
%
%   Adapted from popout.m, by Simon Henin (2011)
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	h           Numeric         xxxxxx
%                                   @default: xxxxxx
%
%    	xmin        Numeric         xxxxxxx
%                                   @default: xxxxxx
%
%    	xmax        Numeric         xxxxxxx
%                                   @default: xxxxxx
%
%    	extraprops 	Cell{n}         xxxxxxx
%                                   @default: xxxxxx
%
%    	drawLines 	Logical         xxxxxxx
%                                   @default: xxxxxx
%
% @Returns:  
%
%       ax1         Numeric         Handle of...
%
%       ax2         Numeric         Handle of...
%
%
% @Syntax:
%
%       [ax1 ax2] = fig_popout(h, xmin, xmax, extraprops, drawLines)
%
% @Example:    
%
%       figure();
%       plot(linspace(1,40,20),rand(20),'o');
%       %
%       h = gca;
%       xmin = 5;
%       xmax = 10;
%       fig_popout(h, xmin, xmax);
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	11/10/11	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            Lots (still a work in progress)


%
%   example:
%
%       x=0:0.1:100;
%       y = bessel(1,x);
%       plot(x,y);
%       popout(gcf, 10, 20);
%
%   more complex popout plot example (with axes properties):
%
%       x=0:0.1:100;
%       y1 = bessel(1,x);
%       y2 = bessel(1,x)*2;
% 
%       plot(x,y1, x, y2, 'linewidth', 2); grid on;
%       xlabel('time'); ylabel('amplitude');
%       title('Bessel functions');
%       set(gca, 'fontsize', 12, 'linewidth', 2);
%       ylim([-10 2]);
%       
%       props.axes1.position = [0.1 0.15 0.7 0.8];
%       props.axes2.position = [0.5 0.1 0.4 0.6];
%       props.axes1.fontsize = 10;
%       props.axes2.fontsize = 18;
%       props.axes2.linewidth = 2;
%       props.xlabel = 'poput x-label';
%       props.ylabel = 'poput y-label';
% 
%       [ax1 ax2] = popout(gcf, 10, 20, props);
%
%       Copyright 2011, Simon Henin <shenin@gc.cuny.edu>

if nargin < 4,
   extraprops.axes1.position = [0.1 0.55 0.65 0.35]; 
   extraprops.axes2.position = [0.3 0.1 0.6 0.55]; 
end
if nargin < 5 || isempty(drawLines)
    drawLines = true;
end

if round(h) == h % isinteger(legendHandles)
    H = findall(gcf,'type','axes');
    M    = length(H) - h;
    h = H(M);
elseif ~strcmp(get(h, 'Type'), 'axes')
    error('Specified axis must be a subplot1 number or an axis handle');
end
ax1 = h;

padding = 10;

ax2 = copyobj(ax1, get(ax1,'parent')); % ax2 = copyobj(ax1, gcf);
set(ax2, 'position', extraprops.axes2.position);


children = get(ax1, 'children');
ylimit = get(ax1, 'Ylim');
if iscell(ylimit) % ????????
    ylimit = ylimit{1};
end
set(ax1, 'position',extraprops.axes1.position);
ylim([ylimit(1)+ylimit(1)*(padding/100) ylimit(2)+ylimit(2)*(padding/100)]);

ymax = 0;
ymin = 0;
for i=1:length(children)
    if ~strcmp('text',get(children(i),'type')) % catch some of the obvious non-data objects
        try % just in case any other non-data obejcts slip through
            xd = get(children(i), 'xdata');
            index = find(xd >= xmin & xd <= xmax);
            yd =  get(children(i), 'ydata');
            ymax = max(ymax, max(yd(index)));
            ymin = min(ymin, min(yd(index)));
        catch
        end
    end
end

axes(ax1);
rectangle('Position',[xmin,ymin,xmax-xmin,ymax-ymin], 'linewidth', 2);

axes(ax2);
title('');
xlim([xmin xmax]);
ylim([ymin ymax]);

% add special pop-out properties
if isfield(extraprops, 'xlabel'),
   xlabel(extraprops.xlabel); 
end
if isfield(extraprops, 'ylabel'),
   ylabel(extraprops.ylabel); 
end

% add axes properties
fields = fieldnames(extraprops.axes1);
for i=1:length(fields),
   set(ax1, fields{i}, getfield(extraprops.axes1, fields{i})); 
end
fields = fieldnames(extraprops.axes2);
for i=1:length(fields),
   set(ax2, fields{i}, getfield(extraprops.axes2, fields{i})); 
end

z = [];
if drawLines
    
    % add pop-out lines
    [xf1 yf1] = popout_getcoords(ax1, xmin, ymin);
    [xf2 yf2] = popout_getcoords(ax2, xmin, ymin);
   	annotation(gcf, 'line',[xf1 xf2],[yf1 yf2]);

    % this one removed for neatness/symmetry
    % 
    % [xf1 yf1] = popout_getcoords(ax1, xmin, ymax);
    % [xf2 yf2] = popout_getcoords(ax2, xmin, ymax);
    % annotation(gcf,'line',[xf1 xf2],[yf1 yf2]);

    % commenting this out is a tmp hack. Couldn't get this to work with the
    % copyobj in fig_axesFormat, despite much messing about with
    % uistack(ax2,'top') and the like...
    %
    % [xf1 yf1] = popout_getcoords(ax1, xmax, ymin);
    % [xf2 yf2] = popout_getcoords(ax2, xmax, ymin);
    % annotation(gcf,'line',[xf1 xf2],[yf1 yf2]);

    [xf1 yf1] = popout_getcoords(ax1, xmax, ymax);
    [xf2 yf2] = popout_getcoords(ax2, xmax, ymax);
    annotation(gcf,'line',[xf1 xf2],[yf1 yf2]);
end   

axes(ax2);


function [x y] = popout_getcoords(ax, x, y)


%% Get limits
axun = get(ax,'Units');
set(ax,'Units','normalized');
axpos = get(ax,'Position');
axlim = axis(ax);
axwidth = diff(axlim(1:2));
axheight = diff(axlim(3:4));


x = (x-axlim(1))*axpos(3)/axwidth + axpos(1);
y = (y-axlim(3))*axpos(4)/axheight + axpos(2);


%% Restore axes units
set(ax,'Units',axun)