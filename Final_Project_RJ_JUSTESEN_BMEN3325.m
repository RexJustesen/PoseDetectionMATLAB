%% Program to calculate angle at each knee in squat position
%This program will have a person step into the webcam and take one picture 
%standing and one in a sqaut positon
%this will allow a trained professional to see the angle at the knee and
%show let them know if the person has muscular inbalances based on the
%angle of the knee in the squatted position. the webcam will pop up when
%the run button is hit, by exiting out of the popup window the first
%screenshot will be taken, then the webcam will popup again and this
%indicates that the person should squat and by exiting the popup the second
%screenshot will be taken. 


clear all;
detector = posenet.PoseEstimator; %acesses machine learning database from 
%tensorflow trained for pose detection.

player = vision.DeployableVideoPlayer; %initialize player
I = zeros(256,192,3,'uint8'); %initialize image array as 8 bit integers,
%pose detection has size constraints that can only use 8 bit integers.
arr = {uint8(size(I)),uint8(size(I))}; %initialize cell array for storing 
%captures images.
player(I); %change resolution of webcam to fit pose detection database
angleArr(2,2) = 0;

for i =1:2
    flag = 1; %flag used to exit while loop
    cam = webcam; %initializes variable for webcam snapshot
while flag == 1
   % for i = 1:2
    % Read an image from web camera 
    I = snapshot(cam);
    
    % Crop the image fitting the network input size of 256x192 
    Iinresize = imresize(I,[256 nan]);
    Itmp = Iinresize(:,(size(Iinresize,2)-192)/2:(size(Iinresize,2)-192)/2+192-1,:);
    Icrop = Itmp(1:256,1:192,1:3);
    
    % Predict pose estimation
    heatmaps = detector.predict(Icrop);
    keypoints = detector.heatmaps2Keypoints(heatmaps);
    
    % Visualize key points
    Iout = detector.visualizeKeyPoints(Icrop,keypoints);
    player(Iout);
    %if keypoints(12:17,3) == 0
     %   error('Lower half of client is not in frame, please ensure the client is in position and start again')
    %end
    %initialize x,y coordinates for the joints (lol joints sounds like points) of interest 
    rightAnkle =  keypoints(17,1:2);
    leftAnkle = keypoints(16,1:2);
    rightHip  = keypoints(13,1:2);
    leftHip = keypoints(12,1:2);
    rightKnee = keypoints(15,1:2);
    leftKnee = keypoints(14,1:2);
    
    %initialize distance vectors between the hips and knees and ankles and
    %knees
    x10 = rightHip(1) - rightKnee(1);
    y10 = rightHip(2) - rightKnee(2);
    x20 = rightAnkle(1) - rightKnee(1);
    y20 = rightAnkle(2) - rightKnee(2);
    x11 = leftKnee(1) - leftHip(1);
    y11 = abs(leftKnee(2) - leftHip(2));
    x22 = leftKnee(1) - leftAnkle(1);
    y22 = abs(leftKnee(2) - leftAnkle(2));
    
    %calculate angle of right knee
    angle1 = atan2(abs(x10*y20-x20*y10),x10*y10+x20*y20) *180/pi;
    
    %calculate angle of left knee
    angle2 = (atan2(abs(x11*y22-x22*y11),x11*y11+x22*y22) *180/pi);
    
    %store angles into angle array. 
    angleArr(i,1) = angle1;
    angleArr(i,2) = angle2;
  
    %store image into cell array.
    arr{1,i} = Iout;
    
    if ~isOpen(player)
       flag = 2; %flag to run through for loop a second time
      release(player); %release player to allow webcam to be accesed again
    end

end
%clear webcam for second iteration.
clear cam
end

sprintf('The angle at the right knee when squatting is %g \n', angleArr(2,1))
sprintf('The angle at the left knee when squatting is %g \n', angleArr(2,2))
if angleArr(2,1) > 90
    warning('Right knee may have muscular imbalances');
end

if angleArr(2,2) > 90
    warning('Left knee may have muscular imbalances');
    
end
%convert image cell array to matrix for display
A = cell2mat(arr(1,1)); 
B = cell2mat(arr(1,2));
str1 = sprintf('Angle of right knee: %g degrees', angleArr(1,1));
str2 = sprintf('Angle of left knee: %g degrees', angleArr(1,2));
%display standing image
subplot(1,2,1)
%display standing image
image(A)
title('Standing Position');
subplot(1,2,2)
%display squatting image
image(B)
title('Squat Position Right Knee Angle ', num2str(angleArr(1,1)));

    

 