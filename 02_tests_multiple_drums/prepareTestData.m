function testdata = prepareTestData( testdata1, testdata2 )
%PREPAREDATA Summary of this function goes here
%   Detailed explanation goes here


    sizeData=size(testdata1);
    testdata = zeros(sizeData(1), sizeData(2));
    
    for i=1:sizeData(2)
      %% define y1, y2
      y1 = testdata1(2:sizeData(1),i);
      y2 = testdata2(2:sizeData(1),i);
      
      %% detect onsets
      onsets1 = detectOnsets(y1);
      onset1 = onsets1(1);
      onsets2 = detectOnsets(y2);
      onset2 = onsets2(1);

      %% superimpose records
      after_onset = min(length(y1)-onset1, length(y2)-onset2);
      before_onset = min(onset1, onset2);
      y = y1(onset1-before_onset+1:onset1+after_onset) + y2(onset2-before_onset+1:onset2+after_onset);
      
      %save y
      testdata(1,i)=testdata1(1,i);
      testdata(2:length(y)+1,i) = y;      
    end

    size(testdata)
end