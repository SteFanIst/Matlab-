function IsoImage = makeImIsoRGB( nonIsoImage, Voxel_size, dim, method )
%MAKEIMISO is used to make an isotropic image from a non-isotropic image
%using interpolation.
%   IsoImage = makeImIso( nonIsoImage, Voxel_size, dim, method )
% 
%     nonIsoImage:  original image (non-isotropic)
%     Voxel_size:   voxel dimension (1-by-3 array)
%     dim:          new dimension of the isotropic voxel (scalar) [default:
%                   Voxel_size(1)]
%     method:       interpolation method [default: 'nearest']
%
%     IsoImage:     output image (isotropic)
%
%   Example:
%        load mri 
%        Image = squeeze(D); 
%        isoImage = makeImIso(Image, [1,1,128/27]);
%        isoImage = makeImIso(Image, [1,1,128/27], 2);
%        isoImage = makeImIso(Image, [1,1,128/27], 0.5, 'cubic');
%        

if nargin < 3
    dim = Voxel_size(1);
    method = 'nearest';
elseif nargin < 4
    method = 'nearest';
end

imDimensions = size(nonIsoImage);

xRatio = double(Voxel_size(1)/dim);
yRatio = double(Voxel_size(2)/dim);
zRatio = double(Voxel_size(3)/dim);

[oX,oY,oZ] = meshgrid(0:imDimensions(2)-1, 0:imDimensions(1)-1, 0:imDimensions(3)-1);
oX = double(oX); oY = double(oY); oZ = double(oZ);
[iX,iY,iZ] = meshgrid(0:1/xRatio:imDimensions(2)-1, 0:1/yRatio:imDimensions(1)-1, 0:1/zRatio:imDimensions(3)-1);
iX = double(iX); iY = double(iY); iZ = double(iZ);
IsoImage = [];
if numel(imDimensions) > 3
    for ch = 1:imDimensions(4)
        IsoImage = cat(4, IsoImage, interp3(oX, oY, oZ, double(nonIsoImage(:,:,:,ch)), iX, iY, iZ, method));
    end
else
    IsoImage = interp3(oX, oY, oZ, double(nonIsoImage), iX, iY, iZ, method);
end

if strcmpi(class(nonIsoImage),'uint8')
    IsoImage = uint8(IsoImage);
elseif strcmpi(class(nonIsoImage),'uint16')
    IsoImage = uint16(IsoImage);
elseif strcmpi(class(nonIsoImage),'uint32')
    IsoImage = uint32(IsoImage);
elseif strcmpi(class(nonIsoImage),'uint64')
    IsoImage = uint64(IsoImage);
elseif strcmpi(class(nonIsoImage),'int8')
    IsoImage = int8(IsoImage);
elseif strcmpi(class(nonIsoImage),'int16')
    IsoImage = int16(IsoImage);
elseif strcmpi(class(nonIsoImage),'int32')
    IsoImage = int32(IsoImage);
elseif strcmpi(class(nonIsoImage),'int64')
    IsoImage = int64(IsoImage);
elseif islogical(nonIsoImage)
    IsoImage = logical(IsoImage);
end    


end

