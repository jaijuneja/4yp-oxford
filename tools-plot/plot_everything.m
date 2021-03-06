function plot_everything(model, world, cor, varargin)
% Jai Juneja, www.jaijuneja.com
% University of Oxford
% 08/12/2013
% -------------------------------------------------------------------------
%
% PLOT_EVERYTHING
% plot_everything(model, world, cor, 'matchesOnly', valMatchesOnly,
% 'showFeatures', valShowFeatures, 'showMosaic', valShowMosaic,
% 'showImgBorders', valShowImgBorders)
%
% Superimposes plots of the image mosaic, features and image edge lines.
% Various optional input properties allow you to select which of these
% plots to include.
%
% Inputs:
%   - model:    Index of images from visualindex. Type 'help
%               visualindex_build' for more info
%   - world:    World structure containing global features. Type 'help 
%               build_world' for more info
%   - cor:      Correspondence structure containing links between different
%               images (graph representation using an adjacency matrix).
%               Type 'help build_correspondence' for more info
%
%   Optional Properties:
%       - showFeatures:     Set to false if you don't want to display
%                           features; true by default
%       - matchesOnly:      Only applies when showFeatures is set to true.
%                           Set to true if you only want to show features
%                           that are matched between multiple images. False
%                           by default
%       - globalFeatsOnly:  Only applies when showFeatures and matchesOnly
%                           are both set to true. When true, only global
%                           features are displayed (local matches are
%                           hidden). False by default
%       - showMosaic:       Set to false if you don't want to display the
%                           image mosaic under the features; true by
%                           default
%       - showImgBorders:   Set to false if you don't want to display lines
%                           along the borders of images; true by default
%       - fromFrame:        Plots the view of the world from the reference
%                           frame of image with the given ID. If set to
%                           zero, viewed from reference frame. If set to
%                           'world', viewed in world frame. Set to 'world'
%                           by default
%       - scaleFactor:      Apply scale factor to world plot
%       - fromFrame:        Which reference frame to plot the world from.
%                           Either the world frame 'w', or the ref frame
%                           'ref'. World frame by default

opts.matchesOnly = false;
opts.globalFeatsOnly = false;
opts.showFeatures = true;
opts.featPlotStyle = 'raw';
opts.showMosaic = true;
opts.showImgBorders = true;
opts.scaleFactor = 1;
opts.fromFrame = 'w';
opts = vl_argparse(opts, varargin);
valLineColour = 'black';

if ~isequal(opts.scaleFactor, 1)
    cor = transform_world(cor, opts.scaleFactor);
    if opts.showFeatures
        world = transform_world(world, opts.scaleFactor);
    end
end
    
if strcmp(opts.fromFrame, 'w')
    cor.H_to_ref = cor.H_to_world;
elseif opts.showFeatures
    world = transform_world(world, cor.H_world_toref);
end
    
% Get offset parameters
offsets = plot_transformations(model, cor, 'plotOnImage', true, ...
    'dontPlot', true, 'fromFrame', opts.fromFrame);
xOffset = offsets(1); yOffset = offsets(2);

% Plot image mosaic
if opts.showMosaic
    mosaic = get_mosaic_pieces(model, cor);
    image_map = build_mosaic(model, mosaic, cor);
    imagesc(image_map);
    valLineColour = 'g';
    hold on
end

% Plot features
if opts.matchesOnly && opts.showFeatures
    plot_feature_matches(world, cor, 'globalFeatsOnly', opts.globalFeatsOnly, ...
        'xOffset', xOffset, 'yOffset', yOffset);
    hold on
elseif opts.showFeatures
    plot_features(world, 'xOffset', xOffset, 'yOffset', yOffset);
    hold on
end

% Plot image edges lines
if opts.showImgBorders
    plot_transformations(model, cor, 'plotOnImage', true, ...
        'LineColour', valLineColour, 'fromFrame', opts.fromFrame);
end

% Turn of axis if plotting mosaic
if opts.showMosaic, axis off, end
axis equal, hold off

end