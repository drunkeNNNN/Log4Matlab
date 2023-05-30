classdef Regex < Log4M.Filters.Filter
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
                regexes={};
                regexMode double = obj.MODE_ANY;
            end
            obj.regexMode=regexMode;
            regexes=obj.convertTextToCellArray(regexes);

            delete=false(size(regexes));
            for i=1:numel(regexes)
                if isempty(regexes{i})
                    delete(i)=true;
                elseif isstring(regexes{i}) && regexes{i}==""
                    delete(i)=true;
                end
            end
            obj.regexes=regexes(~delete);
        end
    end

    methods(Access=protected)
        function enabled=isEnabled(obj)
            enabled=~isempty(obj.regexes);
        end

        function doesMatch=matches(obj,message)
            arguments
                obj Log4M.Filters.Regex;
                message char;
            end
            doesMatchesSingleRegex=cellfun(@(x)(obj.matchesSingleRegex(message,x)),obj.regexes,'UniformOutput',true);
            switch obj.regexMode
                case obj.MODE_ALL
                    doesMatch=all(doesMatchesSingleRegex);
                case obj.MODE_ANY
                    doesMatch=any(doesMatchesSingleRegex);
                otherwise
                    error('Class internal error. Wrong regex mode should be validated in setter argument block.');
            end
        end
    end
    methods(Access=private)
        function regexes=convertTextToCellArray(~,regexes)
            if isempty(regexes)
                regexes={};
            elseif ischar(regexes)
                regexes={regexes};
            elseif isstring(regexes)
                if regexes==""
                    regexes={};
                elseif isscalar(regexes)
                    regexes={regexes};
                else
                    regexes={regexes{:}};
                end
            end
            if ~iscell(regexes)
                error('Regexes must be string, char, or a cell array of strings and chars.');
            end
        end

        function doesMatch=matchesSingleRegex(~,message,regexString)
            if isempty(regexString)
                doesMatch=true;
            else
                doesMatch=~isempty(regexp(message,regexString, 'once'));
            end
        end

        function validateFilterRegexes(~,filterRegexes)
            if ischar(filterRegexes) || isstring(filterRegexes)
                return;
            elseif iscell(filterRegexes)
                isString=cellfun(@isstring,filterRegexes,'UniformOutput',true);
                isChar=cellfun(@ischar,filterRegexes,'UniformOutput',true);
                if all(isString|isChar)
                    return;
                end
            end
            error('filterRegex must be a char, string or a cell array of chars or strings.');
        end
    end
end

