function [H,X,Y]=circle(center,radius,style,NOP)
%---------------------------------------------------------------------------------------------
% H=CIRCLE(CENTER,RADIUS,STYLE,NOP)
% This routine draws a circle with center defined as
% a vector CENTER, radius as a scaler RADIS. NOP is 
% the number of points on the circle. As to STYLE,
% use it the same way as you use the rountine PLOT.
% Since the handle of the object is returned, you
% use routine SET to get the best result.
%
%   Usage Examples,
%
%   circle([1,3],3,1000,':'); 
%   circle([2,4],2,1000,'--');
%
%   Zhenhai Wang <zhenhai@ieee.org>
%   Version 1.00
%   December, 2002
%
%   pj Nov 2011, edited inputs
%---------------------------------------------------------------------------------------------

if nargin<3 || isempty(style)
    style='b-';
end
if nargin<4 || isempty(NOP)
    NOP = 1000;
end
THETA=linspace(0,2*pi,NOP);
RHO=ones(1,NOP)*radius;
[X,Y] = pol2cart(THETA,RHO);
X=X+center(1);
Y=Y+center(2);
H=plot(X,Y,style);
axis square;