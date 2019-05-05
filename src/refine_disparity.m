function [ref_disp] = refine_disparity(disp, w, slack)
    [d, m, n] = size(disp);
    ref_disp = zeros(m,n);
    
    for i=1:m
        for j=1:n
            max_match = 0;
            mxdisp = 1;
            patch = disp(:, max(1,i-w):min(m,i+w), max(1,j-w):min(n,j+w));
            for k=1:d
                cur_val = disp(k,i,j);
                match = (patch < cur_val+slack) .* (patch > cur_val-slack);
                cur_match = sum(sum(match));
                if cur_match > max_match
                    max_match = cur_match;
                    mxdisp = disp(k,i,j);
                end
            end
            ref_disp(i,j) = mxdisp;
        end
    end
end