function [S]= get_cts(im)

im = single(im);
[hei,wid,~] = size(im);
colorareas = zeros(3,hei*wid);
colorareas(1,:) = reshape(im(:,:,1),[1,hei*wid]);
colorareas(2,:) = reshape(im(:,:,2),[1,hei*wid]);
colorareas(3,:) = reshape(im(:,:,3),[1,hei*wid]);

im = im2gray(im);
mag = edgegabor(im);
mag1 = reshape(mag(:,:,1),[1,hei*wid]);
mag2 = reshape(mag(:,:,2),[1,hei*wid]);
mag3 = reshape(mag(:,:,3),[1,hei*wid]);
mag4 = reshape(mag(:,:,4),[1,hei*wid]);

[h, w] = meshgrid(1:hei, 1:wid);  
csumh =  reshape(h',[1,hei*wid]);
csumw =  reshape(w',[1,hei*wid]);


sal = zeros(1,hei*wid);

for m=1:hei*wid
    for n=1:hei*wid
        if n ~= m
            T11 = (colorareas(1,m) - colorareas(1,n)).^2;
            T22 = (colorareas(2,m) - colorareas(2,n)).^2;
            T33 = (colorareas(3,m) - colorareas(3,n)).^2;

            gt1 = (mag1(m) - mag1(n))^2;
            gt2 = (mag2(m) - mag2(n))^2;
            gt3 = (mag3(m) - mag3(n))^2;
            gt4 = (mag4(m) - mag4(n))^2;

            dist = sqrt((csumh(m) - csumh(n)).^2 + (csumw(m)- csumw(n)).^2);

            sal(m) = sal(m)+ log(1+(sqrt(gt1+gt2+gt3+gt4)/dist))+ log(1+(sqrt(T11 + T22 + T33)/dist));
        else
            sal(m) = sal(m) + 0;
        end
    end
    
end

S = reshape(sal,[hei,wid]);
end