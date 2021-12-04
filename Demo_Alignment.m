%[PhaseImageShift, FITCImageShift, TRITCImageShift, CY5ImageShift] = Alignment(PhaseImage, FITCImage, TRITCImage, CY5Image);
%function [PhaseImageShift, varargout] = Alignment(PhaseImage, varargin)
    if isempty(varargin)
        ImageOutNum = 0;
    else
        ImageOutNum = size(varargin, 2);
    end

    SectionSize = 250;
    CorrectionSize = 400;
    % Calcualte Shift distance
    %function [DistanceX, DistanceY] = ShiftCal(PhaseImage, SectionSize, CorrectionSize)

    [Hight, Width, Num] = size(PhaseImage);
    DistanceX = [];
    DistanceY = [];

    for i = 1:Num
        Image1 = double(PhaseImage(:, :, max([1, i - 1])));
        Image2 = double(PhaseImage(:, :, i));
        %Normalize with mean
        Image1 = Image1 - mean(mean(Image1));
        Image2 = Image2 - mean(mean(Image2));
        SectionImage1 = Image1(floor(Hight / 2) - SectionSize:floor(Hight / 2) + SectionSize, floor(Width / 2) - SectionSize:floor(Width / 2) + SectionSize);
        SectionImage2 = Image2(floor(Hight / 2) - CorrectionSize:floor(Hight / 2) + CorrectionSize, floor(Width / 2) - CorrectionSize:floor(Width / 2) + CorrectionSize);
        % Calculate the crosscorrelation of two Images
        CrossCorr = xcorr2(SectionImage2, SectionImage1);
        [~, Location] = max(CrossCorr(:));
        %MaxCrossCorr(i) = max(CrossCorr(:));
        [YY, XX] = ind2sub(size(CrossCorr), Location);

        if i == 1
            DistanceY(i) = YY - SectionSize - CorrectionSize - 1;
            DistanceX(i) = XX - SectionSize - CorrectionSize - 1;
        else
            DistanceY(i) = YY - SectionSize - CorrectionSize - 1 + DistanceY(i - 1);
            DistanceX(i) = XX - SectionSize - CorrectionSize - 1 + DistanceX(i - 1);
        end

        DisplayBar(i, Num);
    end

    %[DistanceX, DistanceY] = ShiftCal(PhaseImage, SectionSize, CorrectionSize);

    if ImageOutNum > 0

        for outnum = 1:ImageOutNum
            varargout{outnum} = [];
        end

    else
    end

    Ymin = max(-min(DistanceY(:)) + 1, 1);
    Ymax = min(size(PhaseImage, 1) - max(DistanceY(:)), size(PhaseImage, 1));

    Xmin = max(-min(DistanceX(:)) + 1, 1);
    Xmax = min(size(PhaseImage, 2) - max(DistanceX(:)), size(PhaseImage, 2));

    for k = 1:size(PhaseImage, 3)
        % Crop out shifted phase images
        PhaseImageShift(:, :, k) = PhaseImage(Ymin + DistanceY(k):Ymax + DistanceY(k), Xmin + DistanceX(k):Xmax + DistanceX(k), k);

        if ImageOutNum > 0

            for outnum = 1:ImageOutNum
                varargout{outnum}(:, :, k) = varargin{outnum}(Ymin + DistanceY(k):Ymax + DistanceY(k), Xmin + DistanceX(k):Xmax + DistanceX(k), k);
            end

        else
        end

    end

%%
PhaseImageMean = mean(PhaseImageShift(:, :, :), 3);
AdaptBG = adaptthresh(mat2gray(PhaseImageMean), 0.5, 'ForegroundPolarity', 'dark');
Normalize_Phase = mat2gray(double(PhaseImageMean) ./ AdaptBG);

imshow(mat2gray(Normalize_Phase))
