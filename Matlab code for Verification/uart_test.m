clc;
close all;
clear all;

% 0587   -- wrong inference
% test_data_0002

fid = fopen('test_data_0050.txt', 'r');  % Open the text file in read mode

data = textscan(fid, '%s', 784, 'Delimiter', '\n');
fclose(fid);  % Close the file
 
numDataPoints = 784;  % Number of rows
data = data{1};  % Extract the data from the cell array
 
% Convert each row to 16-bit unsigned integers
data = cellfun(@(x) uint16(bin2dec(x)), data, 'UniformOutput', false);
data = cell2mat(data);
 
% Reshape the data into a matrix with 784 rows
data = reshape(data, numDataPoints, []);
binaryData = dec2bin(data, 16);
 
 
% Convert each element to upper and lower bytes
upperByte = uint8(bitshift(bitand(data, 65280), -8));  % Extract the upper 8 bits
lowerByte = uint8(bitand(data, 255));  % Extract the lower 8 bits
 
splitData = [lowerByte, upperByte];
finalArray = reshape(splitData.', [], 1);

% port = serialport("COM14", 9600, 'DataBits', 8, 'Parity', 'none', 'StopBits', 1);
binaryData1 = bin2dec(binaryData);
uint8Data = uint8(finalArray);
% Reshape the finalArray into a 28x28 matrix
imageData = reshape(data, 28, 28);

% Rotate the image by 90 degrees
rotatedImage = imrotate(imageData, 90);

% Mirror the rotated image
mirroredImage = flipud(rotatedImage);

% Resize the image to a larger size
enlarged_image = imresize(mirroredImage, [1000, 1000]);

% Display the enlarged image
imshow(enlarged_image);

% 
% 
write(port, uint8Data, "uint8");


i = 0;
while true
    fprintf("--%d--", i);
    data2 = read(port, 1, "uint8");
    disp(data2);

    i = i + 1;
    if i == 1568
        break;
    end
end

% fclose(port);
delete(port);
