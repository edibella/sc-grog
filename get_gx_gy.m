function [gX, gY] = get_gx_gy(KSpaceData)
% compute GRAPPA gX and gY operators. See documentation for more info.

  % Check Data struct
  requiredFields = { 'kSpace', 'trajectory', 'cartesianSize' };
  verify_struct(KSpaceData, requiredFields, 'KSpaceData');

  % If kSpace has more than three dimensions flatten the rays
  if ndims(KSpaceData.kSpace) > 3
    KSpaceData = flatten_rays(KSpaceData);
  end

  kSpace3D = KSpaceData.kSpace;
  trajectory2D = KSpaceData.trajectory;

  kxMatrix = KSpaceData.cartesianSize(1) * real(trajectory2D);
  kyMatrix = KSpaceData.cartesianSize(2) * imag(trajectory2D);

  % Initialize nmMatrix and vMatrix, see docs for variable naming.
  [nReadouts, nRays, nCoils] = size(kSpace3D);

  nmMatrix = zeros(2, nRays);
  vMatrix = zeros(nCoils, nCoils, nRays);

  % Create nmMatrix and vMatrix, ray-by-ray
  for iRay = 1:nRays
    %  Master Equation:
    %
    %     targetData = gRay * sourceData
    %
    % Since we're grabbing just 1 ray, from our 3D slice, targetData becomes a
    % (nReadouts - 1) x 1 x nCoils thing. But what we need is for targetData and
    % sourceData to be nCoils x (nReadouts - 1). So we squeeze and transpose

    targetData = squeeze(kSpace3D(2:end,iRay,:)).';
    sourceData = squeeze(kSpace3D(1:end-1,iRay,:)).';

    % Now solve targetData = gRay * sourceData where gRay is an nCoils x nCoils
    % grappa-like coefficients matrix for that ray (we'll combine all of the Gs
    % from all rays later).
    gRay = targetData * pinv(sourceData);

    % Step 1, figure out n and m for this ray
    nRay = kxMatrix(round(nReadouts/2), iRay) - kxMatrix(round(nReadouts/2) - 1, iRay);
    mRay = kyMatrix(round(nReadouts/2), iRay) - kyMatrix(round(nReadouts/2) - 1, iRay);

    % Step 2, load m and n into nmMatrix
    %          and load gRay into vMatrix.
    nmMatrix(:,iRay) = [nRay, mRay];
    vMatrix(:,:,iRay) = logm(gRay);
  end

  % Step 3 pseudo-invert nmMatrix and multiply by vMatrix to get ln(gX) and ln(gY) for each element.
  logGx = zeros(nCoils, nCoils); % ln(gX)
  logGy = zeros(nCoils, nCoils); % ln(gY)

  for row = 1:nCoils
    for col = 1:nCoils
      logResult = pinv(nmMatrix).' * squeeze(vMatrix(row,col,:));
      logResult = squeeze(logResult);
      logGx(row,col) = logResult(1);
      logGy(row,col) = logResult(2);
    end
  end

  % Step 4 solve for gX and gY by taking matrix exponent
  gX = expm(logGx);
  gY = expm(logGy);
end
