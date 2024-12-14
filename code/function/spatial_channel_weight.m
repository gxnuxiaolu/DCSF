function arr = spatial_channel_weight(X)

[hei,wid,K] = size(X);


XF = X;


area = hei * wid;
c = permute(sum(XF,[1,2]),[1,3,2]);
c = c ./ sum(c);
for i = 1:K
    if c(i) == 0
        c(i) = 0;
    else
        c(i) = c(i) * area / nnz(XF(:,:,i));
    end
end

nzsum = sum(c);
for i=1:length(c)
    if c(i) == 0
        c(i) = 0;
    else
        c(i) = log(nzsum/c(i));
    end
end


Sw = permute(sum(XF,[1,2]),[1,3,2]);


arr = Sw .* c;


end