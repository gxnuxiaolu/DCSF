function [mu,s,u,x,x2] = edit_pca(X,XT,d)
mu = mean(X);
Xcov = cov(X, 'omitrows');
Xcov(isnan(Xcov)) = 0;
[u,s,~] = svd(Xcov);
X = X - mu;
x = X * u;
x = x(:,1:d);

XT = XT - mu;
x2 = XT * u;
end


