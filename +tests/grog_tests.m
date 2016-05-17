function grog_tests(tester)
  import ScGrog.*
  % Test data comes from some gated cardiac perfusion data that has been PCA'd
  load('test_grog_data_4D.mat')
  load('gx_gy_results.mat')

  % Needed variable - cartesianSize
  [nReadout, ~, nTime, nCoil] = size(testData4D);
  cartesianSize = [nReadout, nReadout, nTime, nCoil];

  % Load example data into a struct
  KSpaceData.kSpace = testData4D;
  KSpaceData.trajectory = testTrajectory3D;
  KSpaceData.cartesianSize = cartesianSize;

  % get Gx and Gy for comparison
  [presentGx, presentGy] = get_gx_gy(KSpaceData);

  tester.test(officialGx, presentGx, 'Test scGROG Gx')
  tester.test(officialGy, presentGy, 'Test scGROG Gy')
end
