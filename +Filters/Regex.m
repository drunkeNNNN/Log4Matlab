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
            if isempty(obj.acceptFilterArray)
                doesMatch=true;
                return;
            end
            for j=1:length(obj.acceptFilterArray)
                if isempty(obj.acceptFilterArray{j})
                    continue;
                end
                if ~isempty(matches(message,obj.regexes))
                    doesMatch=true;
                    return;
                end
            end
            doesMatch=false;
            return;
        end
    end
end

