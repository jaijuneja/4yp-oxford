%% Simple single feature, multiple view scenario

f_glob = [1; 1];
f_loc{1} = [1; 0];
H{1} = eye(3);
f_loc{2} = [1; -1];
H{2} = [cos(pi/3) -sin(pi/3) 0; sin(pi/3) cos(pi/3) 0; 0 0 1];

numLocalFeats = length(f_loc);
numIterations = 5;
locfeats = cell(1, numLocalFeats);

for i = 1:numIterations
    subplot(1,numIterations,i)
    plot(f_glob(1), f_glob(2), 'rx'); hold on
    [f_glob, H] = optimise_many_features(f_glob, f_loc, H);
    
    for j = 1:numLocalFeats
    locfeat = H{j} * [f_loc{j}; 1];
    locfeat = locfeat(1:2)/locfeat(3);
    plot(locfeat(1), locfeat(2), 'bx');
        if isequal(i, numIterations)
            locfeats{j} = locfeat;
        end
    end
end

%% Real application
clear
load('/Users/jai/Documents/MATLAB/4yp/test_images/loop_resized/etc/index.mat')
load('/Users/jai/Documents/MATLAB/4yp/test_images/loop_resized/etc/cor_ba.mat')
load('/Users/jai/Documents/MATLAB/4yp/test_images/loop_resized/etc/world_ba.mat')

%% Make a sample world and cor struct
% Some basic cases first:
% e.g. only move global features, only adjust H etc.
%% Global feature bundle adjustment
numIters = 10;
% world3 = world;
% cor3 = cor;
optimH_counter = 0;
onlyoptimH = false;
figure; plot_everything(index, world, cor, 'showMosaic', false, 'matchesOnly', true)
for i = 1:numIters
    fprintf(['Iteration ' num2str(i) '\n'])
    if isequal(mod(i, 4), 0)
        onlyoptimH = true;
    elseif isequal(optimH_counter, 2)
        onlyoptimH = false;
        optimH_counter = 0;
    end
    tic
    [world3, cor3] = bundle_adjustment_world_rep(world3, cor3, 'perspDistPenalty', 0, ...
        'onlyOptimiseH', onlyoptimH, 'weighted', false, 'constrainScale', false);
    toc
    if onlyoptimH
        optimH_counter = optimH_counter + 1;
    end
end
world3 = update_world(world3, cor3);
figure; plot_everything(index, world3, cor3, 'showMosaic', false, 'matchesOnly', true)
% figure; plot3d_poses(index, cor2, world2, 'showMosaic', false);
% cor4 = cor3;
% cor4 = transform_world(cor4, 1000);
% cor4.H_to_ref = cor4.H_to_world;
% mosaic = get_mosaic_pieces(index, cor4);
% img = build_mosaic(index, mosaic, cor4);
% imagesc(img), axis tight, axis equal
%% Local feature bundle adjustment
numIters = 1;
for i = 1:numIters
    [world, cor] = bundle_adjustment_local(world, cor, 'perspDistPenalty', 0, ...
        'onlyOptimiseH', false, 'imsToInclude', []);
end
%% Update world
world = update_world(world, cor);
%%
figure;
% plot_feature_matches(world, cor);
plot_everything(index, world, cor, 'showFeatures', true,  ...
    'matchesOnly', true, 'showImgBorders', true, 'showMosaic', true)