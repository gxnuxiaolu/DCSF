function [F] = gctf_weight(X,im)

[hei,wid,~] = size(X);

im = imresize(im, [hei wid]);

cts = get_cts(im);

F = cts;

end
