function [image_map, origin] = build_mosaic(model, mosaic, cor)
% Jai Juneja, www.jaijuneja.com
% University of Oxford
% 20/11/2013
% -------------------------------------------------------------------------
%
% BUILD_MOSAIC
% [image_map, origin] = build_mosaic(mosaic, im_ref_id)
%
% Build an image mosaic by superimposing a set of images.
%
% Inputs:
%   - model:    Index of images from visualindex. Type 'help
%               visualindex_build' for more info
%   - mosaic:	Structure containing images ('pieces') transformed
%            	relative to reference image and their origins
%               ('origins') in pixel co-ordinates
%   - cor:      Correspondence structure containing links between different
%               images (graph representation using an adjacency matrix).
%               Type 'help build_correspondence' for more info
%
% Outputs:
%   - image_map:    Output mosaic image. Empty pixels contain NaN
%   - origin:       Pixel co-ordinates of image origin (given by bottom
%                   left corner of reference image in the mosaic)

% Load reference image
im_ref = imread(model.index.names{cor.ref_img});
% Initialise image map
% image_map = im2double(im_ref);
image_map = nan(size(im_ref));
mass = zeros(size(im_ref));

% Origin is bottom left of reference image
origin = [size(im_ref, 1), 1];
num_matches = numel(mosaic.pieces);

for i = 1:num_matches
    map_size = size(image_map);
    space_top = origin(1);
    space_bottom = map_size(1) - space_top;
    space_left = origin(2);
    space_right = map_size(2) - space_left;

    image_map_tmp = mosaic.pieces{i};
    origin_tmp = mosaic.origins{i};
    
    map_size_tmp = size(image_map_tmp);
    space_top_tmp = origin_tmp(1);
    space_bottom_tmp = map_size_tmp(1) - space_top_tmp;
    space_left_tmp = origin_tmp(2);
    space_right_tmp = map_size_tmp(2) - space_left_tmp;

    % Adjust images so that they have the same origin
    if space_top > space_top_tmp
        toprows = space_top - space_top_tmp;
        image_map_tmp = [nan(toprows, map_size_tmp(2), 3); image_map_tmp];
        map_size_tmp = size(image_map_tmp);
    end
    if space_top_tmp > space_top
        toprows = space_top_tmp - space_top;
        image_map = [nan(toprows, map_size(2), 3); image_map];
        map_size = size(image_map);
        origin(1) = origin(1) + toprows;
        mass = [zeros(toprows, map_size(2), 3); mass];
    end
    
    if space_bottom > space_bottom_tmp
        bottomrows = space_bottom - space_bottom_tmp;
        image_map_tmp = [image_map_tmp; nan(bottomrows, map_size_tmp(2), 3)];
        map_size_tmp = size(image_map_tmp);
    end
    if space_bottom_tmp > space_bottom
        bottomrows = space_bottom_tmp - space_bottom;
        image_map = [image_map; nan(bottomrows, map_size(2), 3)];
        map_size = size(image_map);
        mass = [mass; zeros(bottomrows, map_size(2), 3)];
    end 
    
    if space_left > space_left_tmp
        colsleft = space_left - space_left_tmp;
        image_map_tmp = [nan(map_size_tmp(1), colsleft, 3), image_map_tmp];
        map_size_tmp = size(image_map_tmp);
    end
    if space_left_tmp > space_left
        colsleft = space_left_tmp - space_left;
        image_map = [nan(map_size(1), colsleft, 3), image_map];
        map_size = size(image_map);
        origin(2) = origin(2) + colsleft;
        mass = [zeros(map_size(1), colsleft, 3), mass];
    end
        
    if space_right > space_right_tmp
        colsright = space_right - space_right_tmp;
        image_map_tmp = [image_map_tmp, nan(map_size_tmp(1), colsright, 3)];
        map_size_tmp = size(image_map_tmp);
    end
    if space_right_tmp > space_right
        colsright = space_right_tmp - space_right;
        image_map = [image_map, nan(map_size(1), colsright, 3)];
        map_size = size(image_map);
        mass = [mass, zeros(map_size(1), colsright, 3)];
    end
    
    mosaic.pieces{i} = image_map_tmp;
    mosaic.origins{i} = origin_tmp;
    
    % Take average of the two images being superimposed
    mass_new = mass + ~isnan(image_map_tmp);
    image_map(isnan(image_map)) = 0 ;
    image_map_tmp(isnan(image_map_tmp)) = 0 ;
    
    image_map = (image_map .* mass + image_map_tmp) ./ mass_new;
    image_map(image_map == 0) = NaN;
    
    mass = mass_new;
end

mass = mass(:,:,1) | mass(:,:,2) | mass(:,:,3);
% Remove black pixel padding
% pixels = (mass ~= 0);
% [row, col] = find(pixels);
% minrow = min(row);
% if ~isequal(minrow, 1)
%     image_map(1:minrow-1, :, :) = [];
% end
% mincol = min(col);
% if ~isequal(mincol, 1)
%     image_map(:, 1:mincol-1, :) = [];
% end
% maxrow = max(row) - minrow + 1;
% if ~isequal(maxrow, size(image_map, 1) - minrow + 1)
%     image_map(maxrow+1:end, :, :) = [];
% end
% maxcol = max(col);
% if ~isequal(maxcol, size(image_map, 2) - mincol + 1)
%     image_map(:, maxcol+1:end, :) = [];
% end
end