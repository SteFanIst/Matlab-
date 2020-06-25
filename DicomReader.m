function Img = DicomReader(filename)

dicom_header = dicominfo(filename);
sampleSlice = dicomread(dicom_header);
file_names = dir('*.dcm');
if strcmpi(dicom_header.PhotometricInterpretation, 'RGB')
    Img = false([dicom_header.Height, dicom_header.Width, length(file_names), 3]);
else
    Img = false([dicom_header.Height, dicom_header.Width, length(file_names)]);
end
if strcmpi(class(sampleSlice),'uint8')
    Img = uint8(Img);
elseif strcmpi(class(sampleSlice),'uint16')
    Img = uint16(Img);
elseif strcmpi(class(sampleSlice),'uint32')
    Img = uint32(Img);
elseif strcmpi(class(sampleSlice),'uint64')
    Img = uint64(Img);
elseif strcmpi(class(sampleSlice),'int8')
    Img = int8(Img);
elseif strcmpi(class(sampleSlice),'int16')
    Img = int16(Img);
elseif strcmpi(class(sampleSlice),'int32')
    Img = int32(Img);
elseif strcmpi(class(sampleSlice),'int64')
    Img = int64(Img);
elseif islogical(sampleSlice)
    Img = logical(Img);
end    

minSliceNo = Inf;
maxSliceNo = 0;
numSlices = numel(file_names);
for i = 1:numSlices
    dicom_header = dicominfo(file_names(i).name);
    if dicom_header.InstanceNumber < minSliceNo
        minSliceNo = dicom_header.InstanceNumber;
    end
    if dicom_header.InstanceNumber > maxSliceNo
        maxSliceNo = dicom_header.InstanceNumber;
    end
    if strcmpi(dicom_header.PhotometricInterpretation, 'RGB')
        Img(:,:,dicom_header.InstanceNumber,:) = dicomread(dicom_header);
    else
        Img(:,:,dicom_header.InstanceNumber) = dicomread(dicom_header);
    end
end
if strcmpi(dicom_header.PhotometricInterpretation, 'RGB')
    Img = Img(:,:,minSliceNo:maxSliceNo,:);
else
    Img = Img(:,:,minSliceNo:maxSliceNo);
end
    
   
end
