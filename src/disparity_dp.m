clear;
im_l = imread('../middlebury/Adirondack-perfect/im0.png');
im_r = imread('../middlebury/Adirondack-perfect/im1.png');

% im_l = imgaussfilt(im_l, 1);
% im_r = imgaussfilt(im_r, 1);

% imshow(im_l);

%downsample the image
% step_sz = 4;
% im_l = im_l(1:step_sz:end, 1:step_sz:end);
% im_r = im_r(1:step_sz:end, 1:step_sz:end);

[m, n] = size(im_l);
d = 50; % disparity range
w = 15; % window size
num_disp = 10;

disparity = zeros(num_disp, m, n);
confidence = zeros(m, n);

diffs = zeros(d, w+1, n); % store the pixel wise differences for each disparity

for i=1:d
    diffs(i,:,1:end-i) = im_l(1:w+1, i+1:end) - im_r(1:w+1, 1:end-i);
end

%% store sum of squares (DP)
p_sz = 2*w+1; % patch size
diffs = diffs.^2;
sd = ones(d, p_sz, n)*1e9; % store the ssd along row for each pixel each disparity
sd (:, w+1:end, 1) = sum(diffs(:, :, 1:w+1), 3);

for i=2:n
    r = i+w;
    l = i-w;
    sd(:, :, i) = sd(:, :, i-1);
    if r <= n
        sd(:, w+1:end, i) = sd(:, w+1:end, i) + diffs (:, :, r);
    end
    if l > 1
        sd(:, w+1:end, i) = sd(:, w+1:end, i) - diffs(:, :, l-1);
    end
end

ssd = squeeze(sum(sd, 2)); % store ssd for patch around each pixel each disparity current row
ind = 1; % ind of row in sd to replace

% disparity for first row
[~, inds] = sort(ssd, 1);
disparity(:, 1, :) = inds(1:num_disp, :);
confidence (1, :) = std(ssd);

for i=2:m
    if mod(i,100) == 1
        i
    end
    cur_ind_r = i+w;
    cur_ind_l = i-w;
    if cur_ind_r <= m
        cur_diff = ones(d, n)*1e9; % differences for row i+w
        for j=1:d
            cur_diff(j, 1:end-j) = im_l(cur_ind_r, j+1:end) - im_r(cur_ind_r, 1:end-j);
        end
        cur_diff = cur_diff.^2;
        
        cur_sd = zeros(d, n);
        cur_sd(:, 1) = sum(cur_diff (:, 1:w+1), 2);
        for j = 2:n
            r = j+w;
            l = j-w;
            cur_sd(:, j) = cur_sd(:, j-1);
            if r <= n
                cur_sd (:, j) = cur_sd(:, j) + cur_diff(:, r);
            end
            
            if l > 1
                cur_sd(:, j) = cur_sd(:, j) - cur_diff(:, l-1);
            end
        end
        ssd = ssd + cur_sd;
    end
    if cur_ind_l > 1
        ssd = ssd - squeeze(sd(:, ind, :));
    end
    
    % ssd is for current row
    [~, mn] = sort(ssd, 1);
    disparity(:,i,:) = mn(1:num_disp,:);
%     confidence(i, :) = std(ssd);
    
    % update sd, ind
    sd (:, ind, :) = cur_sd;
    
    ind = ind + 1;
    if ind > p_sz
        ind = 1;
    end
end

% imshow(im_l);
disp = squeeze(disparity(1,:,:));
figure;
imshow(disp/ max(max(disp)));
% figure;
% imshow(confidence/ max(max(confidence)));
