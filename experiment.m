function experiment(varargin)

clc;

hFig = openfig('assume.fig') %% Load initial figure

gui_State = struct('gui_Name',hFig);

      
projectdir = 'D:\stelios phd files\DesMoines\karadokei\New';

handles.folder = projectdir;
filelist = dir(fullfile(handles.folder, '*.dcm')); %%Get all dicom images from the folder

handles.filelist = fullfile(handles.folder, {filelist.name});
handles.frameindex = 1;



NumFrames = length(handles.filelist); %// Check below for dummy 4D matrix/image sequence
frameindex  = max(1, min(handles.frameindex, NumFrames)); %% Order the slices from minimum to maximum
handles.axes7 = axes('Parent',hFig,'Units','characters','Position',[9.8 27.077 17.6 7.769]);

    btn = uicontrol('Style', 'pushbutton', 'String', 'Load Image','Units','characters',...
        'Position', [165.2 33.923 14.6 2.615],...
        'Callback', @btn_Callback);



axes(handles.axes7)
I = imread('staffs.png');
imshow(I,'Parent',handles.axes7)
axis off
axis image



[fileName, isCancelled] = imgetfile();

im = DicomReader(fileName)
handles.im2 = makeImIsoRGB(im, [1,1,15], 2.0, 'cubic')


sizeIn = size(handles.im2);
sliceIndex =round(sizeIn(3)/2);
 
data = dlmread('imgpositions.txt');
[row, col] = size(data);
x=data(:,1)
y=data(:,2)


translation_vector=[row col 0 0];




data = dlmread('imgpositions.txt');
for m = 1:size(data,1)    
    Image3D(:,:,m) = imtranslate(handles.im2(:,:,m),data(m,:)); %% Translate the image slices according to X,Y coordinates by reading the txt file
end

Image3D = makeImIsoRGB(Image3D,[1,1,15],2.0,'cubic')

MyMatrix = Image3D
handles.im2 = MyMatrix

    
handles.im3 = flip(permute(MyMatrix, [3 1 2 4]),1); %% Create the Sagittal and Coronal planes
handles.im4 = flip(permute(MyMatrix, [3 2 1 4]),1);

sno = size(handles.im2)
sno_s = sno(2);
sno_a = sno(3)
sno_c = sno(1)

slice1=round(size(handles.im2,1)/2);
slice2=round(size(handles.im2,2)/2);
slice3=round(size(handles.im2,3)/2);

setappdata(hFig, 'MyMatrix', MyMatrix);




 
handles.axes1 = subplot(2,2,1)
handles.axes2 = subplot(2,2,2)
handles.axes3 = subplot(2,2,3)



subplot(2,2,1)


handles.i1 = imshow(squeeze(handles.im2(:,:,slice3,:)),'XData',[1 592], 'YData',[1 481],'parent',handles.axes1)



subplot(2,2,2)

handles.i2 = imshow(squeeze(handles.im3(:,:,slice2,:)),'XData',[1 592], 'YData',[1 481],'parent',handles.axes2);


subplot(2,2,3)

handles.i3 = imshow(squeeze(handles.im4(:,:,slice1,:)),'XData',[1 592], 'YData',[1 481],'parent',handles.axes3);


subplot(2,2,4)
vol3d('cdata', squeeze(handles.im2), 'xdata', [0 1], 'ydata', [0 1], 'zdata', [0 0.7]); %% Call the vol3d for the 3d volume reconstruction
colormap(gray);
alphamap([0 linspace(0.1, 0.8, 255)]);
axis equal off
rotate3d on;
set(gcf, 'color', 'w');
view(3);

pan off %% Disable the initial figure activities
zoom off
rotate3d off
datacursormode off
plotedit off



 
handles.axes1 = subplot(2,2,1)
handles.axes2 = subplot(2,2,2)
handles.axes3 = subplot(2,2,3)

axes(handles.axes1)
handles.SliderFrame1 = uicontrol('Style','slider','Position',[382 453 130 20],'Min',1,'Max',sno_a,'Value',slice3,'SliderStep',[1/(sno_a-1) 10/(sno_a-1)],'Callback',@XSliderCallback); %% Set the Sliders

axes(handles.axes2)
handles.SliderFrame2 = uicontrol('Style','slider','Position',[1150 453 156 21],'Min',1,'Max',sno_s,'Value',slice2,'SliderStep',[1/(sno_s-1) 10/(sno_s-1)],'Callback',@XSliderCallback);

axes(handles.axes3)
handles.SliderFrame3 = uicontrol('Style','slider','Position',[400 44 160 22],'Min',1,'Max',sno_c,'Value',slice1,'SliderStep',[1/(sno_c-1) 10/(sno_c-1)],'Callback',@XSliderCallback);

handles.Text1 = uicontrol('Style','Text','Position',[760 803 60 30],'String','Current frame'); 
handles.Edit1 = uicontrol('Style','Edit','Position',[817 803 100 30],'String','1');




set (hFig, 'WindowScrollWheelFcn', @mouseScroll); %% Set the WindowScrollWheelFcn


guidata(hFig,handles);


function XSliderCallback(~,~)

     handles = guidata(gcf);

%// Here retrieve MyMatrix using getappdata.
      MyMatrix = getappdata(hFig, 'MyMatrix');

        idx = round((get(handles.SliderFrame1, 'Value'))); %% Get current Slider Value
        idx2 = round((get(handles.SliderFrame2, 'Value')));
        idx3 = round((get(handles.SliderFrame3, 'Value')));
         set(handles.Edit1,'String',num2str(idx));
       

            
set(handles.SliderFrame1,'Value',idx); %% Set the current value to Slider
set(handles.SliderFrame2,'Value',idx2);
set(handles.SliderFrame3,'Value',idx3);

set(handles.Edit1, 'String', sprintf('Slice# %d / %d',idx, idx));
          
           
                set(handles.Edit1, 'String', '2D image');
      
        
        subplot(2,2,1)
        image(handles.axes1, handles.im2(:,:,idx)) %% For the first row left panel show the original image
        imshow(squeeze(handles.im2(:,:,idx,:)))
      
        
        hold on
        p311=plot([0 sno_s/10],[slice1 slice1],'r', 'linewidth',2);
        p312=plot([sno_s*9/10 sno_s],[slice1 slice1],'r', 'linewidth',2);
        p321=plot([slice2 slice2],[0 sno_c/10],'g', 'linewidth',2);
        p322=plot([slice2 slice2],[sno_c*9/10 sno_c],'g', 'linewidth',2);
        hold off

         
       subplot(2,2,2)
       image(handles.axes2, handles.im3(:,:,idx2));
       imshow(squeeze(handles.im3(:,:,idx2,:)),'XData',[1 592], 'YData',[1 481])
     
       
       hold on
       p231=plot([0 sno_c/10],[slice3 slice3],'g', 'linewidth',2);
       p232=plot([sno_c*9/10 sno_c],[slice3 slice3],'g', 'linewidth',2);
       p211=plot([slice1 slice1],[0 sno_a/10],'g', 'linewidth',2);
       p212=plot([slice1 slice1],[sno_a*9/10 sno_a],'g', 'linewidth',2);
       hold off
       
       set(handles.axes2,'box', 'on', 'Visible', 'on', 'xtick', [], 'ytick', [],'XColor', [0,1,0], 'YColor', [0,1,0],'LineWidth',5.0)

       subplot(2,2,3)
       image(handles.axes3, handles.im4(:,:,idx3));
       imshow(squeeze(handles.im4(:,:,idx3,:)),'XData',[1 592], 'YData',[1 481])
      
       
       hold on
       p131=plot([0 sno_s/10],[slice3 slice3],'g', 'linewidth',2);
       p132=plot([sno_s*9/10 sno_s],[slice3 slice3],'g', 'linewidth',2);
       p121=plot([slice2 slice2],[0 sno_a/10],'g', 'linewidth',2);
       p122=plot([slice2 slice2],[sno_a*9/10 sno_a],'g', 'linewidth',2);
       hold off
       
       
       set(handles.axes3, 'box', 'on', 'Visible', 'on', 'xtick', [], 'ytick', [],'XColor', [1,0,0], 'YColor', [1,0,0],'LineWidth',5.0)
      
 
       guidata(hFig,handles);
       
        drawnow()
    end
    
    function btn_Callback(~,~)
        
        
[fileName, isCancelled] = imgetfile(); %% Get image file

im = DicomReader(fileName) %% Create a stack and make them 3D from 4D   
handles.im2 = makeImIsoRGB(im, [1,1,15], 2.0, 'cubic') %% Fill the anisotropy gaps with interp3


    end
        

  function mouseScroll(hObject,eventdata,I)


handles = guidata(hObject);

im2=handles.im2;i1=handles.i1;
im3=handles.im3;i2=handles.i2;
im4=handles.im4;i3=handles.i3;
S(1) = round((get(handles.SliderFrame1,'Value')));
S(2) = round((get(handles.SliderFrame2,'Value')));
S(3) = round((get(handles.SliderFrame3,'Value')));
UPDN = eventdata.VerticalScrollCount;
S=S-UPDN;
S=max([1 1 1],S);%ensure S is at least 1
S=min(size(im2),S);%ensure S is at most size(im2,___)

 if S(1) > get(handles.SliderFrame1,'Max')
       S(1) = get(handles.SliderFrame1,'Max');
elseif S(1) < get(handles.SliderFrame1,'Min')
    S(1) = get(handles.SliderFrame1,'Min');
 end
 
 set(handles.SliderFrame1,'Value',S(1));
set(handles.SliderFrame2,'Value',S(2));
set(handles.SliderFrame3,'Value',S(3));
set(handles.Edit1, 'String', sprintf('Slice# %d / %d',S(3), sno(3)));
set(i1,'cdata',squeeze(im2(:,:,S(1),:))); %%For Axes 1
set(i2,'cdata',squeeze(im3(:,:,S(2),:))); %%For Axes 2
set(i3,'cdata',squeeze(im4(:,:,S(3),:))); %%For Axes 3


end

function do_lines
    
        set(p131,'YData',[slice3 slice3]);
        set(p121,'XData',[slice2 slice2]);
        set(p132,'YData',[slice3 slice3]);
        set(p122,'XData',[slice2 slice2]);
        
        set(p231,'YData',[slice3 slice3]);
        set(p211,'XData',[slice1 slice1]);
        set(p232,'YData',[slice3 slice3]);
        set(p212,'XData',[slice1 slice1]);
        
        set(p311,'YData',[slice1 slice1]);
        set(p321,'XData',[slice2 slice2]);
        set(p312,'YData',[slice1 slice1]);
        set(p322,'XData',[slice2 slice2]);
end

end


