function [in] = spatialweight(feature)

    [~,index] = max(feature,[],2);
    s = zeros(size(feature));
    for i = 1:size(feature,1)
        s(i,index(i)) = 1;
    end
    t = sum(s);

    [~,in] = sort(t,'descend');
    
end

