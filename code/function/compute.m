function [mapE,mapM,mapH] = compute(feature,query_feature,K,image_set)

    ks = 0;
    mapM = 0;
    mapH = 0;
    sim = feature * query_feature';
    [~,ranklist] = sort(sim,'descend');
    %.................QE...................%
    if K
        all_index = ranklist(1:K,:);
        for i = 1:size(query_feature,1)
            index = all_index(:,i);
            temp = feature(index,:);
            qe_data = sum(temp);
            query_feature(i,:) = normalize(qe_data,2,'norm');
        end
        sim = feature * query_feature';
        [~,ranklist] = sort(sim,'descend');
    end
    %.......................................%

    if strcmp(image_set,'Oxford5k')
        cfg = load(['../datasets/',image_set,'/gnd_oxford5k.mat']);
        mapE = input1(cfg,ranklist,ks);
    elseif strcmp(image_set,'Paris6k')
        cfg = load(['../datasets/',image_set,'/gnd_paris6k.mat']);
        mapE = input1(cfg,ranklist,ks);
    elseif strcmp(image_set,'Holidays')
        cfg = load(['../datasets/',image_set,'/gnd_holidays.mat']);
        mapE = input1(cfg,ranklist,ks);
    elseif strcmp(image_set,'Oxford105k')
        cfg = load('../datasets/Oxford5k/gnd_oxford5k.mat');
        mapE = input1(cfg,ranklist,ks);
    elseif strcmp(image_set,'Paris106k')
        cfg = load('../datasets/Paris6k/gnd_paris6k.mat');
        mapE = input1(cfg,ranklist,ks);
    elseif strcmp(image_set,'roxford5k')
        cfg = load('../datasets/Oxford5k/gnd_roxford5k.mat');
        [mapE,mapM,mapH] = input2(cfg,ranklist,ks);
    elseif strcmp(image_set,'rparis6k')
        cfg = load('../datasets/Paris6k/gnd_rparis6k.mat');
        [mapE,mapM,mapH] = input2(cfg,ranklist,ks);
    end
end

function mapE = input1(cfg,ranklist,ks)
    gnd = cfg.gnd;
    [mapE] = rcompute_map (ranklist, gnd, ks);
    clear gnd;
end

function [mapE,mapM,mapH] = input2(cfg,ranklist,ks)    
    for i = 1:numel(cfg.gnd)
        gnd(i).ok = [cfg.gnd(i).easy];
        gnd(i).junk = [cfg.gnd(i).junk,cfg.gnd(i).hard];
    end
    [mapE] = rcompute_map (ranklist, gnd, ks);
    for i = 1:numel(cfg.gnd)
        gnd(i).ok = [cfg.gnd(i).easy, cfg.gnd(i).hard]; 
        gnd(i).junk = [cfg.gnd(i).junk];
    end
    [mapM] = rcompute_map (ranklist, gnd, ks);
    for i = 1:numel(cfg.gnd)
        gnd(i).ok = [cfg.gnd(i).hard]; 
        gnd(i).junk = [cfg.gnd(i).junk, cfg.gnd(i).easy];
    end
    [mapH] = rcompute_map (ranklist, gnd, ks);
    clear gnd;
end

