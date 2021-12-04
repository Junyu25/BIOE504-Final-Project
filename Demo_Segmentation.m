Image = Normalize_Phase;
[counts, ~] = imhist(Image, 128)
[MaskThreshold, EM] = otsuthresh(counts)

for i = 1:N
    for j = 1:N
        [countsAll(:, i, j), ~] = imhist(Image((floor(end / N) * (i - 1) + 1):(floor(end / N) * i), (floor(end / N) * (j - 1) + 1):(floor(end / N) * j)), 64);
        [ThresholdAll(i, j), EMAll(i, j)] = otsuthresh(countsAll(:, i, j));
    end
end
MaskThreshold = min(ThresholdAll(:));

%Mask AutoThreshold
Mask = (Image < MaskThreshold);
%Erode
Mask = imerode(imdilate(Mask, strel('disk', 5)), strel('disk', 2));

Image = adapthisteq(Image); %Contrast enhance
%ImageSegment(Normalize_Phase, 'sePattern', sePattern, 'AreaRange', AreaRange, 'Thereshold', Thereshold, 'Effectiveness', Effectiveness, 'N', N);


Ie = imerode(Image, sePattern);%Erode
Iobr = imreconstruct(Ie, Image);%Opening by reconstruction
Iobrd = imdilate(Iobr, sePattern);%Dilate
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);

L = watershed(Iobrcbr);

[counts, ~] = imhist(Image, 128);
ImageThreshold = otsuthresh(counts);

BW_Image = (Iobrcbr < ImageThreshold);
BW_Image = BW_Image > 0 & Mask > 0;
BW_Image = L > 0 & imclose(BW_Image, ones(3));
BW_Image = imopen(BW_Image, sePattern);
BW_Image = imfill(BW_Image, 'holes');
BW_Image = bwpropfilt(BW_Image > 0, 'Area', AreaRange);

imshow(BW_Image)
