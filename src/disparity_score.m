function [perc_good] = disparity_score(input_mat, gt_file, step_sz, thresh)
    [gt_mat, ~] = parsePfm(gt_file);
    gt_mat_step = gt_mat(1:step_sz:end, 1:step_sz:end);
    count = gt_mat_step(isinf(gt_mat_step)|isnan(gt_mat_step));
    gt_mat_step(isinf(gt_mat_step)|isnan(gt_mat_step)) = 0;
    input_mat(isinf(gt_mat_step)|isnan(gt_mat_step)) = 0;
    gt_mat_step = abs(gt_mat_step - input_mat);
    gt_mat_step(gt_mat_step<thresh) = 0;
    num_good = sum(sum(gt_mat_step==0));
    [m,n] = size(gt_mat_step);
    perc_good = num_good * 1.0/(m*n);
end