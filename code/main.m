%% example code
clearvars -except in;
addpath('function');
cnn = 'matlab_vgg19';
image_set = {'Oxford5k';'Paris6k';'Oxford105k';'Paris106k';'Holidays';...
    'roxford5k';'rparis6k';'roxford105k';'rparis106k'};
temp_set = image_set{5};
if strcmp(temp_set,"Oxford5k")
    load(['../datasets/',temp_set,'/gnd_oxford5k.mat']);
elseif strcmp(temp_set,"Paris6k")
    load(['../datasets/',temp_set,'/gnd_paris6k.mat']);
elseif strcmp(temp_set,"Holidays")
    load(['../datasets/',temp_set,'/gnd_holidays.mat']);
elseif strcmp(temp_set,"Oxford105k")
    load('../datasets/Oxford5k/gnd_oxford5k.mat');
elseif strcmp(temp_set,"Paris106k")
    load('../datasets/Paris6k/gnd_paris6k.mat');
elseif strcmp(temp_set,"rparis6k")
    load('../datasets/Paris6k/gnd_rparis6k.mat');
elseif strcmp(temp_set,"roxford5k")
    load('../datasets/Oxford5k/gnd_roxford5k.mat');
end
if strcmp(temp_set,'Oxford105k')
    pool51 = dir(['../testdata/',cnn,'/Oxford5k/pool5/*.mat']);
    pool52 = dir(['../testdata/',cnn,'/data100k/pool5/*.mat']);
    pool5 = [pool51;pool52];
    qpool5 = dir(['../testdata/',cnn,'/Oxford5k/crop_query/*.mat']);
    namelist = arrayfun(@(x) x.name, pool5, 'UniformOutput', false);
    qnamelist = arrayfun(@(x) x.name, qpool5, 'UniformOutput', false);
    dphoto1 = dir('../datasets/Oxford5k/photo/*.jpg');
    dphoto2 = dir('../datasets/data100k/photo/*.jpg');
    dphoto = [dphoto1;dphoto2];
    dphoto_path = {dphoto(:).folder};
    dphoto1 = dir('../datasets/Oxford5k/query_images_crop/*.jpg');
    qphoto_path = {dphoto1(:).folder};
    clear dphoto dphoto1 dphoto2 dphoto1
elseif strcmp(temp_set,'Paris106k')
    pool51 = dir(['../testdata/',cnn,'/Paris6k/pool5/*.mat']);
    pool52 = dir(['../testdata/',cnn,'/data100k/pool5/*.mat']);
    pool5 = [pool51;pool52];
    qpool5 = dir(['../testdata/',cnn,'/Paris6k/crop_query/*.mat']);
    namelist = arrayfun(@(x) x.name, pool5, 'UniformOutput', false);
    qnamelist = arrayfun(@(x) x.name, qpool5, 'UniformOutput', false);
    dphoto1 = dir('../datasets/Paris6k/photo/*.jpg');
    dphoto2 = dir('../datasets/data100k/photo/*.jpg');
    dphoto = [dphoto1;dphoto2];
    dphoto_path = {dphoto(:).folder};
    dphoto1 = dir('../datasets/Paris6k/query_images_crop/*.jpg');
    qphoto_path = {dphoto1(:).folder};
    clear dphoto dphoto1 dphoto2 dphoto1
elseif strcmp(temp_set,'roxford5k') || strcmp(temp_set,'rparis6k')
    temp_set2 = temp_set(3:end);
    first = upper(temp_set(2));
    temp_set2 = [first,temp_set2];
    pool5 = dir(['../testdata/',cnn,'/',temp_set2,'/pool5/*.mat']);
    qpool5 = dir(['../testdata/',cnn,'/',temp_set,'/crop_query/*.mat']);
    namelist = imlist;
    namelist = cellfun(@(x) [x, '.mat'], namelist, 'UniformOutput', false);
    qnamelist = qimlist;
    qnamelist = cellfun(@(x) [x, '.mat'], qnamelist, 'UniformOutput', false);
    dphoto = dir(['../datasets/',temp_set2,'/photo/*.jpg']);
    dphoto_path = {dphoto(:).folder};
    dphoto1 = dir(['../datasets/',temp_set,'/rquery_images_crop/*.jpg']);
    qphoto_path = {dphoto1(:).folder};
else
    pool5 = dir(['../testdata/',cnn,'/',temp_set,'/pool5/*.mat']);
    qpool5 = dir(['../testdata/',cnn,'/',temp_set,'/crop_query/*.mat']);
    namelist = arrayfun(@(x) x.name, pool5, 'UniformOutput', false);
    qnamelist = arrayfun(@(x) x.name, qpool5, 'UniformOutput', false);
    dphoto = dir(['../datasets/',temp_set,'/photo/*.jpg']);
    dphoto_path = {dphoto(:).folder};
    dphoto1 = dir(['../datasets/',temp_set,'/query_images_crop/*.jpg']);
    qphoto_path = {dphoto1(:).folder};
end
clear pool51 pool52;
%% 
num = numel(namelist);
parfor i=1:num
    fe_path = [pool5(i).folder,'/',namelist{i}];
    feature_mat = importdata(fe_path);
    ceshifeature(i,:) = permute(sum(feature_mat,[1,2]),[1,3,2]);
end
[in] = spatialweight(ceshifeature);
% compute image feature vectors
num = numel(namelist);
feature = [];
vit_feature = [];
if strcmp(temp_set,"Oxford105k")
    p1 = dir('../testdata/swim/Oxford5k/out/*.mat');
    p2 = dir('../testdata/swim/data100k/out/*.mat');
    p = [p1;p2];
elseif strcmp(temp_set,"Paris106k")
    p1 = dir('../testdata/swim/Paris6k/out/*.mat');
    p2 = dir('../testdata/swim/data100k/out/*.mat');
    p = [p1;p2];
elseif strcmp(temp_set,"rparis6k")
    p = dir('../testdata/swim/Paris6k/out/*.mat');
elseif strcmp(temp_set,"roxford5k")
    p = dir('../testdata/swim/Oxford5k/out/*.mat');
else
    p = dir(['../testdata/swim/',temp_set,'/out/*.mat']);
end
parfor i=1:num
    files_path=[p(i).folder,'/',namelist{i}];
    po = importdata(files_path);
    vit_feature(i,:) = po;
    % vit_feature(i,:) = permute(sum(po,[1,2]),[1,3,2]);
end
parfor i=1:num
    fe_path = [pool5(i).folder,'/',namelist{i}];
    im_path = [dphoto_path{i},'/',namelist{i}(1:end-4),'.jpg'];
    feature_mat = importdata(fe_path);
    im = importdata(im_path);
    pfeature = DCSF_Representation(feature_mat,im,in);
    feature(i,:) = pfeature;
end

clear pool5 imlist namelist pool51 pool52

% compute crop_query image feature vectors

if strcmp(temp_set,'Holidays')
    holidays_feature = feature;
    hvit_feature = vit_feature;
    d = cell2mat(query_list(:,2,:));
    query_feature = holidays_feature(d,:);
    vit_query = hvit_feature(d,:);
    save('../representation/test/Holidays/holidays_feature.mat','holidays_feature');
    save('../representation/test/Holidays/hvit_feature.mat','hvit_feature');
    save('../representation/test/Holidays/query_feature.mat','query_feature');
    save('../representation/test/Holidays/vit_query.mat','vit_query');
else
    num = numel(qnamelist);
    query_feature = [];
    vit_query = [];
    if strcmp(temp_set,"Oxford105k")
        q = dir('../testdata/swim/Oxford5k/query_out/*.mat');
    elseif strcmp(temp_set,"Paris106k")
        q = dir('../testdata/swim/Paris6k/query_out/*.mat');
    else
        q = dir(['../testdata/swim/',temp_set,'/query_out/*.mat']);
    end
    parfor i=1:size(q,1)
        files_path=[q(i).folder,'/',qnamelist{i}];
        qo = importdata(files_path);
        vit_query(i,:) = qo;
        % vit_query(i,:) = permute(sum(qo,[1,2]),[1,3,2]);
    end
    parfor i = 1:num
        fe_path = [qpool5(i).folder,'/',qnamelist{i}];
        feature_mat = importdata(fe_path);
        im_path = [qphoto_path{i},'/',qimlist{i},'.jpg'];
        im = importdata(im_path);
        pfeature = DCSF_Representation(feature_mat,im,in);
        query_feature(i,:) = pfeature;
    end
    if strcmp(temp_set,'Oxford5k')
        oxford_feature = feature;
        ovit_feature = vit_feature;
        save('../representation/test/Oxford5k/oxford_feature.mat','oxford_feature');
        save('../representation/test/Oxford5k/ovit_feature.mat','ovit_feature');
        save('../representation/test/Oxford5k/query_feature.mat','query_feature');
        save('../representation/test/Oxford5k/vit_query.mat','vit_query');
    elseif strcmp(temp_set,'Paris6k')
        paris_feature = feature;
        pvit_feature = vit_feature;
        save('../representation/test/Paris6k/paris_feature.mat','paris_feature');
        save('../representation/test/Paris6k/pvit_feature.mat','pvit_feature');
        save('../representation/test/Paris6k/query_feature.mat','query_feature');
        save('../representation/test/Paris6k/vit_query.mat','vit_query');
    elseif strcmp(temp_set,'Oxford105k')
        oxford105k_feature = feature;
        vit105_feature = vit_feature;
        save('../representation/test/Oxford105k/oxford105k_feature.mat','oxford105k_feature');
        save('../representation/test/Oxford105k/vit105_feature.mat','vit105_feature');
        save('../representation/test/Oxford105k/query_feature.mat','query_feature');
        save('../representation/test/Oxford105k/vit_query.mat','vit_query');
    elseif strcmp(temp_set,'Paris106k')
        paris106k_feature = feature;
        vit106_feature = vit_feature;
        save('../representation/test/Paris106k/paris106k_feature.mat','paris106k_feature');
        save('../representation/test/Paris106k/vit106_feature.mat','vit106_feature');
        save('../representation/test/Paris106k/query_feature.mat','query_feature');
        save('../representation/test/Paris106k/vit_query.mat','vit_query');
    elseif strcmp(temp_set,'roxford5k')
        roxford_feature = feature;
        r5vit_feature = vit_feature;
        save('../representation/test/roxford5k/roxford_feature.mat','roxford_feature');
        save('../representation/test/roxford5k/r5vit_feature.mat','r5vit_feature');
        save('../representation/test/roxford5k/query_feature.mat','query_feature');
        save('../representation/test/roxford5k/vit_query.mat','vit_query');
    elseif strcmp(temp_set,'rparis6k')
        rparis_feature = feature;
        r6vit_feature = vit_feature;
        save('../representation/test/rparis6k/rparis_feature.mat','rparis_feature');
        save('../representation/test/rparis6k/r6vit_feature.mat','r6vit_feature');
        save('../representation/test/rparis6k/query_feature.mat','query_feature');
        save('../representation/test/rparis6k/vit_query.mat','vit_query');
    end
end
%% compute mAP (Execute PCA_Whitening first )
clear;
addpath('function');
% Whether to perform  QE. If you execute QE, please set the size of K.
% For example, K is equal to top 10. K = 10;
K = 0;
i = 5;
image_set = {'Oxford5k';'Paris6k';'Oxford105k';'Paris106k';'Holidays';...
    'roxford5k';'rparis6k';'roxford105k';'rparis106k'};
temp_set = image_set{i};
% Choose how to calculate distance 
% L1            type = 1; 
% L2            type = 2;
% Cosine        type = 3;
% Correlation   type = 4;
type = 2;
mAP = zeros(1,3);
dim = [64,128,256,512];
fprintf('------------------------------------\n');
if strcmp(temp_set,'Oxford5k')
    for i = 1:size(dim,2)
        load('../representation/test/Oxford5k/query_feature.mat');
        load('../representation/test/Oxford5k/oxford_feature.mat');
        load('../representation/test/Paris6k/paris_feature.mat');
        load('../representation/test/Paris6k/pvit_feature.mat');
        load('../representation/test/Oxford5k/ovit_feature.mat');
        load('../representation/test/Oxford5k/vit_query.mat');
        [oxford_feature,query_feature] = pca_whitening(oxford_feature,paris_feature,query_feature,dim(i));
        [ovit_feature,vit_query] = pca_whitening(ovit_feature,pvit_feature,vit_query,dim(i));
        oxford_feature = [oxford_feature,ovit_feature];
        query_feature = [query_feature,vit_query];
        mAP(i) = compute(oxford_feature,query_feature,K,temp_set);
        fprintf('dim = %d  mAP = %.4f\n',size(query_feature,2),mAP(i));
    end
elseif strcmp(temp_set,'Paris6k')
    for i = 1:size(dim,2)
        load('../representation/test/Paris6k/query_feature.mat');
        load('../representation/test/Oxford5k/oxford_feature.mat');
        load('../representation/test/Paris6k/paris_feature.mat');
        load('../representation/test/Paris6k/pvit_feature.mat');
        load('../representation/test/Oxford5k/ovit_feature.mat');
        load('../representation/test/Paris6k/vit_query.mat');
        [paris_feature,query_feature] = pca_whitening(paris_feature,oxford_feature,query_feature,dim(i));
        [pvit_feature,vit_query] = pca_whitening(pvit_feature,ovit_feature,vit_query,dim(i));
        paris_feature = [paris_feature,pvit_feature];
        query_feature = [query_feature,vit_query];      
        mAP(i) = compute(paris_feature,query_feature,K,temp_set);
        fprintf('dim = %d  mAP = %.4f\n',size(query_feature,2),mAP(i));
    end
elseif strcmp(temp_set,'Holidays')
    for i = 1:size(dim,2)
        load('../representation/test/Holidays/query_feature.mat');
        load('../representation/test/Holidays/holidays_feature.mat');
        load('../representation/test/Paris6k/paris_feature.mat');
        load('../representation/test/Paris6k/pvit_feature.mat');
        load('../representation/test/Holidays/hvit_feature.mat');
        load('../representation/test/Holidays/vit_query.mat');
        [holidays_feature,query_feature] = pca_whitening(holidays_feature,paris_feature,query_feature,dim(i));
        [hvit_feature,vit_query] = pca_whitening(hvit_feature,pvit_feature,vit_query,dim(i));
        holidays_feature = [holidays_feature,hvit_feature];
        query_feature = [query_feature,vit_query];
        mAP(i) = compute(holidays_feature,query_feature,K,temp_set);
        fprintf('dim = %d  mAP = %.4f\n',size(query_feature,2),mAP(i));
    end
elseif strcmp(temp_set,'Oxford105k') 
    for i = 1:size(dim,2)
        load('../representation/test/Oxford105k/query_feature.mat');
        load('../representation/test/Oxford105k/oxford105k_feature.mat');
        load('../representation/test/Paris106k/paris106k_feature.mat');
        load('../representation/test/Paris106k/vit106_feature.mat');
        load('../representation/test/Oxford105k/vit105_feature.mat');
        load('../representation/test/Oxford105k/vit_query.mat');
        [oxford105k_feature,query_feature] = pca_whitening(oxford105k_feature,paris106k_feature,query_feature,dim(i));
        [vit105_feature,vit_query] = pca_whitening(vit105_feature,vit106_feature,vit_query,dim(i));
        oxford105k_feature = [oxford105k_feature,vit105_feature];
        query_feature = [query_feature,vit_query];
        mAP(i) = compute(oxford105k_feature,query_feature,K,temp_set);
        fprintf('dim = %d  mAP = %.4f\n',size(query_feature,2),mAP(i));
    end
elseif strcmp(temp_set,'Paris106k')
    for i = 1:size(dim,2)
        load('../representation/test/Paris106k/query_feature.mat');
        load('../representation/test/Paris106k/paris106k_feature.mat');
        load('../representation/test/Oxford105k/oxford105k_feature.mat');
        load('../representation/test/Paris106k/vit106_feature.mat');
        load('../representation/test/Oxford105k/vit105_feature.mat');
        load('../representation/test/Paris106k/vit_query.mat');
        [paris106k_feature,query_feature] = pca_whitening(paris106k_feature,oxford105k_feature,query_feature,dim(i));
        [vit106_feature,vit_query] = pca_whitening(vit106_feature,vit105_feature,vit_query,dim(i));
        paris106k_feature = [paris106k_feature,vit106_feature];
        query_feature = [query_feature,vit_query];
        mAP(i) = compute(paris106k_feature,query_feature,K,temp_set);
        fprintf('dim = %d  mAP = %.4f\n',size(query_feature,2),mAP(i));
    end
elseif strcmp(temp_set,'roxford5k')
    for i = 1:size(dim,2)
        load('../representation/test/roxford5k/roxford_feature.mat');
        load('../representation/test/rparis6k/rparis_feature.mat');
        load('../representation/test/roxford5k/query_feature.mat');
        load('../representation/test/roxford5k/r5vit_feature.mat');
        load('../representation/test/rparis6k/r6vit_feature.mat');
        load('../representation/test/roxford5k/vit_query.mat');
        [roxford5k,query_feature] = pca_whitening(roxford_feature,rparis_feature,query_feature,dim(i));
        [r5vit_feature,vit_query] = pca_whitening(r5vit_feature,r6vit_feature,vit_query,dim(i));
        roxford5k = [roxford5k,r5vit_feature];
        query_feature = [query_feature,vit_query];
        [mape,mapm,maph] = compute(roxford5k,query_feature,K,temp_set);
        fprintf('dim = %d mape = %.4f mapm = %.4f maph = %.4f\n',size(query_feature,2),mape,mapm,maph);
    end
elseif strcmp(temp_set,'rparis6k')
    for i = 1:size(dim,2)
        load('../representation/test/rparis6k/rparis_feature.mat');
        load('../representation/test/roxford5k/roxford_feature.mat');
        load('../representation/test/rparis6k/query_feature.mat');
        load('../representation/test/rparis6k/r6vit_feature.mat');
        load('../representation/test/roxford5k/r5vit_feature.mat');
        load('../representation/test/rparis6k/vit_query.mat');
        [rparis6k,query_feature] = pca_whitening(rparis_feature,roxford_feature,query_feature,dim(i));
        [r6vit_feature,vit_query] = pca_whitening(r6vit_feature,r5vit_feature,vit_query,dim(i));
        rparis6k = [rparis6k,r6vit_feature];
        query_feature = [query_feature,vit_query];
        [mape,mapm,maph] = compute(rparis6k,query_feature,K,temp_set);
        fprintf('dim = %d mape = %.4f mapm = %.4f maph = %.4f\n',size(query_feature,2),mape,mapm,maph);
    end
end
rmpath('function');

