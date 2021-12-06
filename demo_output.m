%Channel
imshow(PhaseImage(:,:,1))

%Allignment
%Shift
imshow(PhaseImageShift(1,1))

%Segment output image
Alignment_small=BW_Image_Segment(145:645,130:630);
Alignment_large=BW_Image_Segment(1:801,1:801);

imshow(Alignment_small)

imshow(CY5ImageShift(145:645,130:630,1))
imshow(FITCImageShift(145:645,130:630,1))
imshow(TRITCImageShift(145:645,130:630,1))


imshow(CY5ImageShift(145:645,130:630,2))