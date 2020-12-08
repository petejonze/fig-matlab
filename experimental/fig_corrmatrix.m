function [hFig, hScatPlots, hLeg] = fig_corrmatrix(hFig, X, varNames, dohist, showRho, ticks, tickLbls, lims, rho, nBins, logScatter, keyTxt, rhoLoc, proportionPlotScatter, addLsLine, rhoType)
%FIG_CORRELATION plot correlation matrix, with optional histograms
%
%   Plots a (lower diagonal) matrix of scatter plots to visualise the
%   correlations between 2 or more variables. Pearson correlations are
%   applied independently between each pair of variables, and the results
%   (optionally) displayed. A histogram of each variable may also be
%   displayed (optional). 
%
%
% @Requires:        fig [package]
%                   Matlab v2008 onwards
%   
% @Input Parameters:
%
%    	hFig    	Numeric         Handle of figure. If omitted then a new
%                                   figure will be created and
%                                   appropriately initialised (recommended)
%                                   @default: <figure created>
%
%    	X           Numeric[m,n]    Data. Each column is a variable. Each
%                                   row is an observation. E.g., a 30x4
%                                   matrix will produce 6 scatter plots.
%                                   @required
%
%    	varNames    Cellstr{n}      Name of each variable (column). Used to
%                                   title each axis
%                                   @default: {'var1','var2',...'varN'} 
%
%    	dohist      Logical         Whether to plot histograms for each
%                                   variable (on the diagonal)
%                                   @default: false
%
%    	showRho     Logical         Whether to annotate each panel with the
%                                   associated correlation coeficient. If
%                                   no values are inputted (cf. rho, below)
%                                   then Pearson correlations will be 
%                                   calculated
%                                   @default: true
%
%    	ticks       Numeric[n]      Values at which to place tick marks
%                                   (same for both X- and Y- axes)
%                                   @default: determined by system
%
%    	tickLbls    Cellstr{n}      Text to label each tickmark with
%                                   @default: same as ticks
%
%    	lims        Numeric[2]      [min max] axis limits
%                                   (same for both X- and Y- axes)
%                                   @default: data +/- [25% of range]
%
%    	rho         Numeric[n]      Values to be used as correlation
%                                   coefficients. If omitted then a
%                                   pairwise Pearson's test will be used
%                                   @default: corrcoef(X,'rows','pairwise')
%
%    	nBins       Numeric[n]      Number of bins to use in histograms
%                                   (i.e., only if doHist == true)
%                                   @default: 10
%
%    	logScatter  Logical         If true then axes are scaled in log10
%                                   @default: false
%
%    	keyTxt      Cellstr{n}      Text for an optional legend, which is
%                                   displayed top-right
%                                   @default: []
%
%    	rhoLoc      Char            Location within each panel at which to
%                                   display correlation coefficients
%                                   @default: 'NorthEast'
%
%    	rhoType   	Char            'Pearson' or 'Spearman'
%                                   @default: 'Pearson'
%
% @Returns:  
%
%       hFig        Numeric         Handle of figure
%
%       hScatPlots  Numeric[n]      Handles of each correlation panel
%       
%       hLeg        Numeric         Handle of legend (or empty if none)
%
%
% @Syntax:
%
%       [hFig, hScatPlots] = fig_corrmatrix([hFig], X, [varNames], [dohist], [showRho], [ticks], [tickLbls], [lims], [rho], [nBins], [logScatter], [keyTxt], [rhoLoc], [varargin])
%
% @Example:    
%
%       X = randn(30,4);
%       varNames = {'var1','vr2','var3','d'};
%       dohist= true;
%       showRho = false;
%       ticks = [-3 0 3];
%       tickLbls = [];
%       lims = [-5 5];
%       fig_corrmatrix([], X, varNames, dohist, showRho, ticks, tickLbls, lims);
%
% @See also:        EXAMPLES.m
% 
% @Author:          Pete R Jones <petejonze@gmail.com>
%
% @Version History: 1.0.0	02/02/12	First Build            	[PJ]
%                   1.0.1	08/10/12	Tweaks & comments       [PJ]
%
% @Todo:            <none>



    %%%%%%%
    %% 1 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Init %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
       	% compute plot params
        datMax = max(max(X)); % throw error if X not inputted
        datMin = min(min(X));
        margin = (datMax - datMin)*(25/100); % 25 percent margin
        
        % parse input paramters, substitutes defaults if necessary
        if nargin < 1 || isempty(hFig)
            hFig = [];
        end
        if nargin < 2 || isempty(X)
            error('fig_corrmatrix:invalidInput','Data, X, is required')
        end
        if nargin < 3 || isempty(varNames)
            varNames = strread(sprintf('var%i\n',1:4),'%s');
        end
        if nargin < 4 || isempty(dohist)
            dohist = 0;
        end
        if nargin < 5 || isempty(showRho)
            showRho = true;
        end
        % if not overwrite default params:
        if nargin < 6 || isempty(ticks)
            ticks = [];
        end
        if nargin < 7 || isempty(tickLbls)
            tickLbls = [];
        end
        if nargin < 8 || isempty(lims)
            lims = [datMin-margin datMax+margin];
        end
        if nargin < 16 || isempty(rhoType)
            rhoType = 'Pearson';
        end
        if nargin < 9 || isempty(rho)
            % rho = corrcoef(X,'rows','pairwise');
            rho = corr(X,'type',rhoType); % when 'pearson' same as corrcoef
        end
        if nargin < 10 || isempty(nBins)
            nBins = 11;
        end
        if nargin < 11 || isempty(logScatter)
            logScatter = false;
        end
        if nargin < 12 || isempty(keyTxt)
            keyTxt = []; % key appears top right
        end
        if nargin < 13 || isempty(rhoLoc)
            rhoLoc = 'NorthEast';
        end
        if nargin < 14 || isempty(proportionPlotScatter)
            proportionPlotScatter = 1;
        end
        if nargin < 15 || isempty(addLsLine)
            addLsLine = false;
        end
        
        if isnan(ticks)
            tickLbls = NaN;
        end
        if logScatter
            lims(1) = max(lims(1),.01);
        end

        % compute further params
        nVars = length(rho);
        if dohist
            nCols = nVars;
            nRows = nVars;
        else
            nCols = nVars-1;
            nRows = nVars-1;
        end
            
        % calc histograms
        % log x-axis if required
        if logScatter
         	hist_xlims = log10(lims);
            [hist_N,hist_X] = hist(log10(X), nBins);
        else
            hist_xlims = lims;
            [hist_N,hist_X] = hist(X, nBins);
        end
        hist_ylims = [0 max(max(hist_N)) * 1.25]; % 25 percent margin     
        
    %%%%%%%
    %% 2 %%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Plot %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % open a new figure window.
        if isempty(hFig)
            hFig = fig_make([], [nRows nCols], true, true);
        end
        
        % plot lower diagonal correlations
        hScatPlots = [];
        for j=1:(nVars-1)
            for i=(j+1):nVars
                % calc plot params
                xAxisTitle = []; yAxisTitle = [];
                if j==1 % if marginal column
                    yAxisTitle = varNames{i};
                end
                if i==nVars % if marginal row
                    xAxisTitle = varNames{j};
                end
                % set focus
                hAxes = fig_subplot([i-1+dohist j]);
                % plot correlation
                idx = (1:size(X,1)) <= round(proportionPlotScatter*size(X,1));
                hDat = plot(X(idx,j),X(idx,i),'o', 'MarkerSize',4); %#ok
%                 set(gca,'XTick',[],'YTick',[]); % HACK (??? This causes labels to disappear??)
                if logScatter
                    set(gca,'XScale','log','YScale','log')
                    if isempty(tickLbls) % ensure actual values shown (not logs)
                        if isempty(ticks)
                            tickLbls = log10(get(hAxes,'XTick'));
                        else
                            tickLbls = ticks; % log10(ticks);
                        end
                    end
                    [hXTickLbl, hYTickLbl, c_axes] = fig_axesFormat(gca, ticks,tickLbls, ticks,tickLbls, xAxisTitle, yAxisTitle, lims,lims); %#ok
                else                  
                    % Format the axis: fig_axesFormat(axesHandle, xTick,xTickLbl, yTick,yTickLbl, xAxisTitle,yAxisTitle, xlims,ylims, fontSize, autoFormatData, xMinorTick,yMinorTick,minorTickLength, xRotation,yRotation, vGridColr,hGridColr)
                    [hXTickLbl, hYTickLbl, c_axes] = fig_axesFormat(gca, ticks,tickLbls, ticks,tickLbls, xAxisTitle, yAxisTitle, lims,lims); %#ok
                end
                
                if addLsLine
                    % set(lsline(), 'Color','r', 'linewidth',1.5);
                    
                    % this way, all the data is used (even that which isn't
                    % plotted in the scatter), and no reliance on the stats
                    % toolkit
                    idx = ~any(isnan(X(:,[i j])),2);
                    if any(idx) % if any data to actually fit
                        p = polyfit(X(idx,j),X(idx,i), 1);
                        plot(lims, polyval(p,lims), 'r', 'linewidth',1.5);
                    end
                end
                % add unity line
                uline('k:');
                    
                % label with rho
                if showRho
                    %textLoc(sprintf('.%1.0f',rho(i,j)*100), rhoLoc);
                    textLoc(sprintf('$r_{%i} = .%1.0f$', size(X,1)-2, rho(i,j)*100), rhoLoc);
                end
                % add ref
                hScatPlots(end+1,:) = [i-1+dohist j];
            end
        end

        % plot histograms along the diagonal
        if dohist
            for i=1:nCols
                % calc plot params
                ytick = NaN;
                ytickLbl = NaN;
                if i==1 && ~all(isnan(ticks)) % only label first panel (and only then if ticks haven't been manually suppressed by the user)
                    ytick = floor(hist_ylims(2));
                    ytickLbl = ytick;
                end
                % set focus
                fig_subplot([i i]);
                % plot histogram
               	bar(hist_X, hist_N(:,i));
                % Format the axis
                set(gca,'XTick',[],'YTick',[]); % HACK
                xAxisTitle = []; yAxisTitle = [];
                if i==1
                    yAxisTitle = varNames{i};
                elseif i==nCols
                    xAxisTitle = varNames{i};
                end             
                [hXTickLbl, hYTickLbl, c_axes] = fig_axesFormat(gca, NaN,NaN, ytick,ytickLbl, xAxisTitle, yAxisTitle, hist_xlims,hist_ylims); %#ok
            end   
        end


        % make upper off-diagonal invisible
        for j=2:nCols
            for i=1:(j-1)
                fig_subplot([i j]);
                set(gca,'visible','off');
            end
        end
        
        % add key, if requested
        hLeg = [];
        if ~isempty(keyTxt)
            fig_subplot([1 nCols])
            tmp = [varNames; keyTxt];
            txt =  sprintf('%s: %s\n',tmp{:});
            hLeg = textLoc(txt,'West');
        end
        
        % format the figure
        [hXTitle,hYTitle,hTitle] = fig_figFormat(); %#ok                
end