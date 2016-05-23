function verify_struct(Data, requiredFields, structName)
  % setup missing fields struct for error message
  missingFields = {};

  % Loop through each required field and assert existence of fields
  nFields = length(requiredFields);
  for iField = 1:nFields
    fieldName = requiredFields{iField};

    % Check if fieldName is in struct
    if ~isfield(Data, fieldName)
      missingFields = [missingFields, fieldName];
    end
  end

  % The rest is just for nice error messaging . . . sheesh
  % Concatenate missing fields into error message
  nMissing = length(missingFields);
  switch nMissing
    case 0
      return
    case 1
      missingFieldsString = [ missingFields{1} ' field.' ];
    case 2
      missingFieldsString = [ missingFields{1} ' and ' missingFields{2} ' fields.' ];
    otherwise
      firstFields = strjoin(missingFields(1:end-1), ', ');
      lastField = missingFields(end);
      missingFieldsString = [ firstFields ', and ' lastField{1} ' fields.' ];
  end

  % Create and throw error
  Error.message = [structName ' struct is missing the ' missingFieldsString];
  Error.identifier = 'VerifyStruct:MissingFields';
  Error.stack =  dbstack(1, '-completenames');
  % raise error
  error(Error)
end
