load("input.mat");
load("output.mat");


%histogram(output(1, :), 10);

hiddenLayerSize = 15;

PS_MODEL = fitnet(hiddenLayerSize);
PS_MODEL.divideParam.trainRatio = 0.7;
PS_MODEL.divideParam.valRatio = 0.15;
PS_MODEL.divideParam.testRatio = 0.15;

PS_MODEL.trainParam.epochs = 5000;

[PS_MODEL, tr] = train(PS_MODEL, input, output);

save PS_MODEL