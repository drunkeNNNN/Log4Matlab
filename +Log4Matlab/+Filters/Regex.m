classdef Regex < Log4Matlab.Filters.Filter
    properties(Constant,Access=public)
        MODE_ALL=0;
        MODE_ANY=1;
    end

    properties(Access=private)
        regexes;
        regexMode;
    end

    methods(Access=public)
        function obj = setRegex(obj,regexes,regexMode)
            arguments
                obj;
                regexes;
                regexMode double = 1;
            end
            obj.regexMode=regexMode;
            if isstring(regexes)||ischar(regexes)
                regexes={regexes};
            end
            obj.regexes=regexes;
        end
    end
    methods(Access=protected)
        function doesMatch=matches(obj,message)
            if isempty(obj.regexes)
                doesMatch=true;
                return;
            end
            doesMatchesSingleRegex=cellfun(@(x)(obj.matchesSingleRegex(message,x)),obj.regexes,'UniformOutput',true);
            switch obj.regexMode
                case obj.MODE_ALL
                    doesMatch=all(doesMatchesSingleRegex);
                case obj.MODE_ANY
                    doesMatch=any(doesMatchesSingleRegex);
                otherwise
                    error('Class internal error. Wrong regex mode should be validated in setter argument block.')
            end

        end

        function doesMatch=matchesSingleRegex(~,message,regexString)
            if isempty(regexString)
                doesMatch=true;
            else 
                doesMatch=~isempty(regexp(message,regexString, 'once'));
            end
        end
    end
end

