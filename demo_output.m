%Channel
imshow(PhaseImage(:,:,1))

%Allignment
imshow(mat2gray(PhaseImage(145:645,130:630, 1)));
imshow(mat2gray(PhaseImage(1:801,1:801, 2)));

%Shift
imshow(PhaseImageShift(1,1))

%Segment output image
Alignment_small=BW_Image_Segment(145:645,130:630);
Alignment_large=BW_Image_Segment(1:801,1:801);

imshow(Alignment_small)


%% Display fluorescence images in RGB
imshow(mat2gray(CY5ImageShift(145:645,130:630,1)));
CY5ImageShift_color = mat2gray(CY5ImageShift(145:645,130:630,1));
%rgbImage = ind2rgb(CY5ImageShift_color, [0.12, 0.56, 0.1]);


imshow(FITCImageShift(145:645,130:630,1))
imshow(TRITCImageShift(145:645,130:630,1))
imshow(CY5ImageShift(145:645,130:630,2))

imageRed = uint8(zeros(501, 501,3));
imageRed(:, :,1) = CY5ImageShift(145:645,130:630,1);
imshow(imageRed);

imageRed = uint8(zeros(501, 501, 3));
imageRed(:, :,1) = CY5ImageShift(145:645,130:630,1);
imshow(imageRed);

imageGreen = uint8(zeros(501, 501, 3));
imageGreen(:, :,2) = CY5ImageShift(145:645,130:630,1);
imshow(imageGreen)

imageBlue = uint8(zeros(501, 501, 3));
imageBlue(:, :,3) = CY5ImageShift(145:645,130:630,1);
imshow(imageBlue)


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

%Dye color
imageCY5 = zeros(501, 501, 3);
imageCY5(:,:,1) = mat2gray(CY5ImageShift(145:645,130:630,1))*194/255;
imageCY5(:,:,2) = mat2gray(CY5ImageShift(145:645,130:630,1))*24/255;
imageCY5(:,:,3) = mat2gray(CY5ImageShift(145:645,130:630,1))*194/255;
imshow(imageCY5);

%for loop generate 1 strain sample
%Select PD1 StrainCode(:, 2)
strain = 12;
for i = 1:8
    imageInit = zeros(501, 501, 3);
    if StrainCode(i, strain) == 1
        imageInit(:,:,1) = mat2gray(CY5ImageShift(145:645,130:630,1))*194/255;
        imageInit(:,:,2) = mat2gray(CY5ImageShift(145:645,130:630,1))*24/255;
        imageInit(:,:,3) = mat2gray(CY5ImageShift(145:645,130:630,1))*194/255;
    end
    if StrainCode(i, strain) == 2
        imageInit(:,:,1) = mat2gray(CY5ImageShift(145:645,130:630,1))*41/255;
        imageInit(:,:,2) = mat2gray(CY5ImageShift(145:645,130:630,1))*179/255;
        imageInit(:,:,3) = mat2gray(CY5ImageShift(145:645,130:630,1))*84/255;
    end
    if StrainCode(i, strain) == 3
        imageInit(:,:,1) = mat2gray(CY5ImageShift(145:645,130:630,1))*239/255;
        imageInit(:,:,2) = mat2gray(CY5ImageShift(145:645,130:630,1))*101/255;
        imageInit(:,:,3) = mat2gray(CY5ImageShift(145:645,130:630,1))*45/255;
    end
    %imageInit(:, :,StrainCode(i, 2)) = CY5ImageShift(145:645,130:630,i);
    imshow(imageInit)
    imwrite(imageInit, sprintf('SingleStrain_%d_Round_%d.png',strain,i));
end

imshow(CY5ImageShift(145:645,130:630,1))



%% Labled final image
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

% Add scale bar
[ImageWithBar, BarLength] = AddScaleBar(Final_image_small, ImageScale);
imshow(ImageWithBar)

% How to add Legend?
legend([b1 b2],'Bar Chart 1','Bar Chart 2')

