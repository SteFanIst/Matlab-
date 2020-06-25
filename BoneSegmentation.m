clc;
clear all;

x = imread('A6_(14.9N).bmp');

%% Take the Biggest Blob.
background =(imclose(x(:,:,1)==0,ones(25))); %% Close image size from top bar annotations using a large structural element.
%% In order to seperate foreground and background is to take just one channel (e.g. I take the Green, 2nd channel since I zero the Red first one).
d = (x.*(repmat(1-uint8(background),[1 1 3]))); %%  I take the complement of the image by removing its background.

%% OR Follow Image Analyst Suggestion. See bigblob.m

q = im2bw(d); %% to convert it to logical/binary.

e = bwareafilt(q,1); %% Take the biggest blob once again to minimize the overall size of the image.

r = edge(e);  %% Sobel edge Detection

CC = bwareaopen(r, 59); %% Remove blobs and speckle clusters from 59 pixels and smallers.

se = strel('line',80,180); 
BW2 = imdilate(CC,se);  %% Dilate the image accordingly so most of the gaps get filled.

%% Alternatively you can use imclose(CC,se);
imshow(BW2);