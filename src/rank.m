clear;
im_l = rgb2gray(imread('../middlebury/Vintage-perfect/im0.png'));
im_r = rgb2gray(imread('../middlebury/Vintage-perfect/im1.png'));

w_sizes = [25];
step_sz = 5;
step_sz2 = 3;

[m, n] = size(im_l);
rank_l = zeros(m,n);
rank_r = zeros(m,n);
for x= 1:m
    for y = 1:n
        lim_l = max(1,x-2);
        lim_r = min(m,x+2);
        lim_t = max(1,y-2);
        lim_b = min(n,y+2);
        rank_l(x,y) = sum(sum( im_l(lim_l:lim_r, lim_t:lim_b) >= im_l(x,y))) -1;
        rank_r(x,y) = sum(sum( im_r(lim_l:lim_r, lim_t:lim_b) >= im_r(x,y))) -1;
    end
end


disparity = zeros(ceil(m/step_sz), ceil(n/step_sz));
disp_range = 300;

for x=[1:step_sz:m]
    for y=[1:step_sz:n]
        match_val = zeros(1,ceil(disp_range/step_sz2));
        for k=[1:length(w_sizes)]
            w_sz = w_sizes(k);
            patch_sz = 2*w_sz + 1;
            
            patch_l = zeros(patch_sz, patch_sz);
            ind_x_l = max(x-w_sz,1);
            ind_x_r =  min(x+w_sz,m);
            ind_y_l = max(y-w_sz,1);
            ind_y_r = min(y+w_sz,n);
            patch_l(ind_x_l-x+w_sz+1:ind_x_r-x+w_sz+1, ind_y_l-y+w_sz+1:ind_y_r-y+w_sz+1) = rank_l(ind_x_l:ind_x_r,ind_y_l:ind_y_r);

            
            for yr=[1:step_sz2:disp_range]
                y2 = y-yr;
                patch_r = zeros(patch_sz, patch_sz);
                ind_x_l = max(x-w_sz,1);
                ind_x_r =  min(x+w_sz,m);
                ind_y_l = max(y2-w_sz,1);
                ind_y_r = min(y2+w_sz,n);
                patch_r(ind_x_l-x+w_sz+1:ind_x_r-x+w_sz+1, ind_y_l-y2+w_sz+1:ind_y_r-y2+w_sz+1) = rank_r(ind_x_l:ind_x_r,ind_y_l:ind_y_r);

                match_val(ceil(yr/step_sz2)) = match_val(ceil(yr/step_sz2)) + sum(sum(abs(patch_l - patch_r)));
            end
        end
        [~,ind] = min(match_val); 
        disparity(ceil(x/step_sz),ceil(y/step_sz)) = abs(ind*step_sz2);
    end
    if mod(x,100) == 1
        x
    end
end
disparity_image = disparity;
disparity = disparity/max(max(disparity));
imshow(disparity);
% per_good_pixel = disparity_score(disparity_image, '../middlebury/Vintage-perfect/disp0.pfm', step_sz, 20)
