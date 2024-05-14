clc; clear;

imageProcessingGUI;

function imageProcessingGUI()
    % 创建主窗口
    mainFigure = figure('Name', 'Image Processing GUI', 'NumberTitle', 'off', 'Position', [100, 100, 1250, 700]);

    % 添加按钮
    btnLoadImage = uicontrol('Style', 'pushbutton', 'String', '导入初始图像', 'Position', [50, 650, 100, 30], 'Callback', @loadImageCallback);
    btnConvertToGray = uicontrol('Style', 'pushbutton', 'String', '灰度图像', 'Position', [50, 600, 150, 30], 'Callback', @convertToGrayCallback);
    btnAdjustBrightness = uicontrol('Style', 'pushbutton', 'String', '明暗度调整', 'Position', [50, 550, 150, 30], 'Callback', @adjustBrightnessCallback);
    btnAdjustSaturation = uicontrol('Style', 'pushbutton', 'String', '饱和度调整', 'Position', [50, 500, 150, 30], 'Callback', @adjustSaturationCallback);
    btnEdgeDetection = uicontrol('Style', 'pushbutton', 'String', '边缘增强', 'Position', [50, 450, 150, 30], 'Callback', @edgeDetectionCallback);
    btnAdjustSharpness = uicontrol('Style', 'pushbutton', 'String', '清晰度调整', 'Position', [50, 400, 150, 30], 'Callback', @adjustSharpnessCallback);
    btnSharpenImage = uicontrol('Style', 'pushbutton', 'String', '锐化', 'Position', [50, 350, 150, 30], 'Callback', @sharpenImageCallback);
    btnHistogramEqualization = uicontrol('Style', 'pushbutton', 'String', '直方图均衡化', 'Position', [50, 300, 150, 30], 'Callback', @histogramEqualizationCallback);
    btnFrequencyDomainFiltering = uicontrol('Style', 'pushbutton', 'String', '频域滤波', 'Position', [50, 250, 150, 30], 'Callback', @frequencyDomainFilteringCallback);
    btnImageSmoothing = uicontrol('Style', 'pushbutton', 'String', '高斯核平滑', 'Position', [50, 200, 150, 30], 'Callback', @imageSmoothing_Callback);
    adaptiveImageEnhancement = uicontrol('Style', 'pushbutton', 'String', '自适应图像增强', 'Position', [50, 150, 150, 30], 'Callback', @adaptiveImageEnhancement_Callback);
    btnPowerLawTransform = uicontrol('Style', 'pushbutton', 'String', '幂律变换', 'Position', [50, 100, 150, 30], 'Callback', @powerLawTransform_Callback);
    btnNoiseFiltering = uicontrol('Style', 'pushbutton', 'String', '噪声滤波', 'Position', [50, 50, 150, 30], 'Callback', @noiseFiltering_Callback);

    % 显示彩色图像的axes
    axesOriginalImage = axes('Parent', mainFigure, 'Units', 'pixels', 'Position', [250, 300, 200, 150]);
    title('初始图象');
    % 显示处理后图像的axes
    axesProcessedImage = axes('Parent', mainFigure, 'Units', 'pixels', 'Position', [500, 300, 200, 150]);
    title('处理后图像');
    % 显示处理后图像的直方图的axes
    axesHistogram = axes('Parent', mainFigure, 'Units', 'pixels', 'Position', [750, 300, 200, 150]);
    title('图像直方图');
    % 显示处理后图像的傅里叶频谱的axes
    axesFourierTransform = axes('Parent', mainFigure, 'Units', 'pixels', 'Position', [1000, 300, 200, 150]);
    title('傅里叶频谱');
    % 用来保存加载的图像
    loadedImage = [];
    processedImage = [];
    
    % 加载图像的回调函数
    function loadImageCallback(~, ~)
        [filename, pathname] = uigetfile({'*.jpg;*.png;*.bmp', 'Image Files (*.jpg, *.png, *.bmp)'}, 'Select an image file');
        if isequal(filename, 0) || isequal(pathname, 0)
            return;
        end
        imagePath = fullfile(pathname, filename);
        loadedImage = imread(imagePath);
        axes(axesOriginalImage);
        imshow(loadedImage);
    end

    % 将图像转换为灰度图像的回调函数
    function convertToGrayCallback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        grayImage = rgb2gray(loadedImage);
        axes(axesProcessedImage);
        imshow(grayImage);
        axes(axesHistogram);
        imhist(grayImage);
        fftImage = fft2(grayImage);
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 调整图像明暗度的回调函数
    function adjustBrightnessCallback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        brightnessValue = inputdlg('Enter brightness value (between -1 and 1):', 'Brightness', 1, {'0'});
        brightnessValue = str2double(brightnessValue);
        if isempty(brightnessValue) || isnan(brightnessValue) || brightnessValue < -1 || brightnessValue > 1
            msgbox('Brightness value must be a number between -1 and 1.', 'Error', 'error');
            return;
        end
        lowOut = max(0, -brightnessValue);
        highOut = min(1, 1 - brightnessValue);
        adjustedImage = imadjust(loadedImage, [0, 1], [lowOut, highOut]);
        axes(axesProcessedImage);
        imshow(adjustedImage);
        axes(axesHistogram);
        imhist(rgb2gray(adjustedImage));
        fftImage = fft2(rgb2gray(adjustedImage));
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 调整图像饱和度的回调函数
    function adjustSaturationCallback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        saturationValue = inputdlg('Enter saturation value:', 'Saturation', 1, {'1.0'});
        saturationValue = str2double(saturationValue);
        if isempty(saturationValue) || isnan(saturationValue) || saturationValue <= 0
            msgbox('Saturation value must be a positive number.', 'Error', 'error');
            return;
        end
        hsvImage = rgb2hsv(loadedImage);
        hsvImage(:, :, 2) = hsvImage(:, :, 2) * saturationValue;
        adjustedImage = hsv2rgb(hsvImage);
        axes(axesProcessedImage);
        imshow(adjustedImage);
        axes(axesHistogram);
        imhist(rgb2gray(adjustedImage));
        fftImage = fft2(rgb2gray(adjustedImage));
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 边缘检测的回调函数
    function edgeDetectionCallback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        grayImage = rgb2gray(loadedImage);
        edgeImage = edge(grayImage, 'Sobel');
        axes(axesProcessedImage);
        imshow(edgeImage);
        axes(axesHistogram);
        imhist(edgeImage);
        fftImage = fft2(edgeImage);
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 调整图像清晰度的回调函数
    function adjustSharpnessCallback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        sharpnessValue = inputdlg('Enter sharpness value:', 'Sharpness', 1, {'1.0'});
        sharpnessValue = str2double(sharpnessValue);
        if isempty(sharpnessValue) || isnan(sharpnessValue) || sharpnessValue <= 0
            msgbox('Sharpness value must be a positive number.', 'Error', 'error');
            return;
        end
        adjustedImage = imsharpen(loadedImage, 'Amount', sharpnessValue);
        axes(axesProcessedImage);
        imshow(adjustedImage);
        axes(axesHistogram);
        imhist(rgb2gray(adjustedImage));
        fftImage = fft2(rgb2gray(adjustedImage));
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 图像锐化的回调函数
    function sharpenImageCallback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        sharpenType = questdlg('Select sharpening type:', 'Sharpening Type', 'Laplacian', 'Gradient', 'Laplacian');
        grayImage = rgb2gray(loadedImage);
        if strcmpi(sharpenType, 'Laplacian')
            sharpenedImage = imsharpen(grayImage, 'Amount', 1.5);
        elseif strcmpi(sharpenType, 'Gradient')
            h = fspecial('unsharp');
            sharpenedImage = imfilter(grayImage, h);
        else
            return;
        end
        axes(axesProcessedImage);
        imshow(sharpenedImage);
        axes(axesHistogram);
        imhist(sharpenedImage, 256); 
        fftImage = fft2(sharpenedImage);
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 直方图均衡化的回调函数
    function histogramEqualizationCallback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        grayImage = rgb2gray(loadedImage);
        equalizedImage = histeq(grayImage);
        axes(axesProcessedImage);
        imshow(equalizedImage);
        axes(axesHistogram);
        imhist(equalizedImage);
        fftImage = fft2(equalizedImage);
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 频域滤波的回调函数
    function frequencyDomainFilteringCallback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        grayImage = rgb2gray(loadedImage);
        fftImage = fft2(grayImage);
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        prompt = {'Enter filter type (low/high/band):', 'Enter pass range (e.g., [0.1, 0.5]):'};
        dlgtitle = 'Frequency Domain Filtering';
        dims = [1 50];
        definput = {'low', '[0.1, 0.5]'};
        filterParams = inputdlg(prompt, dlgtitle, dims, definput);
        filterType = filterParams{1};
        passRange = eval(filterParams{2});
        [rows, cols] = size(fftImage);
        centerRow = floor(rows / 2) + 1;
        centerCol = floor(cols / 2) + 1;
        [X, Y] = meshgrid(1:cols, 1:rows);
        if strcmpi(filterType, 'low')
            radius = min(rows, cols) * passRange(1);
            filter = exp(-((X - centerCol).^2 + (Y - centerRow).^2) / (2 * radius^2));
        elseif strcmpi(filterType, 'high')
            radius = min(rows, cols) * passRange(1);
            filter = 1 - exp(-((X - centerCol).^2 + (Y - centerRow).^2) / (2 * radius^2));
        elseif strcmpi(filterType, 'band')
            lowRadius = min(rows, cols) * passRange(1);
            highRadius = min(rows, cols) * passRange(2);
            filter = double((X - centerCol).^2 + (Y - centerRow).^2 >= lowRadius^2 & (X - centerCol).^2 + (Y - centerRow).^2 <= highRadius^2);
        else
            msgbox('Invalid filter type.', 'Error', 'error');
            return;
        end
        filteredFFT = fftImage .* filter;
        filteredImage = ifftshift(filteredFFT);
        filteredImage = ifft2(filteredImage);
        filteredImage = real(filteredImage);
        axes(axesProcessedImage);
        imshow(filteredImage, []);
        axes(axesHistogram);
        imhist(filteredImage, 256);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 图像平滑的回调函数
    function imageSmoothing_Callback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        smoothedImg = imgaussfilt(loadedImage, 3); % 3 为高斯核的标准差，可根据需要调整
        axes(axesProcessedImage);
        imshow(smoothedImg);
        axes(axesHistogram);
        imhist(smoothedImg, 256);
        fftImage = fft2(smoothedImg);
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 自适应图像增强的回调函数
    function adaptiveImageEnhancement_Callback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        if ndims(loadedImage) == 3
            grayImage = rgb2gray(loadedImage);
        else
            grayImage = loadedImage;
        end
        enhancedImg = adapthisteq(grayImage);
        axes(axesProcessedImage);
        imshow(enhancedImg);
        axes(axesHistogram);
        imhist(enhancedImg, 256);
        fftImage = fft2(enhancedImg);
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 幂律变换的回调函数
    function powerLawTransform_Callback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        prompt = {'Enter gamma value:'};
        dlgtitle = 'Power Law Transform';
        dims = [1 50];
        definput = {'1.0'}; % 默认值为 1.0
        gammaValue = inputdlg(prompt, dlgtitle, dims, definput);
        gamma = str2double(gammaValue{1});
        if isempty(gamma) || isnan(gamma) || gamma <= 0
            msgbox('Gamma value must be a positive number.', 'Error', 'error');
            return;
        end
        powerLawImage = imadjust(loadedImage, [], [], gamma);
        axes(axesProcessedImage);
        imshow(powerLawImage);
        axes(axesHistogram);
        imhist(rgb2gray(powerLawImage));
        fftImage = fft2(rgb2gray(powerLawImage));
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

    % 噪声滤波的回调函数
    function noiseFiltering_Callback(~, ~)
        if isempty(loadedImage)
            msgbox('Please load an image first.', 'Error', 'error');
            return;
        end
        filterMethods = {'Mean', 'Wiener'};
        [selectedIndex, ~] = listdlg('PromptString', 'Select noise filtering method:', ...
            'SelectionMode', 'single', 'ListString', filterMethods);
        if isempty(selectedIndex)
            return; 
        end
        selectedMethod = filterMethods{selectedIndex};
        switch selectedMethod
            case 'Mean'
                % 使用均值滤波
                filteredImage = imfilter(loadedImage, fspecial('average'));
            case 'Wiener'
                % 使用维纳滤波
                grayImage = rgb2gray(loadedImage);
                filteredImage = wiener2(grayImage);
        end
        axes(axesProcessedImage);
        imshow(filteredImage);
        axes(axesHistogram);
        if strcmp(selectedMethod, 'Wiener')
            filteredImage = uint8(filteredImage);
        end
        imhist(filteredImage);
        if strcmp(selectedMethod, 'Mean')
            fftImage = fft2(rgb2gray(filteredImage));
        elseif strcmp(selectedMethod, 'Wiener')
            fftImage = fft2(grayImage);
        end
        fftImage = fftshift(fftImage);
        magnitudeImage = abs(fftImage);
        axes(axesFourierTransform);
        imshow(log(1 + magnitudeImage), []);
        colormap(gca, jet);
        colorbar;
        title('Fourier Transform');
    end

end
