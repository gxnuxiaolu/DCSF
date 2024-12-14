function [X,Q] = pca_whitening(XText,XTrain,XQ,d)

if d == 512
    d = size(XText,2);
end

    XText = normalize(XText,2,'norm');
    XTrain = normalize(XTrain,2,'norm');
    temp = isnan(XText);
    XText(temp) = 0;
    temp = isnan(XTrain);
    XTrain(temp) = 0;

    [ mu, s, u, ~ , XT] = edit_pca (XTrain,XText,d);
    X = edit_whitening (XT,s,d);
    X = normalize(X,2,'norm');

    XQ = normalize(XQ,2,'norm');
    xq = (XQ - mu) * u;
    Q = edit_whitening (xq,s,d);
    Q = normalize(Q,2,'norm');

end

