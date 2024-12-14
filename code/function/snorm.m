function [x] = snorm(x)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
s = x.^2;
t = sum(s,[1,2]);
epsilon = 1*10^(-5);
% t(t==0)=1;
x = s ./ (sqrt(t) + epsilon);
end

