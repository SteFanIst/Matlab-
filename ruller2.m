message = ({'Welcome to my Automated Calibration and Segmentation Toolbox';'I hope you Enjoy it' ; 'Please, share' ; 'Cheers!'});
myicon = imread('maer.jpg');
waitfor(msgbox(message,'ACST','custom',myicon));

global Image2

clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;


Image = imread('A6_(14.9N).bmp');

Image2 = rgb2gray(Image);

%% To remove top color bar
m = 1;
while(sum(Image(m,:)))
    m = m+1;
end
Image2 = Image2(m:end,:);

%% To detect ruller dashes:

n = size(Image2,2)
while(sum(Image2(:,n))==0)    
    n = n-1;
end
Ruller = find(sum(Image2(:,n-4:n),2));

FirstDash = [Ruller(1)+m-1,n]   % The top dash location
LastDash = [Ruller(end)+m-1,n]  % The bottom dash location

global lastDrawnHandle
global calibration


% Ask the user for the real-world distance.
userPrompt = {'Enter real world units (e.g. mm/cm):','Enter distance in those units:'};
dialogTitle = 'Specify calibration information';
numberOfLines = 1;
def = {'mm', '40'};
answer = inputdlg(userPrompt, dialogTitle, numberOfLines, def);
if isempty(answer)
	return;
end



y1 = FirstDash(1)
y2 = LastDash(1)
x1 = FirstDash(2)
x2 = LastDash(2)

distanceInPixels = sqrt((x2-x1).^2 + (y2-y1).^2);


imshow(Image)
% Plot the line.
hold on;
lastDrawnHandle = plot([x1,x2],[y1,y2], 'y-', 'LineWidth', 2);


calibration.units = answer{1};
calibration.distanceInPixels = distanceInPixels;
calibration.distanceInUnits = str2double(answer{2});
calibration.distancePerPixel = calibration.distanceInUnits / distanceInPixels;
distanceInRealUnits = distanceInPixels * calibration.distancePerPixel;

	% Inform use via a dialog box.
	txtInfo = sprintf('Distance = %.1f %s, which = %.1f pixels.', ...
		distanceInRealUnits, calibration.units, distanceInPixels);
	msgbox(txtInfo);
	% Print the values out to the command window.
	fprintf(1, '%\n', txtInfo);
    
    pause(3)
    
 reply = questdlg('Is calibration correct?', 'Yes', 'No');  
  
  if strcmpi(reply, 'No')
      waitfor(msgbox('We will do manually calibration then!'));
      Drawline()
  else
end
  
  
userPrompt = {'Enter standoff thickness in mm:'};
dialogTitle = 'Specify standoff thickness';
numberOfLines = 1;
def = {'10'};
answer = inputdlg(userPrompt, dialogTitle, numberOfLines, def);
if isempty(answer)
	return;
end

iwant = cellfun(@str2num,answer)
q = 0.5*iwant;
conv = q*11.8;
  
binaryImage = bwareafilt(Image2 > 0, 1);
props = regionprops(binaryImage, 'BoundingBox');
bb = props.BoundingBox;
bb(end) = 180;% Whatever height you want.
croppedImage = imcrop(Image2,bb);

[height width dims] = size(croppedImage);
J = imcrop(croppedImage,[0 floor(height*0.17) width height-floor(height*0.17)]);
figure(1)

subplot(2,2,1:2)
imshow(Image2)
subplot(2,2,3); imshow(croppedImage)
subplot(2,2,4); imshow(J)

[height width dims] = size(croppedImage);
rowsx = floor(height*0.17) 
convert = rowsx*0.087



reply2 = questdlg('Do you want to automatic segmented?', 'Yes', 'No');



S.bg = uibuttongroup(gcf,'Visible','off',...
                  'Position',[0 0 .2 1]);
              
S.r(1) = uicontrol(S.bg,'Style',...
                  'radiobutton',...
                  'String','Option 1',...
                  'Position',[10 350 100 30]);
              
S.r(2) = uicontrol(S.bg,'Style','radiobutton',...
                  'String','Option 2',...
                  'Position',[10 250 100 30]);
                     

            
              
              % Make the uibuttongroup visible after creating child objects. 
S.bg.Visible = 'on';



if strcmpi(reply2, 'Yes')
      uiwait(msgbox('We will do automated segmentation then!'));
      
      us = {'X1:','X2:', 'Y1:', 'Y2'};
     
      
      numberOfLines = 1;
      dialogTitle = 'Specify contour dimensions for Chan Vese';
      def = {'30', '110', '2', '445'};
      
      U = inputdlg(us,dialogTitle,numberOfLines,def); 
      
      i = cellfun(@str2num,U);
     r = real(i);
     

    
handles.axes1 = subplot(2,2,3)
handles.axes2 = subplot(2,2,4)

 
switch findobj(get(S.bg,'selectedobject'))
    case S.r(1)
        Img = getimage(handles.axes1)
    case S.r(2)
        Img = getimage(handles.axes2)
    otherwise
        set(S.ed,'string','None!') % Very unlikely I think.
end
 
 Img = double(Img); 
      
 thr1 = 100


% find values below
ind_below = (Img < thr1);
% find values above
ind_above = (Img >= thr1);
% set values below to black
Img(ind_below) = 0;
% set values above to white
Img(ind_above) = 255;

I = Img;
m = zeros(size(I,1),size(I,2));  

m(i(1,1):i(2,1),i(3,1):i(4,1)) = 1;

I = imresize(I,.5);  %-- make image smaller 
m = imresize(m,.5);  %     for fast computation

subplot(2,2,1); imshow(I); title('Input Image');
subplot(2,2,2); imshow(m); title('Initialization');
subplot(2,2,3); title('Segmentation');

figure

seg = region_seg(I, m, 2000); %-- Run segmentation

subplot(2,2,4); imshow(seg); title('Global Region-Based Segmentation');



else
    return
end
 
  function Drawline()
  try
   
      global calibration
      global distancePerPixel
   
      
    instructions = sprintf('Draw a line.\nFirst, left-click to get the first pixel coordinates \n and second double-click to get the second pixel coordinates and the distance among the pixels');
	title(instructions);
	waitfor(msgbox(instructions));
    fontSize = 14;
		
    [cx,cy, rgbValues, xi,yi] = improfile(1000);
	% Get the profile again but spaced at the number of pixels instead of 1000 samples.
    lastDrawnHandle = plot(xi, yi, 'y-', 'LineWidth', 2);
	hImage = findobj(gca,'Type','image');
	theImage = get(hImage, 'CData');
	lineLength = round(sqrt((xi(1)-xi(2))^2 + (yi(1)-yi(2))^2))
	[cx,cy, rgbValues] = improfile(theImage, xi, yi, lineLength);
	
	% rgbValues is 1000x1x3.  Call Squeeze to get rid of the singleton dimension and make it 1000x3.
	rgbValues = squeeze(rgbValues);
	distanceInPixels = sqrt( (xi(2)-xi(1)).^2 + (yi(2)-yi(1)).^2);
	distanceInRealUnits = distanceInPixels * calibration.distancePerPixel;
	
	if length(xi) < 2
		return;
	end
	% Plot the line.
	hold on;
	lastDrawnHandle = plot(xi, yi, 'y-', 'LineWidth', 2);
	
	% Plot profiles along the line of the red, green, and blue components.
	subplot(1,2,2);
	[rows, columns] = size(rgbValues);
	if columns == 3
		% It's an RGB image.
		plot(rgbValues(:, 1), 'r-', 'LineWidth', 2);
		hold on;
		plot(rgbValues(:, 2), 'g-', 'LineWidth', 2);
		plot(rgbValues(:, 3), 'b-', 'LineWidth', 2);
		title('Red, Green, and Blue Profiles along the line you just drew.', 'FontSize', 14);
	else
		% It's a gray scale image.
		plot(rgbValues, 'k-', 'LineWidth', 2);
	end
	xlabel('X', 'FontSize', fontSize);
	ylabel('Gray Level', 'FontSize', fontSize);
	title('Intensity Profile', 'FontSize', fontSize);
	grid on;
	
	% Inform use via a dialog box.
	txtInfo = sprintf('Distance = %.1f %s, which = %.1f pixels.', ...
		distanceInRealUnits, calibration.units, distanceInPixels);
	waitfor(msgbox(txtInfo));
	% Print the values out to the command window.
	fprintf(1, '%\n', txtInfo);
	
catch ME
	errorMessage = sprintf('Error in function DrawLine().\n\nError Message:\n%s', ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
    
  end
  end
  

