classdef Regex < Filters.Filter
    properties(Access=private)
        regexes;
    end
    
    methods(Access=public)       
        function obj = setRegex(obj,regexes)
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
            for j=1:length(obj.regexes)
                if isempty(obj.regexes{j})
                    continue;
                end
                if ~isempty(regexp(message,obj.regexes{j},'match'))
                    doesMatch=true;
                    return;
                end
            end
            doesMatch=false;
            return;
        end
    end
end

