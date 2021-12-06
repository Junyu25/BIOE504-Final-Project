clear
clc

addpath(genpath(pwd))

%% Load the data
Type = '.nd2';

NameAll = ls(['.\ImageAnalysis\Demo', filesep, '*', Type]);
FileName = ['.\ImageAnalysis\Demo', filesep, NameAll(1, :)];
[Path, ~, ~] = fileparts(FileName);

%% iterate for 8 demo images
for i = 1:8
    % FileName=[PathAll,filesep,NameAll(i,:)];
    % [Path,Name,~]=fileparts(FileName);
    if i == 1
        ImageInfo = ND2Info([Path, filesep, num2str(i), Type]);
        %
        ScaleX = ImageInfo.metadata.channels(1).volume.axesCalibration(1);
        ScaleY = ImageInfo.metadata.channels(1).volume.axesCalibration(2);
        ScaleZ = ImageInfo.metadata.channels(1).volume.axesCalibration(3);
        %
        if ScaleX == ScaleY
            ImageScale(i) = ScaleX;
        else
            warning('Scale not fit in X and Y')
        end

    else
    end

    Image = ND2ReadSingle([Path, filesep, num2str(i), Type]);
    %Split to four images
    FITCImage(:, :, i) = Image{1}; %FITC channel
    TRITCImage(:, :, i) = Image{2}; %TRITC channel
    CY5Image(:, :, i) = Image{3}; %Cy5 channel
    PhaseImage(:, :, i) = Image{4}; %TD channel
end

%% Multiple Image Alignment

[PhaseImageShift, FITCImageShift, TRITCImageShift, CY5ImageShift] = Alignment(PhaseImage, FITCImage, TRITCImage, CY5Image);

PhaseImageMean = mean(PhaseImageShift(:, :, :), 3);
AdaptBG = adaptthresh(mat2gray(PhaseImageMean), 0.5, 'ForegroundPolarity', 'dark');
Normalize_Phase = mat2gray(double(PhaseImageMean) ./ AdaptBG);

imshow(mat2gray(Normalize_Phase))

%% Image segementation

sePattern = strel('disk', 1);
AreaRange = [10, 1000];
Thereshold = 'Auto';
Effectiveness = 0.65;
N = 12;

[BW_Image_Segment] = ImageSegment(Normalize_Phase, 'sePattern', sePattern, 'AreaRange', AreaRange, 'Thereshold', Thereshold, 'Effectiveness', Effectiveness, 'N', N);
% [BW_Image_Filtered,~] = PhaseCheck(BW_Image_Segment,Normalize_Phase);

[~, Labels] = bwboundaries(BW_Image_Segment, 'noholes');
TestImage = labeloverlay(mat2gray(PhaseImageShift(:, :, 1)), Labels, 'Transparency', 0.75);

imshow(TestImage)

%% Strain Identification

CodexRes = ColorIdentify(BW_Image_Segment, FITCImageShift, TRITCImageShift, CY5ImageShift, 1:8);

% % StrainCode
StrainCode(:, 1) = [3, 3, 2, 3, 3, 3, 3, 3];
StrainCode(:, 2) = [1, 2, 1, 2, 1, 1, 3, 3];
StrainCode(:, 3) = [1, 2, 3, 1, 1, 3, 3, 1];
StrainCode(:, 4) = [2, 1, 1, 2, 1, 2, 2, 2];
StrainCode(:, 5) = [1, 2, 2, 1, 2, 1, 2, 1];
StrainCode(:, 6) = [2, 2, 2, 2, 2, 2, 2, 2];
StrainCode(:, 7) = [2, 3, 2, 3, 2, 3, 1, 1];
StrainCode(:, 8) = [3, 1, 3, 1, 1, 3, 2, 2];
StrainCode(:, 9) = [1, 3, 1, 3, 1, 3, 2, 1];
StrainCode(:, 10) = [2, 1, 2, 1, 1, 2, 2, 1];
StrainCode(:, 11) = [3, 3, 3, 2, 2, 2, 2, 1];
StrainCode(:, 12) = [1, 2, 3, 3, 2, 2, 3, 2];

[StrainLikehood, Decode] = StrainIdentify(StrainCode, CodexRes, 2);

%% Image Output

[StrainImageAll, ~] = LabelImage(BW_Image_Segment, Decode);

StrainColors = ColorGenerator(max(Decode(:, 1)));
StrainColors(max(Decode(:, 1))+1,:)=[0.5,0.5,0.5];
StrainColors(max(Decode(:, 1))+2,:)=[0.1,0.1,0.1];

%Lable on ori image
%LabeledImage = labeloverlay(mat2gray(mean(PhaseImageShift(:, :, 1), 3)), StrainImageAll, 'ColorMap', StrainColors, 'Transparency', 0.25);
%Lable on segmented image
LabeledImage = labeloverlay(mat2gray(BW_Image_Segment), StrainImageAll, 'ColorMap', StrainColors, 'Transparency', 0.25);

figure
imshow(LabeledImage)

for i = 1:12
    SingleStrainColor = StrainColors(i,:);
    InitColors = ones(12,3);
    InitColors(i,:) = SingleStrainColor;
    InitColors(13,:) = StrainColors(13,:);
    InitColors(14,:) = StrainColors(14,:);
    SingleStrainColor
    SingleStrainLabeledImage = labeloverlay(mat2gray(zeros(5066,5037)), StrainImageAll, 'ColorMap', InitColors, 'Transparency', 0.25);
    imwrite(SingleStrainLabeledImage(145:645,130:630,:), sprintf('SingleStrainLabeledImage_%d.png',i));
    %figure
    %imshow(SingleStrainLabeledImage(145:645,130:630,:))
    %savefig(labeloverlay(mat2gray(BW_Image_Segment), StrainImageAll, 'ColorMap', InitColors, 'Transparency', 0.25), sprintf('SingleStrainLabeledImage_%d.fig',i));
end

%code book to strain name!!!
InitColors = ones(12,3);
InitColors(13,:) = StrainColors(13,:);
InitColors(14,:) = StrainColors(14,:);

imshow(mat2gray(zeros(5066,5037)))
%Alignment_small=BW_Image_Segment(145:645,130:630);
%Alignment_large=BW_Image_Segment(1:801,1:801);

Final_image_small=LabeledImage(145:645,130:630,:);
figure
imshow(Final_image_small)
imwrite(LabeledImage(145:645,130:630,:), 'demo_image.png');

%% Display fluorescence images

% CY5
imageCY5 = zeros(5066,5037,3);
imageCY5(:,:,1) = mat2gray(CY5ImageShift(:,:,1))*194/255;
imageCY5(:,:,2) = mat2gray(CY5ImageShift(:,:,1))*24/255;
imageCY5(:,:,3) = mat2gray(CY5ImageShift(:,:,1))*194/255;
imshow(imageCY5);
% FITC 
imageFITC = zeros(5066,5037,3);
imageFITC(:,:,1) = mat2gray(FITCImageShift(:,:,1))*41/255;
imageFITC(:,:,2) = mat2gray(FITCImageShift(:,:,1))*179/255;
imageFITC(:,:,3) = mat2gray(FITCImageShift(:,:,1))*84/255;
imshow(imageFITC);

% TRITC 
imageTRITC = zeros(5066,5037,3);
imageTRITC(:,:,1) = mat2gray(TRITCImageShift(:,:,1))*239/255;
imageTRITC(:,:,2) = mat2gray(TRITCImageShift(:,:,1))*101/255;
imageTRITC(:,:,3) = mat2gray(TRITCImageShift(:,:,1))*45/255;
imshow(imageTRITC);
