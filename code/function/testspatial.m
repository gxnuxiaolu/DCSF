function [X] = testspatial(feature,in)

[h,w,~] = size(feature);
n= 5;
s = sum(feature(:,:,in(1:n)),3);
avg = sum(s,[1,2]) / nnz(s);
s(s<avg) = 0;
s(s>avg) = 1;

temp = feature(:,:,in(1:n));
temp(temp>0)=1;
s1 = sum(temp,3);
avg = sum(s1,[1,2]) / nnz(s1);
s1(s1<avg) = 0;
s1(s1>avg) = 1;

s = s + s1;
s(s>0) = 1;

X = feature .* s;
end

