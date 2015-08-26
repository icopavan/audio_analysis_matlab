[ training_drums, test_drums, training_data, test_data, fs ] = GetData2('E:\FH\Masterthesis\recordings\14_08_18\wav');

[AMax, AMin, SMax ] = TrainDrums( training_data );



for i=1:90
    test_drums(i)
    Classify(test_data(:,i), AMax, AMin, SMax);
end
