function pgp_util_error_message(errorCode, varargin)
    persistent errMap;
    
    if isempty(errMap)
        errMap = pg_create_error_map();
    end

    
    errMsg1      = '';
    errMsg2       = '';
    funCallStack = dbstack;
    
    for i = length(funCallStack):-1:2
        errMsg1 = cat(2, errMsg1, funCallStack(i).file, '@', num2str(funCallStack(i).line));
        errMsg2 = cat(2, errMsg2, funCallStack(i).name);
        
        if i > 2
             errMsg1 = cat(2, errMsg1, '  ->  ');
             errMsg2 = cat(2, errMsg2, '  ->  ');
        end
    end
    
    if ~isempty(errMsg1)
        fprintf('An ERROR (error code %d) occurred at: \n', errorCode);
        fprintf('[FILE STACK]\n%s\n', errMsg1);
        fprintf('[FUNCTION STACK]\n%s\n', errMsg2);
    end
    
    errMsg = errMap(errorCode);
    

    pIdx = 1;
    for i = 1:length(varargin)
        errMsg = strrep(errMsg, sprintf('$%d', pIdx), varargin{i});
        pIdx = pIdx + 1;
    end
    fprintf('\nWith the following message: \n%s\n', errMsg);

    
end



function errMap = pg_create_error_map()


    errMap = containers.Map('KeyType', 'int32', 'ValueType', 'char');
   
    errMap(-1) = 'The specified filepath does not exist ($1).';
    errMap(-2) = 'Error parsing file $1.';
    errMap(-3) = '$1 failed with message: $2';
    errMap(-4) = 'Permutation failed with message: $1';
    errMap(-5) = 'Model training failed with message: $1';
    errMap(-6) = 'PLS-DA cannot handle multiple quantitation types';
    errMap(-7) = 'Missing values are not allowed';
    errMap(-8) = 'Grouping must be defined using exactly one data color';
    errMap(-9) = 'Grouping must contain at least two different levels';
    errMap(-10) = 'Spot ID could not be retrieved';
    errMap(-11) = 'Invalid value for property "$1"';

 
    
    errMap(-1000) = 'Invalid argument, expected plsda --infile=/path/to/file';


end