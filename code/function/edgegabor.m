function [mag] = edgegabor(im)



wavelength = 8;
orientation = [0,45,90,135];
gaborArray = gabor(wavelength,orientation);
mag = imgaborfilt(im,gaborArray);



end

