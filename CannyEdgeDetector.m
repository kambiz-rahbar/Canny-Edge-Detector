clc
clear
close all


%% 1. get the image
I = imread ('cameraman.tif');
%I = imread ('019_1_2.jpg');

figure(1); imshow(I); title('original image');

% apply processing pre-conditions
if size(I,3)>1
    I = rgb2gray(I);
end
I = double(I);


%% 2. apply Gaussian and Gradient filters

% 2.1. gaussian filter coefficients
GaussFltCoeff = [2, 4,  5,  4,  2;
                 4, 9,  12, 9,  4;
                 5, 12, 15, 12, 5;
                 4, 9,  12, 9,  4;
                 2, 4,  5,  4,  2]/159;

% 2.2. gradient filter coefficients for horizontal and vertical directions
GradFltCoeff.X = [-1 0 1;
                  -2 0 2;
                  -1 0 1];

GradFltCoeff.Y = [1  2  1;
                  0  0  0;
                 -1 -2 -1];

% 2.3. apply filters and ignore marginal results
GaussFlt_I = conv2(I, GaussFltCoeff, 'same');
GradX_I = conv2(GaussFlt_I, GradFltCoeff.X, 'same');
GradY_I = conv2(GaussFlt_I, GradFltCoeff.Y, 'same');

% 2.4. show the results
figure(2); imshow(uint8(GaussFlt_I)); title('Gaussian Flt');
figure(3);
subplot(1,2,1); imshow(GradX_I); title('GradX Flt');
subplot(1,2,2); imshow(GradY_I); title('GradX Flt');


%% 3. calculate direction of edges

% 3.1. calculate four-quadrant inverse tangent
% The four-quadrant inverse tangent, atan2(Y,X), returns values in the
% closed interval [-pi,pi] based on the values of Y and X as shown in the
% graphic. % In contrast, atan(Y/X) returns results that are limited to
% the interval [-pi/2,pi/2], shown on the right side of the diagram.
edgeDirection = atan2(GradY_I, GradX_I)*180/pi;

% 3.2. set negative edge directions positive
edgeDirection(edgeDirection < 0) = edgeDirection(edgeDirection < 0) + 360;

% 3.3. quantize edge directions into 0, 45, 90 and 135 degrees
edgeDirection(edgeDirection >= 0 & edgeDirection < 22.5) = 0;
edgeDirection(edgeDirection >= 22.5 & edgeDirection < 67.5) = 45;
edgeDirection(edgeDirection >= 67.5 & edgeDirection < 112.5) = 90;
edgeDirection(edgeDirection >= 112.5 & edgeDirection < 157.5) = 135;
edgeDirection(edgeDirection >= 157.5 & edgeDirection < 202.5) = 0;
edgeDirection(edgeDirection >= 202.5 & edgeDirection < 247.5) = 45;
edgeDirection(edgeDirection >= 247.5 & edgeDirection < 292.5) = 90;
edgeDirection(edgeDirection >= 292.5 & edgeDirection < 337.5) = 135;
edgeDirection(edgeDirection >= 337.5 & edgeDirection <= 360) = 0;

% 3.4. show the results
figure(4); imagesc(edgeDirection); title('edge direction'); colorbar


%% 4. calculate edges in each direction (0 degree, 45 degree, 90 degree and 135 degree)
edgeMagnitude = sqrt(GradX_I.^2 + GradY_I.^2);

figure(5); imagesc(edgeMagnitude); title('edge magnitude'); colorbar


%% 5. integrate edges of each directions

% 5.1. prepare pre-computation matrices
edgeMagnitudeU = shiftmatrix(edgeMagnitude,[-1,0]);
edgeMagnitudeD = shiftmatrix(edgeMagnitude,[1,0]);
edgeMagnitudeR = shiftmatrix(edgeMagnitude,[0,1]);
edgeMagnitudeL = shiftmatrix(edgeMagnitude,[0,-1]);
edgeMagnitudeUR = shiftmatrix(edgeMagnitudeU,[0,1]);
edgeMagnitudeUL = shiftmatrix(edgeMagnitudeU,[0,-1]);
edgeMagnitudeDR = shiftmatrix(edgeMagnitudeD,[0,1]);
edgeMagnitudeDL = shiftmatrix(edgeMagnitudeD,[0,-1]);

edgeMagnitude0(:,:,1) = edgeMagnitudeR;
edgeMagnitude0(:,:,2) = edgeMagnitude;
edgeMagnitude0(:,:,3) = edgeMagnitudeL;

edgeMagnitude45(:,:,1) = edgeMagnitudeDL;
edgeMagnitude45(:,:,2) = edgeMagnitude;
edgeMagnitude45(:,:,3) = edgeMagnitudeUR;

edgeMagnitude90(:,:,1) = edgeMagnitudeD;
edgeMagnitude90(:,:,2) = edgeMagnitude;
edgeMagnitude90(:,:,3) = edgeMagnitudeU;

edgeMagnitude135(:,:,1) = edgeMagnitudeDR;
edgeMagnitude135(:,:,2) = edgeMagnitude;
edgeMagnitude135(:,:,3) = edgeMagnitudeUL;

% 5.2. find edges along each direction
edge90 = edgeMagnitude .* (edgeMagnitude == max(edgeMagnitude0,[],3));
edge135 = edgeMagnitude .* (edgeMagnitude == max(edgeMagnitude45,[],3));
edge0 = edgeMagnitude .* (edgeMagnitude == max(edgeMagnitude90,[],3));
edge45 = edgeMagnitude .* (edgeMagnitude == max(edgeMagnitude135,[],3));

% 5.3. show the results
figure(6);
subplot(2,2,1); imagesc(edge0); title('edge Magnitude 0');
subplot(2,2,2); imagesc(edge45); title('edge Magnitude 45');
subplot(2,2,3); imagesc(edge90); title('edge Magnitude 90');
subplot(2,2,4); imagesc(edge135); title('edge Magnitude 135');


%% 6. integrate edges of each directions
edge_I = edge0 + edge45 + edge90 + edge135;

figure(7); imagesc(edge_I); title('edge of image');


%% 7. mark strong edges and make a binary result

% 7.1. set the low and high thresholds
% for cameraman
Threshold_Low = 0.7*(std(edge_I(:)) - mean(edge_I(:)));
Threshold_High = 2*(std(edge_I(:)) + mean(edge_I(:)));

% for iris
%Threshold_Low = 0.07*(std(edge_I(:)) - mean(edge_I(:)));
%Threshold_High = 0.2*(std(edge_I(:)) + mean(edge_I(:)));

% 7.2. extract final edges
binEdge_I = ones(size(edge_I));
binEdge_I(edge_I <= Threshold_Low) = 1;
binEdge_I(edge_I > Threshold_Low & edge_I < Threshold_High & max(neighbors(edge_I),[],3) >= Threshold_High) = 0;
binEdge_I(edge_I >= Threshold_High) = 0;

% 7.3. show the results
figure(8); imshow(binEdge_I); title('binary edge of image');


%% EOF