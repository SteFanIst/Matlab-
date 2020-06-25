clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 16;
%===============================================================================
% Get the name of the image the user wants to use.
baseFileName = 'A1b.jpg';
folder = pwd;
fullFileName = fullfile(folder, baseFileName);
% Check if file exists.
if ~exist(fullFileName, 'file')
	% The file doesn't exist -- didn't find it there in that folder.
	% Check the entire search path (other folders) for the file by stripping off the folder.
	fullFileNameOnSearchPath = baseFileName; % No path this time.
	if ~exist(fullFileNameOnSearchPath, 'file')
		% Still didn't find it.  Alert user.
		errorMessage = sprintf('Error: %s does not exist in the search path folders.', fullFileName);
		uiwait(warndlg(errorMessage));
		return;
	end
end
%=======================================================================================
% Read in demo image.
rgbImage = imread(fullFileName);
% Get the dimensions of the image.
[rows, columns, numberOfColorChannels] = size(rgbImage)
% Display image.
subplot(2, 3, 1);
imshow(rgbImage, []);
impixelinfo;
axis on;
caption = sprintf('Original Color Image\n%s', baseFileName);
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
hp = impixelinfo(); % Set up status line to see values when you mouse over the image.
% Set up figure properties:
% Enlarge figure to full screen.
set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0.05 1 0.95]);
% Get rid of tool bar and pulldown menus that are along top of figure.
% set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% Give a name to the title bar.
set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')
drawnow;
%===================================================================================
% FIND THE RED MASK
% Extract the individual red, green, and blue color channels.
redChannel = rgbImage(:, :, 1);
greenChannel = rgbImage(:, :, 2);
blueChannel = rgbImage(:, :, 3);
% get a mask for the red line.
mask = redChannel > greenChannel;
% Display the image.
subplot(2, 3, 2);
imshow(mask);
caption = sprintf('Color Segmentation Mask Image');
title(caption, 'FontSize', fontSize, 'Interpreter', 'None');
impixelinfo;
axis('on', 'image');
drawnow;
% fill holes.

% Take the largest blob only.

% Shrink two layers of pixels to come inside the red lines.

% Display the image.
subplot(2, 3, 3);
imshow(mask);
title('Final Mask', 'FontSize', fontSize, 'Interpreter', 'None');
impixelinfo;
axis('on', 'image');
% Get a masked image.
% Mask the image using bsxfun() function to multiply the mask by each channel individually.
maskedRgbImage = bsxfun(@times, rgbImage, cast(mask, 'like', rgbImage));
% Display the image.
subplot(2, 3, 4);
imshow(maskedRgbImage);
title('Masked RGB Image', 'FontSize', fontSize, 'Interpreter', 'None');
impixelinfo;
axis('on', 'image');
% A = contour(mask,'b');
set(gca,'ydir','reverse')
conversion = 1.09; % in mm/pixel
addMM = @(x) sprintf('%.3fmm', x*0.1*conversion);
addMMy=@(y) sprintf('%.3fmm',y*0.1*conversion);
xticklabels(cellfun(addMM, num2cell(xticks'), 'UniformOutput', false));
yticklabels(cellfun(addMM, num2cell(yticks'), 'UniformOutput', false));

%===================================================================================
% FIND THE HEIGHT OF THE MASK, AND SUM OF GRAY LEVELS FROM ROW 1 TO RED ROW.
topRow = 122; % Whatever you want.
grayLevelSum = zeros(1, columns); % Initialize sums for every column.
heights = zeros(1, columns); % Initialize heights for every column.
% Find the left and right column of the mask so we know where to sum over.
[rows, columns] = find(mask);
col1 = min(columns);
col2 = max(columns);

for col = col1 : col2
    row2 = find(mask(:,col), 1,'last'); % Get bottom row of mask
    if ~isempty(row2)
        % Get the sum in the GREEN channel, from row1 to row2.
        grayLevelSum(col)  = sum(greenChannel(topRow:row2, col));
		% Compute the height of the mask at every column.
		heights(col) = sum(maskedRgbImage(topRow:row2, col));
    end
end

figure
% Plot integrated gray level.
plot(grayLevelSum, 'b-', 'LineWidth', 2);
xlabel('Column', 'FontSize', 20);
ylabel('Sum of gray levels in column', 'FontSize', 20);
title('Sum of gray levels in column', 'FontSize', 20);
grid on;

conversion=1.09; % in mm/pixel
addMM=@(x) sprintf('%.3fmm',x*0.1*conversion);
addMMy=@(y) sprintf('%.3fmm',y*0.1*conversion);

xticklabels(cellfun(addMM,num2cell(xticks'),'UniformOutput',false));
yticklabels(cellfun(addMMy,num2cell(yticks'),'UniformOutput',false));

figure
% Plot heights
plot(heights, 'b-', 'LineWidth', 2);
xlabel('Column', 'FontSize', 20);
ylabel('Height of standoff in column', 'FontSize', 20);
title('Standoff Height vs. Column', 'FontSize', 20);
grid on;

conversion=1.09; % in mm/pixel
addMM=@(x) sprintf('%.3fmm',x*0.1*conversion);
addMMy=@(y) sprintf('%.3fmm',y*0.1*conversion);

xticklabels(cellfun(addMM,num2cell(xticks'),'UniformOutput',false));
yticklabels(cellfun(addMMy,num2cell(yticks'),'UniformOutput',false));

open('A2.fig');
a = get(gca,'Children');
xdata = get(a, 'XData');
ydata = get(a, 'YData');
zdata = get(a, 'ZData');

diff = heights - ydata

figure
plot(diff)

conversion=1.09; % in mm/pixel
addMM=@(x) sprintf('%.3fmm',x*0.1*conversion);
addMMy=@(y) sprintf('%.3fmm',y*0.1*conversion);

xticklabels(cellfun(addMM,num2cell(xticks'),'UniformOutput',false));
yticklabels(cellfun(addMMy,num2cell(yticks'),'UniformOutput',false));

% Tell user the answer.
message = sprintf('Done!');
uiwait(helpdlg(message));

data = [heights(:)];
sheet = 1;
range = 'B';
xlswrite('YourFile.xls', data, sheet, range)
