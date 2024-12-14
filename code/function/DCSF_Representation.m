function [arr] = DCSF_Representation(X,im,in)

F = gctf_weight(X,im);

X = X .* F;

X = testspatial(X,in);

X = snorm(X);

arr = spatial_channel_weight(X);

end