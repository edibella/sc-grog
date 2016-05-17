function KSpaceData = flatten_rays(KSpaceData)
  % This function compares the k-space data to the trajectory and flattens
  % 'rays' where 'rays' are the dimensions from position 2 to the end of the
  % trajectory. To be as clear as possible, I'll include line-by-line examples
  % of what the code does.

  % For example. Let's say
  % that the data was nReadout x nRay x nTime x nCoil. This code
  % should combine nRay and nTime to become all rays.
  % Let's also say that the trajectory has size nReadout x nRay x nTime.

  % First check that k-space contains more info than the trajectory. Since this
  % method is for multi-coil data, this should always be true.
  ndimsKSpace = ndims(KSpaceData.kSpace); % 4
  ndimsTrajectory = ndims(KSpaceData.trajectory); % 3
  sizeDiff = ndimsKSpace - ndimsTrajectory; % 1
  if sizeDiff < 1
    error('Data doesn''t seem suitable for GROG interpolation. Please check data and read docs on how to use `pre_interpolate`')
  end

  % Now figure out where the rays are and smash them.

  % Some needed variables
  nReadout = size(KSpaceData.kSpace, 1); % nReadout
  coilIndex = ndimsTrajectory + 1; % 4
  nCoil = size(KSpaceData.kSpace, coilIndex); % nCoil


  % determine length of ray dimension
  rayIndices = 2:ndimsTrajectory; % [2,3]
  for index = 1:length(rayIndices) % [1,2]
    lengths(index) = size(KSpaceData.kSpace, rayIndices(index));
    % lengths[1] = size(KSpaceData.kSpace, 2)
    % lengths[2] = size(KSpaceData.kSpace, 3)
  end
  % lengths = [nRay, nTime]
  raySize = prod(lengths); % nRay * nTime

  % Now reshape k-space according to the above
  KSpaceData.kSpace = reshape(KSpaceData.kSpace, nReadout, raySize, nCoil);

  % Now do the same for the trajectories
  KSpaceData.trajectory = reshape(KSpaceData.trajectory, nReadout, raySize);
end
